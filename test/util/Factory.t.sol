// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;
pragma abicoder v2;

import {TrancheTokenFactory} from "src/util/Factory.sol";
import {TrancheToken} from "src/token/Tranche.sol";
import {Root} from "src/Root.sol";
import {Escrow} from "src/Escrow.sol";
import "forge-std/Test.sol";

contract FactoryTest is Test {
    uint256 mainnetFork;
    uint256 polygonFork;

    address root;

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        polygonFork = vm.createFork(vm.envString("POLYGON_RPC_URL"));

        root = address(new Root(address(new Escrow()), 48 hours));
    }

    // TODO: re-enable this
    // function testTrancheTokenFactoryIsDeterministicAcrossChains(
    //     bytes32 salt,
    //     address sender,
    //     uint64 poolId,
    //     bytes16 trancheId,
    //     address investmentManager1,
    //     address investmentManager2,
    //     address tokenManager1,
    //     address tokenManager2,
    //     string memory name,
    //     string memory symbol,
    //     uint8 decimals
    // ) public {
    //     vm.assume(sender != address(0));

    //     vm.selectFork(mainnetFork);
    //     TrancheTokenFactory trancheTokenFactory1 = new TrancheTokenFactory{ salt: salt }(root);
    //     address trancheToken1 = trancheTokenFactory1.newTrancheToken(
    //         poolId, trancheId, investmentManager1, tokenManager1, name, symbol, decimals
    //     );

    //     vm.selectFork(polygonFork);
    //     vm.prank(sender);
    //     TrancheTokenFactory trancheTokenFactory2 = new TrancheTokenFactory{ salt: salt }(root);
    //     assertEq(address(trancheTokenFactory1), address(trancheTokenFactory2));
    //     address trancheToken2 = trancheTokenFactory2.newTrancheToken(
    //         poolId, trancheId, investmentManager2, tokenManager2, name, symbol, decimals
    //     );
    //     assertEq(address(trancheToken1), address(trancheToken2));
    // }

    function testTrancheTokenFactoryShouldBeDeterministic(bytes32 salt) public {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(abi.encodePacked(type(TrancheTokenFactory).creationCode, abi.encode(root)))
                        )
                    )
                )
            )
        );
        TrancheTokenFactory trancheTokenFactory = new TrancheTokenFactory{ salt: salt }(root);
        assertEq(address(trancheTokenFactory), predictedAddress);
    }

    function testTrancheTokenShouldBeDeterministic(
        bytes32 salt,
        uint64 poolId,
        bytes16 trancheId,
        address investmentManager,
        address tokenManager,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint128 latestPrice
    ) public {
        TrancheTokenFactory trancheTokenFactory = new TrancheTokenFactory{ salt: salt }(root);

        bytes32 salt = keccak256(abi.encodePacked(poolId, trancheId));
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(trancheTokenFactory),
                            salt,
                            keccak256(abi.encodePacked(type(TrancheToken).creationCode, abi.encode(decimals)))
                        )
                    )
                )
            )
        );

        address token = trancheTokenFactory.newTrancheToken(
            poolId, trancheId, investmentManager, tokenManager, name, symbol, decimals, latestPrice, block.timestamp
        );

        assertEq(address(token), predictedAddress);
    }

    function testDeployingDeterministicAddressTwiceReverts(
        bytes32 salt,
        uint64 poolId,
        bytes16 trancheId,
        address investmentManager,
        address tokenManager,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint128 latestPrice
    ) public {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(abi.encodePacked(type(TrancheTokenFactory).creationCode, abi.encode(root)))
                        )
                    )
                )
            )
        );
        TrancheTokenFactory trancheTokenFactory = new TrancheTokenFactory{ salt: salt }(root);
        assertEq(address(trancheTokenFactory), predictedAddress);
        trancheTokenFactory.newTrancheToken(
            poolId, trancheId, investmentManager, tokenManager, name, symbol, decimals, latestPrice, block.timestamp
        );
        vm.expectRevert();
        trancheTokenFactory.newTrancheToken(
            poolId, trancheId, investmentManager, tokenManager, name, symbol, decimals, latestPrice, block.timestamp
        );
    }
}