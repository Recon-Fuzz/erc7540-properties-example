// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";

import "src/ERC7540Vault.sol";
import {ERC20} from "src/token/ERC20.sol";

abstract contract Setup is BaseSetup {
    address admin;
    ERC20 asset;
    ERC20 share;
    ERC7540Vault vault;

    function setup() internal virtual override {
        admin = address(this);
        asset = new ERC20(uint8(18));
        share = new ERC20(uint8(18));
        bytes16 trancheId = hex"01";
        vault = new ERC7540Vault(
            1,
            trancheId,
            address(asset),
            address(share),
            admin,
            admin,
            admin
        );
    }
}
