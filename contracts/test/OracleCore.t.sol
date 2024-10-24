// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OracleCore} from "../src/OracleCore.sol";
import {IOracleCore} from "../src/IOracleCore.sol";
import {ECDSAStakeRegistry} from "eigenlayer-middleware/unaudited/ECDSAStakeRegistry.sol";
import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {Test, console} from "forge-std/Test.sol";

contract OracleCoreTest is Test {
    string public constant MAINNET_RPC_URL =
        "https://mainnet.infura.io/v3/311142eea537485aabe9b15954cb5960";

    address _avsDirectory = 0x135DDa560e946695d6f155dACaFC6f1F25C1F5AF;
    address _delegationManager = 0x39053D51B77DC0d36036Fc1fCc8Cb819df8Ef37A;

    OracleCore public oracle;
    ECDSAStakeRegistry public stakeRegistry;

    function setUp() external {
        vm.createSelectFork(MAINNET_RPC_URL);

        oracle = new OracleCore(_avsDirectory, address(0), address(0), _delegationManager);
        stakeRegistry = new ECDSAStakeRegistry(IDelegationManager(_delegationManager));
    }

    function test_RegisterAsOperator() external {
        IDelegationManager delegationManager = IDelegationManager(_delegationManager);
        IDelegationManager.OperatorDetails memory operatorDetails = IDelegationManager
            .OperatorDetails({
            __deprecated_earningsReceiver: address(this),
            delegationApprover: address(0),
            stakerOptOutWindowBlocks: 0
        });

        delegationManager.registerAsOperator(operatorDetails, "");
        assertEq(delegationManager.isOperator(address(this)), true);
    }
}
