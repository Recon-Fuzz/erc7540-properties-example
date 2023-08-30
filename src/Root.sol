// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.18;

import "./util/Auth.sol";

interface AuthLike {
    function rely(address) external;
    function deny(address) external;
}

contract Root is Auth {
    address public immutable escrow;

    mapping(address => uint256) public schedule;
    uint256 public delay;
    bool public paused = false;

    // --- Events ---
    event File(bytes32 indexed what, uint256 data);
    event Pause();
    event Unpause();
    event RelyScheduled(address indexed target, uint256 indexed scheduledTime);
    event RelyCancelled(address indexed target);
    event RelyContract(address target, address indexed user);
    event DenyContract(address target, address indexed user);

    constructor(address _escrow, uint256 _delay) {
        escrow = _escrow;
        delay = _delay;

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    // --- Administration ---
    function file(bytes32 what, uint256 data) external auth {
        if (what == "delay") delay = data;
        else revert("Root/file-unrecognized-param");
        emit File(what, data);
    }

    // --- Pause management ---
    function pause() external auth {
        paused = true;
        emit Pause();
    }

    function unpause() external auth {
        paused = false;
        emit Unpause();
    }

    /// --- Timelocked ward management ---
    function scheduleRely(address target) external auth {
        schedule[target] = block.timestamp + delay;
        emit RelyScheduled(target, schedule[target]);
    }

    function cancelRely(address target) external auth {
        schedule[target] = 0;
        emit RelyCancelled(target);
    }

    function executeScheduledRely(address target) public {
        require(schedule[target] != 0, "Root/target-not-scheduled");
        require(schedule[target] < block.timestamp, "Root/target-not-ready");

        wards[target] = 1;
        emit Rely(target);

        schedule[target] = 0;
    }

    /// --- External contract ward management ---
    /// @notice  can be called by any ward on the Root contract
    /// to make an arbitrary address a ward on any contract(requires the root contract to be a ward)
    /// @param target the address of the contract
    /// @param user the address which should get ward permissions
    function relyContract(address target, address user) public auth {
        AuthLike(target).rely(user);
        emit RelyContract(target, user);
    }

    /// @notice removes the ward permissions from an address on a contract
    /// @param target the address of the contract
    /// @param user the address which persmissions should be removed
    function denyContract(address target, address user) public auth {
        AuthLike(target).deny(user);
        emit DenyContract(target, user);
    }
}