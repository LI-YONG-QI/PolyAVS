// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OracleCore} from "../src/OracleCore.sol";

contract OracleCoreScript is Script {
    address _avsDirectory = address(2);
    address _stakeRegistry = address(1);
    address _rewardsCoordinator = address(3);
    address _delegationManager = address(4);

    function run() external {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        OracleCore oracle =
            new OracleCore(_avsDirectory, _stakeRegistry, _rewardsCoordinator, _delegationManager);
        console.log(address(oracle));

        vm.stopBroadcast();
    }
}
