// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OracleCore} from "../src/OracleCore.sol";
import {IOracleCore} from "../src/IOracleCore.sol";
import {ECDSAStakeRegistry} from "eigenlayer-middleware/unaudited/ECDSAStakeRegistry.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {Test, console} from "forge-std/Test.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";

import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract OracleCoreTest is Test {
    using ECDSA for bytes32;

    address public constant SIGNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    uint256 _signerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address _avsDirectory = 0x135DDa560e946695d6f155dACaFC6f1F25C1F5AF;
    address _delegationManager = 0x39053D51B77DC0d36036Fc1fCc8Cb819df8Ef37A;

    OracleCore public oracle;
    ECDSAStakeRegistry public stakeRegistry;

    Quorum internal quorum;

    function setUp() external {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        address signer = vm.addr(_signerPrivateKey);
        vm.startPrank(signer);

        quorum.strategies.push(
            StrategyParams({strategy: IStrategy(address(420)), multiplier: 10_000})
        );

        ECDSAStakeRegistry stakeRegistryImpl =
            new ECDSAStakeRegistry(IDelegationManager(_delegationManager));

        uint64 nonce = vm.getNonce(signer);
        address oracleAddr = vm.computeCreateAddress(signer, nonce + 1);
        bytes memory data = abi.encodeCall(ECDSAStakeRegistry.initialize, (oracleAddr, 0, quorum));

        stakeRegistry =
            ECDSAStakeRegistry(address(new ERC1967Proxy(address(stakeRegistryImpl), data)));

        oracle =
            new OracleCore(_avsDirectory, address(stakeRegistry), address(0), _delegationManager);

        assertEq(stakeRegistry.getServiceManager(), address(oracle));

        _registerOperator();
        vm.stopPrank();
    }

    function _registerOperator() internal {
        IDelegationManager delegationManager = IDelegationManager(_delegationManager);
        IDelegationManager.OperatorDetails memory operatorDetails = IDelegationManager
            .OperatorDetails({
            __deprecated_earningsReceiver: SIGNER,
            delegationApprover: address(0),
            stakerOptOutWindowBlocks: 0
        });

        delegationManager.registerAsOperator(operatorDetails, "");
        assertEq(delegationManager.isOperator(SIGNER), true);
    }

    function test_registerOperatorToAVS() external {
        uint256 expiry = block.timestamp + 10_000;
        bytes32 digest = IAVSDirectory(_avsDirectory).calculateOperatorAVSRegistrationDigestHash(
            SIGNER, address(oracle), 0, expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        ISignatureUtils.SignatureWithSaltAndExpiry memory operatorSignature = ISignatureUtils
            .SignatureWithSaltAndExpiry({signature: signature, salt: 0, expiry: expiry});
        assertEq(digest.recover(signature), SIGNER);

        vm.startPrank(SIGNER);
        stakeRegistry.registerOperatorWithSignature(operatorSignature, SIGNER);
        vm.stopPrank();
    }
}
