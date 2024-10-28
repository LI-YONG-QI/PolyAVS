// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IOracleCore} from "../IOracleCore.sol";

library EventLib {
    function toId(
        string memory title,
        IOracleCore.EventData memory request
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(title, request.content, request.createAt, request.creator));
    }

    function toId(IOracleCore.Event memory e) internal pure returns (bytes32) {
        return toId(e.title, e.request);
    }
}
