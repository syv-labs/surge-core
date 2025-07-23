# Surge Core

The core smart contracts for the Surge DEX protocol.

Surge is a decentralized exchange protocol offering concentrated liquidity, efficient on-chain pricing via TWAP oracles, and fully upgradeable pools. This repository contains the core contracts for the Surge protocol, including the core pool logic, math libraries, and interfaces.

## Packages

This repository contains the logic for Surge protocol, including:

- `Pool.sol` — The core contract responsible for swaps and liquidity.
- `Factory.sol` — Deploys and tracks pools by token pair and fee tier.
- `TickMath.sol`, `FullMath.sol`, `FixedPoint128.sol, SqrtPriceMath.sol` — Precise math libraries for calculations in Surge pools.
- `IPool`, `IFactory` — Pool and factory interfaces.

---

## Features

- **Concentrated Liquidity**: LPs can define custom price ranges to provide liquidity more efficiently.
- **Time-Weighted Average Price (TWAP)** Oracle: Reliable, decentralized pricing with on-chain data.
- **Upgradeable Architecture**: Pools and core contracts are proxy-based and can be upgraded in future protocol phases.
- **Multiple Fee Tiers**: Deploy multiple pools for the same token pair with different fees.

---

## Contracts Overview

| Contract        | Description                                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `Pool`          | Main contract for handling token swaps and liquidity positions.                                                         |
| `Factory`       | Deploys and manages all SurgePools for different token pairs.                                                           |
| `PoolDeployer`  | Deploys a pool with the given parameters                                                                                |
| `TickMath`      | Provides utilities for converting ticks to price and vice versa.                                                        |
| `SqrtPriceMath` | Providing precise mathematical functions for handling price movement, liquidity, and token amount calculations. |

---

## Documentation

You can find complete documentation at:

[Surge Docs](https://app.surgedefi.com/#/docs)

---

## Local Development

To install dependencies and run the local build:

```bash
git clone https://github.com/syv-labs/surge-core.git
cd surge-core
yarn install
npx hardhat compile
```

## Testing

Surge uses hardhat for testing.
To run Hardhat tests:

```bash
npx hardhat test
```
