<div style="display: flex; flex-direction: row;">
    <img src="https://badgen.net/static/license/MIT/green" style="zoom:130%;" />
    <img src="https://img.shields.io/badge/solidity-v0.8.20-red" style="zoom:130%;" />
    <img src="https://img.shields.io/badge/React-front end-blue" style="zoom:130%;" />
    <img src="https://img.shields.io/badge/last commit-December-orange" style="zoom:130%;" />
</div>

# TPlanet

#### [中文](https://github.com/admi-n/TPlanet/blob/main/README.md) | English

### Project Introduction

Use smart contracts as "middlemen" to build a guarantee system to realize the C2C transaction system.

The Dapp, a guarantee system with absolute trust, is built with smart contracts, and provides stable and secure guarantee services based on blockchain for buyers and sellers through blockchain technology.



### Background of the project

...



## Main function

#### Platform Architecture

```
Front end (React)                                Back end (Solidity)
----------------------------------------------------------------
UserA (seller)       ->    Smart Contracts    <-     UserB (buyer)
CreateTrade              Tradecreation            Locking Funds
confirmShipment   ->     confirmReceipt    ->     ConfirmReceipt
```

#### technical architecture

##### Smart Contract Architecture

C2CPlatform(Main)

<img src="assets/main.png" alt="main"  />

HashLock

<img src="assets/hashlock.png" alt="main" style="zoom: 50%;" />

整体HashLock构架

<img src="assets/detailed_hashlock.png" alt="main" />

#### Flowchart Demo

.....