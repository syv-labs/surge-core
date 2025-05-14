// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './interfaces/IPoolDeployer.sol';

import './Pool.sol';

import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

contract PoolDeployer is IPoolDeployer {
    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }

    /// @inheritdoc IPoolDeployer
    Parameters public override parameters;

    /// @dev Deploys a pool with the given parameters by transiently setting the parameters storage slot and then
    /// clearing it after deploying the pool.
    /// @param factory The contract address of the factory
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The spacing between usable ticks
    function deploy(
        address proxyAdmin,
        address poolImplementationAddress,
        address factory,
        address token0,
        address token1,
        uint24 fee,
        int24 tickSpacing
    ) internal returns (address pool) {
        pool = address(new TransparentUpgradeableProxy{salt: keccak256(abi.encode(token0, token1, fee))}(
            poolImplementationAddress,
            proxyAdmin,
            ""
        ));

        Pool(pool).initializePool(factory, token0, token1, fee, tickSpacing);
    }
}
