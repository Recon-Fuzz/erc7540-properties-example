// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";
import {ERC7540Properties} from "erc7540-reusable-properties/ERC7540Properties.sol";

abstract contract Properties is Setup, Asserts, ERC7540Properties {
    function crytic_erc7540_1() public returns (bool test) {
        test = erc7540_1(address(vault));
    }

    function crytic_erc7540_2() public returns (bool test) {
        test = erc7540_2(address(vault));
    }
}