// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";
import {ERC7540Properties} from "erc7540-reusable-properties/ERC7540Properties.sol";
import {CallTestAndUndo} from "./helpers/CallTestAndUndo.sol";

abstract contract Properties is
    Setup,
    Asserts,
    ERC7540Properties,
    CallTestAndUndo
{
    function erc7540_1_call_target() public returns (bool) {
        bytes memory encoded = abi.encodeCall(this.erc7540_1, (address(vault)));
        bool asBool = _doTestAndReturnResult(encoded);

        /// NOTE: we define this as an assertion so it can be tested in assertion mode
        t(asBool, "erc7540_1");

        return asBool;
    }

    function erc7540_2_call_target() public returns (bool) {
        bytes memory encoded = abi.encodeCall(this.erc7540_2, (address(vault)));
        bool asBool = _doTestAndReturnResult(encoded);

        /// NOTE: we define this as an assertion so it can be tested in assertion mode
        t(asBool, "erc7540_2");

        return asBool;
    }
}
