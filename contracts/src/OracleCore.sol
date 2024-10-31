// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IOracleCore} from "./IOracleCore.sol";
import {EventLib} from "./libraries/EventLib.sol";
import {ECDSAServiceManagerBase} from "eigenlayer-middleware/unaudited/ECDSAServiceManagerBase.sol";
import {ECDSAStakeRegistry} from "eigenlayer-middleware/unaudited/ECDSAStakeRegistry.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract OracleCore is IOracleCore, ECDSAServiceManagerBase {
    using EventLib for *;
    using ECDSA for bytes32;

    mapping(bytes32 id => Event) public events;
    mapping(bytes32 id => EventData dispute) public disputingEvents;

    uint256 public constant SETTLE_LIVENESS = 10 minutes;

    modifier onlyOperator() {
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(msg.sender),
            "Operator must be the caller"
        );
        _;
    }

    constructor(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager
    )
        ECDSAServiceManagerBase(_avsDirectory, _stakeRegistry, _rewardsCoordinator, _delegationManager)
    {}

    /// @notice create an event request
    function request(
        string calldata _title,
        bytes calldata _requestContent,
        address _requestor
    ) external returns (bytes32 id) {
        Event memory e = Event({
            title: _title,
            request: EventData({
                content: _requestContent,
                createAt: block.timestamp,
                creator: _requestor
            }),
            proposed: EventData({creator: address(0), createAt: 0, content: ""}),
            status: Status.REQUESTED
        });

        id = e.toId();
        if (events[id].request.createAt != 0) revert EventAlreadyExists();

        events[id] = e;
        emit RequestEvent(id, _requestor, _title, _requestContent, block.timestamp);
    }

    /// @notice propose an requested event result, anyone can propose
    function propose(Event memory _event, bytes calldata data, address proposer) external {
        bytes32 id = _event.toId();
        _checkEventValid(id, Status.REQUESTED);

        EventData storage proposed = events[id].proposed;

        proposed.content = data;
        proposed.creator = proposer;
        proposed.createAt = block.timestamp;

        events[id].status = Status.PROPOSED;

        emit ProposeEvent(id, proposer, data, block.timestamp);
    }

    /// @notice settle an proposed event by operator signature
    function verifyProposed(
        Event memory _event,
        bytes memory signatureData
    ) external onlyOperator {
        bytes32 id = _event.toId();

        _checkEventValid(id, Status.PROPOSED);
        _checkSignature(getDigest(_event), signatureData);

        events[id].status = Status.VERIFIED;

        emit VerifyEvent(id, block.timestamp, _event.request.content, _event.proposed.content);
    }

    function settle(Event memory _event) public {
        bytes32 id = _event.toId();
        _checkEventValid(id, Status.VERIFIED);

        events[id].status = Status.SETTLED;

        emit SettleEvent(id, block.timestamp, _event.request.content, _event.proposed.content);
    }

    function dispute(Event memory _event, bytes calldata disputeData) external {
        bytes32 id = _event.toId();

        _checkEventValid(id, Status.VERIFIED);

        events[id].status = Status.DISPUTED;
        disputingEvents[id] =
            EventData({content: disputeData, createAt: block.timestamp, creator: msg.sender});

        emit DisputeEvent(id, msg.sender, disputeData, block.timestamp);
    }

    function resolve(Event memory _event, bytes memory signatureData) external {
        bytes32 id = _event.toId();
        _checkEventValid(id, Status.DISPUTED);
        _checkSignature(getDigest(_event), signatureData);

        //TODO Slash mechanism

        settle(_event);
    }

    // VIEW FUNCTIONS

    function getDigest(Event memory _event) public pure returns (bytes32) {
        bytes32 id = _event.toId();
        bytes32 message = keccak256(abi.encodePacked(id));
        return message.toEthSignedMessageHash();
    }

    // INTERNAL FUNCTIONS

    function _checkSignature(bytes32 _hash, bytes memory _signaturesData) internal view {
        ECDSAStakeRegistry(stakeRegistry).isValidSignature(_hash, _signaturesData);
    }

    function _checkEventValid(bytes32 id, Status _expect) internal view {
        if (events[id].request.createAt == 0) revert EventNotFound();
        if (events[id].status != _expect) revert EventStatusInvalid(_expect, events[id].status);
    }

    function _checkLiveness(uint256 _settleAt, uint256 _proposeAt) internal view {
        if (_settleAt - _proposeAt < SETTLE_LIVENESS) revert EventNotSettle();
    }
}
