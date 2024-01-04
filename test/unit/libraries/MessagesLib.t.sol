// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MessagesLib} from "src/libraries/MessagesLib.sol";
import "forge-std/Test.sol";

contract MessagesLibTest is Test {
    function setUp() public {}

    function testAddCurrency() public {
        uint128 currency = 246803579;
        address currencyAddress = 0x1231231231231231231231231231231231231231;
        bytes memory expectedHex = hex"010000000000000000000000000eb5ec7b1231231231231231231231231231231231231231";

        assertEq(MessagesLib.formatAddCurrency(currency, currencyAddress), expectedHex);

        (uint128 decodedCurrency, address decodedCurrencyAddress) = MessagesLib.parseAddCurrency(expectedHex);
        assertEq(uint256(decodedCurrency), currency);
        assertEq(decodedCurrencyAddress, currencyAddress);
    }

    function testAddCurrencyEquivalence(uint128 currency, address currencyAddress) public {
        bytes memory _message = MessagesLib.formatAddCurrency(currency, currencyAddress);
        (uint128 decodedCurrency, address decodedCurrencyAddress) = MessagesLib.parseAddCurrency(_message);
        assertEq(decodedCurrency, uint256(currency));
        assertEq(decodedCurrencyAddress, currencyAddress);
    }

    function testAddPool() public {
        uint64 poolId = 12378532;
        bytes memory expectedHex = hex"020000000000bce1a4";

        assertEq(MessagesLib.formatAddPool(poolId), expectedHex);

        (uint64 decodedPoolId) = MessagesLib.parseAddPool(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
    }

    function testAddPoolEquivalence(uint64 poolId) public {
        bytes memory _message = MessagesLib.formatAddPool(poolId);
        (uint64 decodedPoolId) = MessagesLib.parseAddPool(_message);
        assertEq(decodedPoolId, uint256(poolId));
    }

    function testAllowInvestmentCurrency() public {
        uint64 poolId = 12378532;
        uint128 currency = 246803579;
        bytes memory expectedHex = hex"030000000000bce1a40000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatAllowInvestmentCurrency(poolId, currency), expectedHex);

        (uint64 decodedPoolId, uint128 decodedCurrency) = MessagesLib.parseAllowInvestmentCurrency(expectedHex);
        assertEq(decodedPoolId, poolId);
        assertEq(uint256(decodedCurrency), currency);
    }

    function testAllowInvestmentCurrencyEquivalence(uint128 currency, uint64 poolId) public {
        bytes memory _message = MessagesLib.formatAllowInvestmentCurrency(poolId, currency);
        (uint64 decodedPoolId, uint128 decodedCurrency) = MessagesLib.parseAllowInvestmentCurrency(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedCurrency, uint256(currency));
    }

    function testAddTranche() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        string memory name = "Some Name";
        string memory symbol = "SYMBOL";
        uint8 decimals = 15;
        uint8 restrictionSet = 2;
        bytes memory expectedHex =
            hex"040000000000000001811acd5b3f17c06841c7e41e9e04cb1b536f6d65204e616d65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053594d424f4c00000000000000000000000000000000000000000000000000000f02";

        assertEq(MessagesLib.formatAddTranche(poolId, trancheId, name, symbol, decimals, restrictionSet), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            string memory decodedTokenName,
            string memory decodedTokenSymbol,
            uint8 decodedDecimals,
            uint8 decodedRestrictionSet
        ) = MessagesLib.parseAddTranche(expectedHex);

        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedTokenName, name);
        assertEq(decodedTokenSymbol, symbol);
        assertEq(decodedDecimals, decimals);
        assertEq(decodedRestrictionSet, restrictionSet);

        // for backwards compatibility
        bytes memory expectedHexWithoutRestrictionSet =
            hex"040000000000000001811acd5b3f17c06841c7e41e9e04cb1b536f6d65204e616d65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053594d424f4c00000000000000000000000000000000000000000000000000000f";

        (decodedPoolId, decodedTrancheId, decodedTokenName, decodedTokenSymbol, decodedDecimals, decodedRestrictionSet)
        = MessagesLib.parseAddTranche(expectedHexWithoutRestrictionSet);

        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedTokenName, name);
        assertEq(decodedTokenSymbol, symbol);
        assertEq(decodedDecimals, decimals);
        assertEq(decodedRestrictionSet, 0);
    }

    function testAddTrancheEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 decimals,
        uint8 restrictionSet
    ) public {
        bytes memory _message =
            MessagesLib.formatAddTranche(poolId, trancheId, tokenName, tokenSymbol, decimals, restrictionSet);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            string memory decodedTokenName,
            string memory decodedTokenSymbol,
            uint8 decodedDecimals,
            uint8 decodedRestrictionSet
        ) = MessagesLib.parseAddTranche(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        // Comparing raw input to output can erroneously fail when a byte string is given.
        // Intended behaviour is that byte strings will be treated as bytes and converted to strings instead
        // of treated as strings themselves. This conversion from string to bytes32 to string is used to simulate
        // this intended behaviour.
        assertEq(decodedTokenName, MessagesLib._bytes128ToString(MessagesLib._stringToBytes128(tokenName)));
        assertEq(decodedTokenSymbol, MessagesLib._bytes32ToString(MessagesLib._stringToBytes32(tokenSymbol)));
        assertEq(decodedDecimals, decimals);
        assertEq(decodedRestrictionSet, restrictionSet);
    }

    function testUpdateTrancheTokenPrice() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        uint128 currencyId = 2;
        uint128 price = 1_000_000_000_000_000_000_000_000_000;
        uint64 computedAt = uint64(block.timestamp);
        bytes memory expectedHex =
            hex"050000000000000001811acd5b3f17c06841c7e41e9e04cb1b0000000000000000000000000000000200000000033b2e3c9fd0803ce80000000000000000000001";

        assertEq(
            MessagesLib.formatUpdateTrancheTokenPrice(poolId, trancheId, currencyId, price, computedAt), expectedHex
        );

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            uint128 decodedCurrencyId,
            uint128 decodedPrice,
            uint64 decodedComputedAt
        ) = MessagesLib.parseUpdateTrancheTokenPrice(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedCurrencyId, currencyId);
        assertEq(decodedPrice, price);
        assertEq(decodedComputedAt, computedAt);
    }

    function testUpdateTrancheTokenPriceEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        uint128 currencyId,
        uint128 price,
        uint64 computedAt
    ) public {
        bytes memory _message =
            MessagesLib.formatUpdateTrancheTokenPrice(poolId, trancheId, currencyId, price, computedAt);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            uint128 decodedCurrencyId,
            uint128 decodedPrice,
            uint64 decodedComputedAt
        ) = MessagesLib.parseUpdateTrancheTokenPrice(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedCurrencyId, currencyId);
        assertEq(uint256(decodedPrice), uint256(price));
        assertEq(decodedComputedAt, computedAt);
    }

    // Note: UpdateMember encodes differently in Solidity compared to the Rust counterpart because `user` is a 20-byte
    // value in Solidity while it is 32-byte in Rust. However, UpdateMember messages coming from the cent-chain will
    // be handled correctly as the last 12 bytes out of said 32 will be ignored.
    function testUpdateMember() public {
        uint64 poolId = 2;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 member = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint64 validUntil = 1706260138;
        bytes memory expectedHex =
            hex"060000000000000002811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000065b376aa";

        assertEq(MessagesLib.formatUpdateMember(poolId, trancheId, member, validUntil), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedMember, uint64 decodedValidUntil) =
            MessagesLib.parseUpdateMember(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedMember, address(bytes20(member)));
        assertEq(decodedValidUntil, validUntil);
    }

    function testUpdateMemberEquivalence(uint64 poolId, bytes16 trancheId, address user, uint64 validUntil) public {
        bytes memory _message = MessagesLib.formatUpdateMember(poolId, trancheId, user, validUntil);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedUser, uint64 decodedValidUntil) =
            MessagesLib.parseUpdateMember(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedUser, user);
        assertEq(uint256(decodedValidUntil), uint256(validUntil));
    }

    function testTransfer() public {
        uint64 currency = 246803579;
        bytes32 sender = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        address receiver = 0x1231231231231231231231231231231231231231;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"070000000000000000000000000eb5ec7b45645645645645645645645645645645645645645645645645645645645645641231231231231231231231231231231231231231000000000000000000000000000000000052b7d2dcc80cd2e4000000";

        assertEq(MessagesLib.formatTransfer(currency, sender, bytes32(bytes20(receiver)), amount), expectedHex);

        (uint128 decodedCurrency, bytes32 decodedSender, bytes32 decodedReceiver, uint128 decodedAmount) =
            MessagesLib.parseTransfer(expectedHex);
        assertEq(uint256(decodedCurrency), currency);
        assertEq(decodedSender, sender);
        assertEq(decodedReceiver, bytes32(bytes20(receiver)));
        assertEq(decodedAmount, amount);

        // Test the optimised `parseIncomingTransfer` now
        (uint128 decodedCurrency2, address decodedReceiver2, uint128 decodedAmount2) =
            MessagesLib.parseIncomingTransfer(expectedHex);
        assertEq(uint256(decodedCurrency2), currency);
        assertEq(decodedReceiver2, receiver);
        assertEq(decodedAmount2, amount);
    }

    function testTransferEquivalence(uint128 token, bytes32 sender, bytes32 receiver, uint128 amount) public {
        bytes memory _message = MessagesLib.formatTransfer(token, sender, receiver, amount);
        (uint128 decodedToken, bytes32 decodedSender, bytes32 decodedReceiver, uint128 decodedAmount) =
            MessagesLib.parseTransfer(_message);
        assertEq(uint256(decodedToken), uint256(token));
        assertEq(decodedSender, sender);
        assertEq(decodedReceiver, receiver);
        assertEq(decodedAmount, amount);

        // Test the optimised `parseIncomingTransfer` now
        (uint128 decodedToken2, address decodedRecipient2, uint128 decodedAmount2) =
            MessagesLib.parseIncomingTransfer(_message);
        assertEq(uint256(decodedToken2), uint256(decodedToken));
        assertEq(decodedRecipient2, address(bytes20(decodedReceiver)));
        assertEq(decodedAmount, decodedAmount2);
    }

    function testTransferTrancheTokensToEvm() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 sender = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        bytes9 domain = MessagesLib.formatDomain(MessagesLib.Domain.EVM, 1284);
        address receiver = 0x1231231231231231231231231231231231231231;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"080000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640100000000000005041231231231231231231231231231231231231231000000000000000000000000000000000052b7d2dcc80cd2e4000000";

        assertEq(
            MessagesLib.formatTransferTrancheTokens(poolId, trancheId, sender, domain, receiver, amount), expectedHex
        );

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedReceiver, uint128 decodedAmount) =
            MessagesLib.parseTransferTrancheTokens20(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedReceiver, receiver);
        assertEq(decodedAmount, amount);
    }

    function testTransferTrancheTokensToEvmEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 sender,
        uint64 destinationChainId,
        address destinationAddress,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatTransferTrancheTokens(
            poolId,
            trancheId,
            sender,
            MessagesLib.formatDomain(MessagesLib.Domain.EVM, destinationChainId),
            destinationAddress,
            amount
        );

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedDestinationAddress, uint256 decodedAmount) =
            MessagesLib.parseTransferTrancheTokens20(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedDestinationAddress, destinationAddress);
        assertEq(decodedAmount, amount);
    }

    function testIncreaseInvestOrder() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"090000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e4000000";

        assertEq(MessagesLib.formatIncreaseInvestOrder(poolId, trancheId, investor, currency, amount), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedAmount
        ) = MessagesLib.parseIncreaseInvestOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
        assertEq(decodedAmount, amount);
    }

    function testIncreaseInvestOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 token,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatIncreaseInvestOrder(poolId, trancheId, investor, token, amount);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedToken,
            uint128 decodedAmount
        ) = MessagesLib.parseIncreaseInvestOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedToken, token);
        assertEq(decodedAmount, amount);
    }

    function testDecreaseInvestOrder() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"0a0000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e4000000";

        assertEq(MessagesLib.formatDecreaseInvestOrder(poolId, trancheId, investor, currency, amount), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedAmount
        ) = MessagesLib.parseDecreaseInvestOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
        assertEq(decodedAmount, amount);
    }

    function testDecreaseInvestOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 token,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatDecreaseInvestOrder(poolId, trancheId, investor, token, amount);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedToken,
            uint128 decodedAmount
        ) = MessagesLib.parseDecreaseInvestOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedToken, token);
        assertEq(decodedAmount, amount);
    }

    function testIncreaseRedeemOrder() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"0b0000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e4000000";

        assertEq(MessagesLib.formatIncreaseRedeemOrder(poolId, trancheId, investor, currency, amount), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedAmount
        ) = MessagesLib.parseIncreaseRedeemOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
        assertEq(decodedAmount, amount);
    }

    function testIncreaseRedeemOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 token,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatIncreaseRedeemOrder(poolId, trancheId, investor, token, amount);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedToken,
            uint128 decodedAmount
        ) = MessagesLib.parseIncreaseRedeemOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedToken, token);
        assertEq(decodedAmount, amount);
    }

    function testDecreaseRedeemOrder() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"0c0000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e4000000";

        assertEq(MessagesLib.formatDecreaseRedeemOrder(poolId, trancheId, investor, currency, amount), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedAmount
        ) = MessagesLib.parseDecreaseRedeemOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
        assertEq(decodedAmount, amount);
    }

    function testDecreaseRedeemOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 token,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatDecreaseRedeemOrder(poolId, trancheId, investor, token, amount);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            bytes32 decodedInvestor,
            uint128 decodedToken,
            uint128 decodedAmount
        ) = MessagesLib.parseDecreaseRedeemOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedToken, token);
        assertEq(decodedAmount, amount);
    }

    function testCollectInvest() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;

        bytes memory expectedHex =
            hex"0d0000000000000001811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatCollectInvest(poolId, trancheId, investor, currency), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, bytes32 decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCollectInvest(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
    }

    function testCollectInvestEquivalence(uint64 poolId, bytes16 trancheId, bytes32 user, uint128 currency) public {
        bytes memory _message = MessagesLib.formatCollectInvest(poolId, trancheId, user, currency);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, bytes32 decodedUser, uint128 decodedCurrency) =
            MessagesLib.parseCollectInvest(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedUser, user);
        assertEq(decodedCurrency, currency);
    }

    function testCollectRedeem() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x4564564564564564564564564564564564564564564564564564564564564564);
        uint128 currency = 246803579;

        bytes memory expectedHex =
            hex"0e0000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b45645645645645645645645645645645645645645645645645645645645645640000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatCollectRedeem(poolId, trancheId, investor, currency), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, bytes32 decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCollectRedeem(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
        assertEq(decodedCurrency, currency);
    }

    function testCollectRedeemEquivalence(uint64 poolId, bytes16 trancheId, bytes32 user, uint128 currency) public {
        bytes memory _message = MessagesLib.formatCollectRedeem(poolId, trancheId, user, currency);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, bytes32 decodedUser, uint128 decodedCurrency) =
            MessagesLib.parseCollectRedeem(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedUser, user);
        assertEq(decodedCurrency, currency);
    }

    function testExecutedDecreaseInvestOrder() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        uint128 currencyPayout = 50000000000000000000000000;
        uint128 remainingInvestOrder = 5000000000000000000000000;
        bytes memory expectedHex =
            hex"0f0000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b0000000000295be96e6406697200000000000000000422ca8b0a00a425000000";

        assertEq(
            MessagesLib.formatExecutedDecreaseInvestOrder(
                poolId, trancheId, investor, currency, currencyPayout, remainingInvestOrder
            ),
            expectedHex
        );

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedCurrencyPayout,
            uint128 decodedRemainingInvestOrder
        ) = MessagesLib.parseExecutedDecreaseInvestOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
        assertEq(decodedCurrencyPayout, currencyPayout);
        assertEq(decodedRemainingInvestOrder, remainingInvestOrder);
    }

    function testExecutedDecreaseInvestOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency,
        uint128 currencyPayout,
        uint128 remainingInvestOrder
    ) public {
        bytes memory _message = MessagesLib.formatExecutedDecreaseInvestOrder(
            poolId, trancheId, investor, currency, currencyPayout, remainingInvestOrder
        );
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedCurrencyPayout,
            uint128 decodedRemainingInvestOrder
        ) = MessagesLib.parseExecutedDecreaseInvestOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
        assertEq(decodedCurrencyPayout, currencyPayout);
        assertEq(decodedRemainingInvestOrder, remainingInvestOrder);
    }

    function testExecutedDecreaseRedeemOrder() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        uint128 currencyPayout = 50000000000000000000000000;
        uint128 remainingRedeemOrder = 5000000000000000000000000;

        bytes memory expectedHex =
            hex"100000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b0000000000295be96e6406697200000000000000000422ca8b0a00a425000000";

        assertEq(
            MessagesLib.formatExecutedDecreaseRedeemOrder(
                poolId, trancheId, investor, currency, currencyPayout, remainingRedeemOrder
            ),
            expectedHex
        );

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedCurrencyPayout,
            uint128 decodedRemainingRedeemOrder
        ) = MessagesLib.parseExecutedDecreaseRedeemOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(bytes32(bytes20(decodedInvestor)), investor);
        assertEq(decodedCurrency, currency);
        assertEq(decodedCurrencyPayout, currencyPayout);
        assertEq(decodedRemainingRedeemOrder, remainingRedeemOrder);
    }

    function testExecutedDecreaseRedeemOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency,
        uint128 currencyPayout,
        uint128 remainingRedeemOrder
    ) public {
        bytes memory _message = MessagesLib.formatExecutedDecreaseRedeemOrder(
            poolId, trancheId, investor, currency, currencyPayout, remainingRedeemOrder
        );
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedCurrencyPayout,
            uint128 decodedRemainingRedeemOrder
        ) = MessagesLib.parseExecutedDecreaseRedeemOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
        assertEq(decodedCurrencyPayout, currencyPayout);
        assertEq(decodedRemainingRedeemOrder, remainingRedeemOrder);
    }

    function testExecutedCollectInvest() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        uint128 currencyPayout = 100000000000000000000000000;
        uint128 trancheTokensPayout = 50000000000000000000000000;
        uint128 remainingInvestOrder = 5000000000000000000000000;

        bytes memory expectedHex =
            hex"110000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e40000000000000000295be96e6406697200000000000000000422ca8b0a00a425000000";

        assertEq(
            MessagesLib.formatExecutedCollectInvest(
                poolId, trancheId, investor, currency, currencyPayout, trancheTokensPayout, remainingInvestOrder
            ),
            expectedHex
        );
        // separate asserts into two functions to avoid stack too deep error
        testParseExecutedCollectInvestPart1(expectedHex, poolId, trancheId, investor, currency);
        testParseExecutedCollectInvestPart2(expectedHex, currencyPayout, trancheTokensPayout, remainingInvestOrder);
    }

    function testParseExecutedCollectInvestPart1(
        bytes memory expectedHex,
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency
    ) internal {
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency,,,) =
            MessagesLib.parseExecutedCollectInvest(expectedHex);

        assertEq(decodedPoolId, poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testParseExecutedCollectInvestPart2(
        bytes memory expectedHex,
        uint128 currencyPayout,
        uint128 trancheTokensPayout,
        uint128 remainingInvestOrder
    ) internal {
        (,,,, uint128 decodedcurrencyPayout, uint128 decodedTrancheTokensPayout, uint128 decodedRemainingInvestOrder) =
            MessagesLib.parseExecutedCollectInvest(expectedHex);

        assertEq(decodedcurrencyPayout, currencyPayout);
        assertEq(decodedTrancheTokensPayout, trancheTokensPayout);
        assertEq(decodedRemainingInvestOrder, remainingInvestOrder);
    }

    function testExecutedCollectInvestEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency,
        uint128 currencyPayout,
        uint128 trancheTokensPayout,
        uint128 remainingInvestOrder
    ) public {
        bytes memory _message = MessagesLib.formatExecutedCollectInvest(
            poolId, trancheId, investor, currency, currencyPayout, trancheTokensPayout, remainingInvestOrder
        );
        // separate asserts into two functions to avoid stack too deep error
        testParseExecutedCollectInvestPart1(_message, poolId, trancheId, investor, currency);
        testParseExecutedCollectInvestPart2(_message, currencyPayout, trancheTokensPayout, remainingInvestOrder);
    }

    function testExecutedCollectRedeem() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        uint128 currencyPayout = 100000000000000000000000000;
        uint128 trancheTokensPayout = 50000000000000000000000000;
        uint128 remainingRedeemOrder = 5000000000000000000000000;

        bytes memory expectedHex =
            hex"120000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e40000000000000000295be96e6406697200000000000000000422ca8b0a00a425000000";

        assertEq(
            MessagesLib.formatExecutedCollectRedeem(
                poolId, trancheId, investor, currency, currencyPayout, trancheTokensPayout, remainingRedeemOrder
            ),
            expectedHex
        );
        // separate asserts into two functions to avoid stack too deep error
        testParseExecutedCollectRedeemPart1(expectedHex, poolId, trancheId, investor, currency);
        testParseExecutedCollectRedeemPart2(expectedHex, currencyPayout, trancheTokensPayout, remainingRedeemOrder);
    }

    function testExecutedCollectRedeemEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency,
        uint128 currencyPayout,
        uint128 trancheTokensPayout,
        uint128 remainingRedeemOrder
    ) public {
        bytes memory _message = MessagesLib.formatExecutedCollectRedeem(
            poolId, trancheId, investor, currency, currencyPayout, trancheTokensPayout, remainingRedeemOrder
        );
        // separate asserts into two functions to avoid stack too deep error
        testParseExecutedCollectRedeemPart1(_message, poolId, trancheId, investor, currency);
        testParseExecutedCollectRedeemPart2(_message, currencyPayout, trancheTokensPayout, remainingRedeemOrder);
    }

    function testParseExecutedCollectRedeemPart1(
        bytes memory expectedHex,
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 currency
    ) internal {
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency,,,) =
            MessagesLib.parseExecutedCollectRedeem(expectedHex);

        assertEq(decodedPoolId, poolId);
        assertEq(decodedTrancheId, trancheId);

        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testParseExecutedCollectRedeemPart2(
        bytes memory expectedHex,
        uint128 currencyPayout,
        uint128 trancheTokensPayout,
        uint128 remainingRedeemOrder
    ) internal {
        (,,,, uint128 decodedCurrencyPayout, uint128 decodedtrancheTokensPayout, uint128 decodedRemainingRedeemOrder) =
            MessagesLib.parseExecutedCollectRedeem(expectedHex);

        assertEq(decodedCurrencyPayout, currencyPayout);
        assertEq(decodedtrancheTokensPayout, trancheTokensPayout);
        assertEq(decodedRemainingRedeemOrder, remainingRedeemOrder);
    }

    function testUpdateTrancheTokenMetadata() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        string memory name = "Some Name";
        string memory symbol = "SYMBOL";
        bytes memory expectedHex =
            hex"170000000000000001811acd5b3f17c06841c7e41e9e04cb1b536f6d65204e616d65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053594d424f4c0000000000000000000000000000000000000000000000000000";

        assertEq(MessagesLib.formatUpdateTrancheTokenMetadata(poolId, trancheId, name, symbol), expectedHex);

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            string memory decodedTokenName,
            string memory decodedTokenSymbol
        ) = MessagesLib.parseUpdateTrancheTokenMetadata(expectedHex);

        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedTokenName, name);
        assertEq(decodedTokenSymbol, symbol);
    }

    function testUpdateTrancheTokenMetadataEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        bytes memory _message = MessagesLib.formatUpdateTrancheTokenMetadata(poolId, trancheId, tokenName, tokenSymbol);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            string memory decodedTokenName,
            string memory decodedTokenSymbol
        ) = MessagesLib.parseUpdateTrancheTokenMetadata(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        // Comparing raw input to output can erroneously fail when a byte string is given.
        // Intended behaviour is that byte strings will be treated as bytes and converted to strings instead
        // of treated as strings themselves. This conversion from string to bytes32 to string is used to simulate
        // this intended behaviour.
        assertEq(decodedTokenName, MessagesLib._bytes128ToString(MessagesLib._stringToBytes128(tokenName)));
        assertEq(decodedTokenSymbol, MessagesLib._bytes32ToString(MessagesLib._stringToBytes32(tokenSymbol)));
    }

    function testCancelInvestOrder() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        bytes memory expectedHex =
            hex"130000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatCancelInvestOrder(poolId, trancheId, investor, currency), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCancelInvestOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testCancelInvestOrderEquivalence(uint64 poolId, bytes16 trancheId, bytes32 investor, uint128 currency)
        public
    {
        bytes memory _message = MessagesLib.formatCancelInvestOrder(poolId, trancheId, investor, currency);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCancelInvestOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testCancelRedeemOrder() public {
        uint64 poolId = 12378532;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        bytes memory expectedHex =
            hex"140000000000bce1a4811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatCancelRedeemOrder(poolId, trancheId, investor, currency), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCancelRedeemOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testCancelRedeemOrderEquivalence(uint64 poolId, bytes16 trancheId, bytes32 investor, uint128 currency)
        public
    {
        bytes memory _message = MessagesLib.formatCancelRedeemOrder(poolId, trancheId, investor, currency);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor, uint128 decodedCurrency) =
            MessagesLib.parseCancelRedeemOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
    }

    function testTriggerIncreaseRedeemOrder() public {
        uint64 poolId = 1;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        bytes32 investor = bytes32(0x1231231231231231231231231231231231231231000000000000000000000000);
        uint128 currency = 246803579;
        uint128 amount = 100000000000000000000000000;
        bytes memory expectedHex =
            hex"1b0000000000000001811acd5b3f17c06841c7e41e9e04cb1b12312312312312312312312312312312312312310000000000000000000000000000000000000000000000000eb5ec7b000000000052b7d2dcc80cd2e4000000";

        assertEq(
            MessagesLib.formatTriggerIncreaseRedeemOrder(poolId, trancheId, investor, currency, amount), expectedHex
        );

        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedCurrency,
            uint128 decodedAmount
        ) = MessagesLib.parseTriggerIncreaseRedeemOrder(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedCurrency, currency);
        assertEq(decodedAmount, amount);
    }

    function testTriggerIncreaseRedeemOrderEquivalence(
        uint64 poolId,
        bytes16 trancheId,
        bytes32 investor,
        uint128 token,
        uint128 amount
    ) public {
        bytes memory _message = MessagesLib.formatTriggerIncreaseRedeemOrder(poolId, trancheId, investor, token, amount);
        (
            uint64 decodedPoolId,
            bytes16 decodedTrancheId,
            address decodedInvestor,
            uint128 decodedToken,
            uint128 decodedAmount
        ) = MessagesLib.parseTriggerIncreaseRedeemOrder(_message);

        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, address(bytes20(investor)));
        assertEq(decodedToken, token);
        assertEq(decodedAmount, amount);
    }

    function testFreeze() public {
        uint64 poolId = 2;
        bytes16 trancheId = bytes16(hex"811acd5b3f17c06841c7e41e9e04cb1b");
        address investor = 0x1231231231231231231231231231231231231231;
        bytes memory expectedHex =
            hex"190000000000000002811acd5b3f17c06841c7e41e9e04cb1b1231231231231231231231231231231231231231000000000000000000000000";

        assertEq(MessagesLib.formatFreeze(poolId, trancheId, investor), expectedHex);

        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedInvestor) = MessagesLib.parseFreeze(expectedHex);
        assertEq(uint256(decodedPoolId), poolId);
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedInvestor, investor);
    }

    function testFreezeEquivalence(uint64 poolId, bytes16 trancheId, address user) public {
        bytes memory _message = MessagesLib.formatFreeze(poolId, trancheId, user);
        (uint64 decodedPoolId, bytes16 decodedTrancheId, address decodedUser) = MessagesLib.parseFreeze(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedTrancheId, trancheId);
        assertEq(decodedUser, user);
    }

    function testDisallowInvestmentCurrency() public {
        uint64 poolId = 12378532;
        uint128 currency = 246803579;
        bytes memory expectedHex = hex"180000000000bce1a40000000000000000000000000eb5ec7b";

        assertEq(MessagesLib.formatDisallowInvestmentCurrency(poolId, currency), expectedHex);

        (uint64 decodedPoolId, uint128 decodedCurrency) = MessagesLib.parseDisallowInvestmentCurrency(expectedHex);
        assertEq(decodedPoolId, poolId);
        assertEq(uint256(decodedCurrency), currency);
    }

    function testDisallowInvestmentCurrencyEquivalence(uint128 currency, uint64 poolId) public {
        bytes memory _message = MessagesLib.formatDisallowInvestmentCurrency(poolId, currency);
        (uint64 decodedPoolId, uint128 decodedCurrency) = MessagesLib.parseDisallowInvestmentCurrency(_message);
        assertEq(uint256(decodedPoolId), uint256(poolId));
        assertEq(decodedCurrency, uint256(currency));
    }

    function testFormatDomainCentrifuge() public {
        assertEq(MessagesLib.formatDomain(MessagesLib.Domain.Centrifuge), hex"000000000000000000");
    }

    function testFormatDomainMoonbeam() public {
        assertEq(MessagesLib.formatDomain(MessagesLib.Domain.EVM, 1284), hex"010000000000000504");
    }

    function testFormatDomainMoonbaseAlpha() public {
        assertEq(MessagesLib.formatDomain(MessagesLib.Domain.EVM, 1287), hex"010000000000000507");
    }

    function testFormatDomainAvalanche() public {
        assertEq(MessagesLib.formatDomain(MessagesLib.Domain.EVM, 43114), hex"01000000000000a86a");
    }
}