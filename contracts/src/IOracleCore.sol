// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface IOracleCore {
    enum Status {
        REQUESTED,
        PROPOSED,
        SETTLED,
        DISPUTED,
        RESOLVED
    }

    struct Event {
        string title; // event title
        bytes requestContent; // request data
        bytes proposeContent; // response data
        uint256 createAt; // create timestamp
        uint256 proposeAt; // propose timestamp
        uint256 settleAt; // settle timestamp
        address creator; // creator address
        address proposer; // proposer address
        Status status; // status
    }

    error EventAlreadyExists();
    error EventNotFound();
    error EventNotSettle();
    error EventStatusInvalid(Status expect, Status current);

    event RequestEvent(bytes32 indexed id, address indexed creator, bytes requestContent, uint256 time);
    event ProposeEvent(bytes32 indexed id, address indexed proposer, bytes proposeContent, uint256 time);
    event SettleEvent(bytes32 indexed id, uint256 indexed settleTime, bytes requestContent, bytes proposeContent);
    // event DisputeEvent(bytes32 indexed id, bytes data);
    // event ResolveEvent(bytes32 indexed id, bytes data);

    function request(string calldata title, bytes calldata requestContent, address creator)
        external
        returns (bytes32 id);
    function propose(Event memory _event, bytes calldata data, address proposer) external;
    function settle(Event memory _event) external;
    // function dispute(bytes32 id, bytes calldata data, ) external;
    // function resolve(bytes32 id, bytes calldata data) external;
}
