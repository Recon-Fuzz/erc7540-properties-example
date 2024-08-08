// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    function vault_requestDeposit(uint256 assets) public {
        // clamp inputs to use the values from setup
        vault.requestDeposit(assets, admin, admin);
    }

    function vault_mint(uint256 shares) public {
        vault.mint(shares, admin);
    }

    // NOTE: this is required for checks in properties to be valid, could have multiple actors in setup and switch between them
    function setup_switchActor() public {
        actor = admin;
    }
}
