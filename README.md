# 💰 FundMe -- Decentralized ETH Crowdfunding Contract

> A production-style crowdfunding smart contract built using
> **Solidity + Foundry**, powered by **Chainlink Price Feeds** to
> enforce a USD minimum contribution.

------------------------------------------------------------------------

## 🚀 Project Overview

FundMe is a decentralized crowdfunding smart contract that:

-   Accepts ETH contributions
-   Enforces a minimum \$5 USD funding requirement
-   Uses Chainlink ETH/USD price feeds for real-time price conversion
-   Allows only the contract owner to withdraw funds
-   Includes gas-optimized withdrawal logic
-   Supports multi-network deployment (Mainnet, Sepolia, Anvil)

------------------------------------------------------------------------

# 🏗 Architecture Overview

    User (ETH)
        │
        ▼
    FundMe.sol
        │
        ├── PriceConverter Library
        │       │
        │       ▼
        │   Chainlink ETH/USD Price Feed
        │
        ▼
    Owner withdraws ETH

------------------------------------------------------------------------

# 🔎 How It Works

## 1️⃣ Funding Flow

When a user sends ETH:

1.  `fund()` is triggered
2.  ETH amount is converted to USD using Chainlink
3.  If USD value ≥ \$5 → transaction succeeds
4.  User address & amount are stored

### Conversion Formula

    USD Value = (ETH Price × ETH Amount) / 1e18

Why division by `1e18`?\
Because Solidity uses 18-decimal fixed-point math.

------------------------------------------------------------------------

## 2️⃣ Withdrawal Flow

Only the owner can withdraw funds:

-   `withdraw()`
-   `cheaperWithdraw()` (gas optimized)

### Why `cheaperWithdraw()` saves gas

-   Stores array length in memory
-   Uses local variables instead of repeated storage reads
-   Minimizes SLOAD operations

------------------------------------------------------------------------

# 📄 Contracts Breakdown

## FundMe.sol

Core crowdfunding contract.

### Features

-   `fund()` → Accept ETH if ≥ \$5
-   `withdraw()` → Owner withdraws funds
-   `cheaperWithdraw()` → Gas optimized withdrawal
-   `fallback()` / `receive()` → Automatically routes ETH to `fund()`
-   Getter functions for transparency

### Security Design

-   Immutable owner
-   Custom error (`FundMe__NotOwner`)
-   Minimum USD enforcement
-   Uses `.call()` instead of `transfer()`

------------------------------------------------------------------------

## PriceConverter.sol

Library used for ETH → USD conversion.

### Constants

    uint256 internal constant PRECISION = 1e18;
    uint256 internal constant ADDITIONAL_FEED_PRECISION = 1e10;

### Why Library?

-   Reusable
-   No separate deployment required
-   Keeps FundMe contract clean

------------------------------------------------------------------------

## HelperConfig.s.sol

Network configuration helper.

Automatically selects correct price feed for:

-   Ethereum Mainnet
-   Sepolia Testnet
-   Local Anvil (deploys mock price feed)

------------------------------------------------------------------------

## DeployFundMe.s.sol

Deployment script that:

-   Fetches correct price feed
-   Broadcasts deployment transaction
-   Returns deployed contract instance

------------------------------------------------------------------------

## Interactions.s.sol

Script utilities to:

-   Fund the contract
-   Withdraw from the contract

Uses DevOpsTools to fetch latest deployed contract address.

------------------------------------------------------------------------

# 🛠 Tech Stack

  Tool                Purpose
  ------------------- -----------------------
  Solidity \^0.8.18   Smart Contracts
  Foundry             Development Framework
  Chainlink           Price Feeds
  MockV3Aggregator    Local Testing
  forge-std           Testing Utilities
  DevOpsTools         Deployment Tracking

------------------------------------------------------------------------

# 📦 Installation & Setup

## 1️⃣ Clone Repository

    git clone https://github.com/shoaib-eth/Project_FundMe_F26.git
    cd Project_FundMe_F26

## 2️⃣ Install Dependencies

    forge install

## 3️⃣ Build

    forge build

## 4️⃣ Run Tests

    forge test -vvv

------------------------------------------------------------------------

# 🚀 Deployment

## Deploy to Sepolia

Make sure you configure:

-   RPC URL
-   Private Key
-   Etherscan API Key

Example:

    forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast --verify

Note: Don't paste `PRIVATE_KEY` directly in terminal. Use keystore or environment variables for security.
------------------------------------------------------------------------

# 🧪 Local Testing with Anvil

Start local node:

    anvil

Deploy locally:

    forge script script/DeployFundMe.s.sol:DeployFundMe --broadcast

------------------------------------------------------------------------

# 📊 Example Funding Scenario

Assume:

-   ETH Price = \$2000
-   User sends 0.01 ETH

Calculation:

    USD = 2000 × 0.01 = $20

Since \$20 \> \$5 → Transaction succeeds.

------------------------------------------------------------------------

# 📚 Concepts Demonstrated

-   Solidity immutables
-   Custom errors
-   Libraries
-   Oracle integration
-   Gas optimization
-   Script automation
-   Multi-network configuration
-   Fallback & receive behavior

------------------------------------------------------------------------

# 📜 License

MIT

------------------------------------------------------------------------

# ⭐ Final Thoughts

This project demonstrates how to:

-   Build a real-world ETH crowdfunding contract
-   Integrate Chainlink oracles safely
-   Optimize gas usage
-   Deploy across multiple networks
-   Structure professional-grade Foundry projects

If you found this useful, consider giving it a ⭐ on GitHub!
