// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    function eRC7540Vault_requestDeposit(
        uint256 assets,
        address controller,
        address owner
    ) public {
        vault.requestDeposit(assets, controller, owner);
    }

    function eRC7540Vault_requestRedeem(
        uint256 shares,
        address controller,
        address owner
    ) public {
        vault.requestRedeem(shares, controller, owner);
    }

    function eRC7540Vault_deposit(uint256 assets, address receiver) public {
        vault.deposit(assets, receiver);
    }

    function eRC7540Vault_withdraw(
        uint256 assets,
        address receiver,
        address controller
    ) public {
        vault.withdraw(assets, receiver, controller);
    }

    // NOTE: this is required for checks in properties to be valid, could have multiple actors in setup and switch between them
    function setup_switchActor() public {
        actor = admin;
    }
}
