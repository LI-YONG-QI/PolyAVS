// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OracleCore} from "../src/OracleCore.sol";

contract OracleCoreScript is Script {
    function run() external {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        OracleCore oracle = new OracleCore();
        console.log(address(oracle));

        vm.stopBroadcast();
    }
}
