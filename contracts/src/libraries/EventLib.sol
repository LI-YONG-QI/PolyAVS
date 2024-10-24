// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IOracleCore} from "../IOracleCore.sol";

library EventLib {
    function toId(IOracleCore.Event memory _event) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_event.title, _event.requestContent, _event.createAt, _event.creator));
    }
}
