# 🔒 Day 1: Time-Locked Vault (30 Days of Solidity & Foundry)

A security-focused, gas-optimized Solidity smart contract that allows users to deposit native ETH and lock it for a custom duration. Users can only withdraw their funds after their specified maturity timestamp has passed.

Built and tested using **Foundry**.

---

## 🚀 Key Features

* **Native ETH Lockup:** Lock native Ethereum with a customizable lockup period in days.
* **Lock Extension:** Subsequent deposits automatically extend existing active lockups safely without resetting or shortening timestamps.
* **Checks-Effects-Interactions (CEI) Pattern:** State is updated before external calls to eliminate **Reentrancy attacks**.
* **Gas-Optimized Custom Errors:** Uses custom error selectors instead of string revert statements (`require`), reducing deployment and execution gas costs.
* **Comprehensive Test Suite:** Unit tested using Foundry cheatcodes (`vm.prank`, `vm.warp`, `vm.deal`, `vm.expectRevert`).

---

## 📐 Smart Contract Architecture

```solidity
struct Vault {
    uint256 amount; // Stored ETH balance in wei
    uint256 time;   // Unlock timestamp (Linux epoch seconds)
}

## 🪙 Day 2 & 3: ERC-20 Custom Token & Token Sale Integration

### Features Added
- Created custom `MyToken` contract inheriting OpenZeppelin `ERC20`.
- Integrated `IERC20` token transfers directly inside `CrowdSale.register()`.
- Added automatic rate calculation (`1 ETH = 1,000 DEVT`).
- Comprehensive unit testing in `test/CrowdSale.t.sol` covering token math, vault balances, and parameterized custom errors (`abi.encodeWithSelector`).
