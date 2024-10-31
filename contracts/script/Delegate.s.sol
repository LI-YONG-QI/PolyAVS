// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OracleCore} from "../src/OracleCore.sol";
import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";

contract Register is Script {
    address public OPERATOR;
    address _delegationManager = 0xA44151489861Fe9e3055d95adC98FbD462B948e7;

    function setUp() external {
        uint256 pk = uint256(vm.envBytes32("OP_PK"));
        OPERATOR = vm.addr(pk);
    }

    function run() external {
        _registerOperator();
    }

    function _registerOperator() internal {
        vm.startBroadcast();

        IDelegationManager delegationManager = IDelegationManager(_delegationManager);
        ISignatureUtils.SignatureWithExpiry memory approverSignatureAndExpiry =
            ISignatureUtils.SignatureWithExpiry("", 0);

        delegationManager.delegateTo(OPERATOR, approverSignatureAndExpiry, 0);

        vm.stopBroadcast();
    }
}
