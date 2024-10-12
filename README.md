# Ethernaut Challenge Solutions with Foundry

This repository contains solutions to the Ethernaut challenges, implemented using Foundry.

---

# Setting Up for Ethernaut Challenges

## 1. Create a MetaMask Wallet and Get Sepolia Test ETH

1. Download and install [MetaMask](https://metamask.io/).
2. After installation, follow the instructions to **create a new wallet**.
   - Save your seed phrase in a safe place (do not share it with anyone).
   - Set a strong password for your wallet.
3. Once your wallet is set up, switch your network to **Sepolia Test Network**.
   - Click on the network dropdown at the top of MetaMask and select **Sepolia** from the list. If it doesn’t appear, click **Add Network** and enter Sepolia's details.
4. To get Sepolia testnet ETH, visit this ([Sepolia faucet link](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)).
   - Paste your MetaMask address and request some test ETH.
   - You should receive test ETH in your wallet after a short while.

---

## 2. Create an Infura Account and Get a Free RPC URL

1. Go to [Infura](https://infura.io/).
2. Click on **Sign Up** and create an account.
3. After signing in, create a new project:
   - Go to the **Dashboard**.
   - Click **Create New Project** and give your project a name.
4. Once the project is created, click on the project name to view details.
   - Copy the **Sepolia RPC URL** from the project settings. It will look something like this:
     ```
     https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
     ```
5. Save this RPC URL. You'll need it for connecting to the Sepolia network in scripts and MetaMask.

---

## 3. Clone the Git Repository

First, clone the repository that contains the Ethernaut challenge solutions by running the following command in your terminal:

```bash
git clone <your-git-repository-link-here>
```

---

## 4. Installing Foundry

Follow these steps to install Foundry on your machine:

1. **Install Foundry**:

   Open your terminal and run the following command to install Foundry:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   ```
2. **Initialize Foundry**:

    After the installation is complete, run:

    ```bash
    foundryup
    ```
    This will install the latest version of forge and cast, the core components of Foundry

3. **Verify Installation**

    Check that Foundry is successfully installed by verifying the forge version:

    ```bash
    forge --version
    ```

    You should see the installed version of Foundry, confirming that it has been successfully installed.
    Foundry is now installed and ready to use!

---

## 5. Setting Up Environment Variables

You need to create a `.env` file in the root directory of the project to store your Ethereum RPC URL and private key. This file will allow the script to interact with the Ethereum network.

    1. Create a file named `.env` in the root directory of the project.
    2. Open the .env file and add the following content

          RPC_URL=https://sepolia.infura.io/v3/your-infura-project-id
          PRIVATE_KEY=your-private-key
          
    3. Replace your-infura-project-id with the project ID from your Infura account (or other provider).Replace your-private-key with the private key of the Ethereum account you want to use for deploying/interacting with contracts.
    4. Save the .env file. This file should now securely store your environment variables for the script to use.
    5. Before running any script, load the .env variables into your shell session with:
   
        source .env
    
    6. Your environment variables are now set up and loaded, ready to interact with the Ethereum network.

## 6. Connect Your Wallet and Get an Instance from Ethernaut

1. Visit the [Ethernaut website](https://ethernaut.openzeppelin.com/).
2. In the top right corner, click on **Connect Wallet** and select MetaMask.
3. MetaMask will prompt you to approve the connection. Approve the connection to allow Ethernaut to interact with your wallet.
4. Once connected, go to the specific challenge you want to solve, such as **Fallback**.
5. Click **Get New Instance** to generate an instance of the smart contract. Ethernaut will deploy a contract to the testnet and give you the instance address.
6. Copy the instance address and use it in your scripts or solutions as required.
7. Open the solution script (e.g., `FallbackSolution.s.sol`).Find the line where the instance address is required, and replace the placeholder with your copied instance address:

   ```solidity
   address fallbackInstanceAddress = 0xYourInstanceAddressHere;
   ```
   
8. Once the instance address is updated in the script, run the script using the following command:

    ```bash
    forge script script/<filename> --rpc-url $RPC_URL --broadcast
    ```

***Ensure that:***

	•	Your .env file is correctly configured and loaded.
	•	You have sufficient testnet ETH in your wallet for transactions.

---