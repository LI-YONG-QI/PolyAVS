// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface IOracleCore {
    enum Status {
        PROPOSED,
        SETTLED,
        DISPUTED,
        RESOLVED
    }

    event ProposeEvent(bytes32 indexed id, bytes data);
    event SettleEvent(bytes32 indexed id, bytes data);
    // event DisputeEvent(bytes32 indexed id, bytes data);
    // event ResolveEvent(bytes32 indexed id, bytes data);

    function propose(bytes calldata data) external returns (bytes32 id);
    function settle(bytes32 id, bytes calldata data) external;

    // function dispute(bytes32 id, bytes calldata data, ) external;
    // function resolve(bytes32 id, bytes calldata data) external;
}
