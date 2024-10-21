// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IOracleCore} from "./IOracleCore.sol";
import {EventLib} from "./libs/EventLib.sol";

contract OracleCore is IOracleCore {
    using EventLib for Event;

    mapping(bytes32 id => Event) public events;

    uint256 public constant SETTLE_LIVENESS = 10 minutes;

    constructor() {}

    function request(string calldata _title, bytes calldata _requestContent, address _creator)
        external
        returns (bytes32 id)
    {
        Event memory e = Event({
            title: _title,
            requestContent: _requestContent,
            proposeContent: bytes(""),
            createAt: block.timestamp,
            settleAt: 0,
            proposeAt: 0,
            creator: _creator,
            proposer: address(0),
            status: Status.REQUESTED
        });

        id = e.toId();
        if (events[id].createAt != 0) revert EventAlreadyExists();

        events[id] = e;
        emit RequestEvent(id, _creator, _requestContent, block.timestamp);
    }

    function propose(Event memory _event, bytes calldata data, address proposer) external {
        bytes32 id = _event.toId();
        _checkEventValid(id, Status.REQUESTED);

        events[id].proposeContent = data;
        events[id].proposer = proposer;
        events[id].proposeAt = block.timestamp;
        events[id].status = Status.PROPOSED;

        emit ProposeEvent(id, proposer, data, block.timestamp);
    }

    function settle(Event memory _event) external {
        bytes32 id = _event.toId();
        _checkEventValid(id, Status.PROPOSED);
        _checkLiveness(block.timestamp, _event.proposeAt);

        events[id].settleAt = block.timestamp;
        events[id].status = Status.SETTLED;

        emit SettleEvent(id, block.timestamp, _event.requestContent, _event.proposeContent);
    }

    // INTERNAL FUNCTIONS

    function _checkEventValid(bytes32 id, Status _expect) internal view {
        if (events[id].createAt == 0) revert EventNotFound();
        if (events[id].status != _expect) revert EventStatusInvalid(_expect, events[id].status);
    }

    function _checkLiveness(uint256 _settleAt, uint256 _proposeAt) internal pure {
        if (_settleAt - _proposeAt < SETTLE_LIVENESS) revert EventNotSettle();
    }
}
