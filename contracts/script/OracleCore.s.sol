// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OracleCore} from "../src/OracleCore.sol";
import {ECDSAStakeRegistry} from "eigenlayer-middleware/unaudited/ECDSAStakeRegistry.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";

contract OracleCoreScript is Script {
    address _rewardsCoordinator = address(3);

    ECDSAStakeRegistry _stakeRegistry;
    OracleCore oracle;
    address _delegationManager = 0xA44151489861Fe9e3055d95adC98FbD462B948e7;
    address _avsDirectory = 0x055733000064333CaDDbC92763c58BF0192fFeBf;
    address WETH_STRATEGY = 0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9;

    Quorum internal quorum;

    function run() external {
        address deployer = vm.addr(vm.envBytes32("DEPLOYER_PK"));
        vm.startBroadcast(vm.envBytes32("DEPLOYER_PK"));

        quorum.strategies.push(
            StrategyParams({strategy: IStrategy(WETH_STRATEGY), multiplier: 10_000})
        );

        ECDSAStakeRegistry stakeRegistryImpl =
            new ECDSAStakeRegistry(IDelegationManager(_delegationManager));

        uint64 nonce = vm.getNonce(deployer);
        address oracleAddr = vm.computeCreateAddress(deployer, nonce + 1);
        bytes memory data = abi.encodeCall(ECDSAStakeRegistry.initialize, (oracleAddr, 0, quorum));

        _stakeRegistry =
            ECDSAStakeRegistry(address(new ERC1967Proxy(address(stakeRegistryImpl), data)));

        oracle = new OracleCore(
            _avsDirectory, address(_stakeRegistry), _rewardsCoordinator, _delegationManager
        );

        console.log(address(oracle));
        console.log(address(oracleAddr));

        vm.stopBroadcast();

        _registerToAVS();
    }

    function _registerToAVS() internal {
        address op = vm.addr(vm.envBytes32("OP_PK"));

        vm.startBroadcast(vm.envBytes32("OP_PK"));

        uint256 expiry = block.timestamp + 10_000;
        bytes32 digest = IAVSDirectory(_avsDirectory).calculateOperatorAVSRegistrationDigestHash(
            op, address(oracle), 0, expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envBytes32("OP_PK"), digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        ISignatureUtils.SignatureWithSaltAndExpiry memory operatorSignature = ISignatureUtils
            .SignatureWithSaltAndExpiry({signature: signature, salt: 0, expiry: expiry});

        _stakeRegistry.registerOperatorWithSignature(operatorSignature, op);

        console.log(_stakeRegistry.operatorRegistered(op));

        vm.stopBroadcast();
    }
}
