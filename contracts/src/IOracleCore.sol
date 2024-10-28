// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface IOracleCore {
    enum Status {
        REQUESTED,
        PROPOSED,
        VERIFIED,
        SETTLED,
        DISPUTED
    }

    struct EventData {
        bytes content;
        uint256 createAt;
        address creator;
    }

    struct Event {
        string title;
        EventData request;
        EventData proposed; // proposed data
        Status status; // status
    }

    struct EventSig {
        bytes32 id;
        bytes32 salt;
        bytes signature;
    }

    error EventAlreadyExists();
    error EventNotFound();
    error EventNotSettle();
    error EventStatusInvalid(Status expect, Status current);

    event RequestEvent(
        bytes32 indexed id,
        address indexed creator,
        string indexed title,
        bytes requestContent,
        uint256 time
    );
    event ProposeEvent(
        bytes32 indexed id, address indexed proposer, bytes proposeContent, uint256 time
    );
    event VerifyEvent(
        bytes32 indexed id, uint256 verifyTime, bytes requestContent, bytes proposeContent
    );
    event SettleEvent(
        bytes32 indexed id, uint256 settleTime, bytes requestContent, bytes proposeContent
    );
    event DisputeEvent(
        bytes32 indexed id, address indexed disputer, bytes disputeContent, uint256 time
    );

    function request(
        string calldata title,
        bytes calldata requestContent,
        address creator
    ) external returns (bytes32 id);

    function propose(Event memory _event, bytes calldata data, address proposer) external;

    function settle(
        Event memory _event,
        bytes memory signature,
        bytes32 salt,
        uint256 expire
    ) external;

    function dispute(bytes32 id, bytes calldata data) external;

    function resolve(bytes32 id, bytes calldata data) external;

    function getDigest(
        Event memory _event,
        bytes32 salt,
        uint256 expiry
    ) external view returns (bytes32);
}
