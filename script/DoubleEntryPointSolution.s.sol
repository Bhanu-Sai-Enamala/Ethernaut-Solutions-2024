// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/DoubleEntryPoint.sol";  // Import the DET contract interface
import "forge-std/Script.sol";  // Foundry utilities for scripting

// Main script to deploy and register the detection bot to solve the DoubleEntryPoint challenge
contract DoubleEntryPointSolution is Script {

    // Address of the DoubleEntryPoint instance (replace with your deployed instance address)
    address public detInstanceAddress = 0xYourInstanceAddressHere;

    // Extract the Forta contract address from the DoubleEntryPoint instance
    address public fortaContractAddress = address(DoubleEntryPoint(detInstanceAddress).forta());

    DetectionBot public detectionBotInstance;  // Store the deployed detection bot instance

    // Main function to deploy and register the detection bot
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start broadcasting transactions

        //Deploy the DetectionBot and log its address
        detectionBotInstance = new DetectionBot(fortaContractAddress);

        //Register the deployed DetectionBot with the Forta contract
        Forta(fortaContractAddress).setDetectionBot(address(detectionBotInstance));

        vm.stopBroadcast();  // Stop broadcasting transactions
    }
}

// DetectionBot contract to monitor suspicious delegateTransfer calls and raise alerts
contract DetectionBot {

    Forta public fortaInstance;  // Store the Forta contract instance

    // Function selector for the delegateTransfer function
    bytes4 public constant DELEGATE_TRANSFER_SELECTOR = bytes4(keccak256("delegateTransfer(address,uint256,address)"));

    // Constructor to initialize the Forta contract instance
    constructor(address _fortaAddress) {
        fortaInstance = Forta(_fortaAddress);
    }
    
    // Function to handle monitored transactions and raise an alert if a suspicious call is detected
    function handleTransaction(address user, bytes calldata msgData) external {
        // Check if the transaction's function selector matches delegateTransfer's selector
        if (bytes4(msgData) == DELEGATE_TRANSFER_SELECTOR) {
            fortaInstance.raiseAlert(user);  // Raise an alert through the Forta contract
        }
    }
}