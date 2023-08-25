// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;

import {PermissionlessRouter} from "test/mock/PermissionlessRouter.sol";
import {InvestmentManager} from "src/InvestmentManager.sol";
import {Deployer} from "./Deployer.sol";

// Script to deploy Liquidity Pools with a permissionless router for testing.
contract PermissionlessScript is Deployer {
    // address(0)[0:20] + keccak("Centrifuge")[21:32]
    bytes32 SALT = 0x000000000000000000000000000000000000000075eb27011b69f002dc094d05;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        admin = msg.sender;

        // Deploy contracts
        deployInvestmentManager();
        PermissionlessRouter router = new PermissionlessRouter();
        wire(address(router));

        // Set up test data
        tokenManager.addCurrency(1, 0xd35CCeEAD182dcee0F148EbaC9447DA2c4D449c4);
        investmentManager.addPool(1171854325);
        investmentManager.addTranche(1171854325, 0x102f4ef817340a8839a515d2c73a7c1d, "Some Token", "ST", 6, 1e27);
        investmentManager.allowPoolCurrency(1171854325, 1);
        investmentManager.deployLiquidityPool(
            1171854325, 0x102f4ef817340a8839a515d2c73a7c1d, 0xd35CCeEAD182dcee0F148EbaC9447DA2c4D449c4
        );
        tokenManager.updateMember(1171854325, 0x102f4ef817340a8839a515d2c73a7c1d, admin, type(uint64).max);

        giveAdminAccess();
        removeDeployerAccess(address(router));

        vm.stopBroadcast();
    }
}
