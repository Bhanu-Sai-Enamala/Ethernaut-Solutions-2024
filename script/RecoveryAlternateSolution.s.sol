// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SimpleToken} from "../src/Recovery.sol";
import "../lib/forge-std/src/Script.sol";

// Script to recover Ether from a destroyed contract using the SimpleToken contract
contract RecoveryScript is Script {
    
    // Replace this with the actual deployed SimpleToken contract address (the contract from which Ether is being recovered)
    SimpleToken recoveryInstance = SimpleToken(payable(0xYourContractAddressHere));
    
    // Replace this with your player address (where the recovered Ether will be sent)
    address payable playerAddress = payable(0xYourPlayerAddressHere);

    function run() external {
        // Start broadcasting using the private key (retrieved from the .env file)
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Call the destroy function on the SimpleToken contract, sending the Ether to the player address
        recoveryInstance.destroy(playerAddress);

        // Stop broadcasting after the transaction is executed
        vm.stopBroadcast();
    }
}


    /*
    Explanation of Recovery Script:

    **How to Get the Contract Address from Etherscan**:
       - First, visit [Etherscan](https://etherscan.io/) and locate the **deployer address** or **transaction hash** that created the SimpleToken contract. You can find this information under internal transactions for the deployer.
       - When viewing the deployer's transactions, look for the event where a contract was created. This will show the contract's address, which is the target of the recovery process.
       - Once you have the contract's address, replace `0xYourContractAddressHere` with this address in the script.
    */