// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './interfaces/IFactory.sol';

import './PoolDeployer.sol';

import './Pool.sol';
import '@openzeppelin/contracts-upgradeable/proxy/Initializable.sol';

/// @title Canonical   factory
/// @notice Deploys   pools and manages ownership and control over pool protocol fees
contract Factory is Initializable, IFactory, PoolDeployer {
    /// @inheritdoc IFactory
    address public override owner;

    address public PoolImplementation;
    address public PoolImplementationAdmin;

    /// @inheritdoc IFactory
    mapping(uint24 => int24) public override feeAmountTickSpacing;
    /// @inheritdoc IFactory
    mapping(address => mapping(address => mapping(uint24 => address))) public override getPool;

    // Reserve storage space to allow for layout changes in the future.
    uint256[50] private __gap;

    /// @notice Initialize instead of constructor
    function initialize(address _PoolImplementation, address _PoolImplementationAdmin) external initializer {
        PoolImplementation = _PoolImplementation;
        PoolImplementationAdmin = _PoolImplementationAdmin;

        owner = msg.sender;
        emit OwnerChanged(address(0), msg.sender);

        feeAmountTickSpacing[500] = 10;
        emit FeeAmountEnabled(500, 10);
        feeAmountTickSpacing[3000] = 60;
        emit FeeAmountEnabled(3000, 60);
        feeAmountTickSpacing[10000] = 200;
        emit FeeAmountEnabled(10000, 200);
    }

    /// @inheritdoc IFactory
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external override returns (address pool) {
        require(tokenA != tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0));
        int24 tickSpacing = feeAmountTickSpacing[fee];
        require(tickSpacing != 0);
        require(getPool[token0][token1][fee] == address(0));
        pool = deploy(PoolImplementationAdmin, PoolImplementation, address(this), token0, token1, fee, tickSpacing);
        getPool[token0][token1][fee] = pool;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        getPool[token1][token0][fee] = pool;
        emit PoolCreated(token0, token1, fee, tickSpacing, pool);
    }

    /// @inheritdoc IFactory
    function setOwner(address _owner) external override {
        require(msg.sender == owner);
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    function setPoolImplementation(address _PoolImplementation) external {
        require(msg.sender == owner);
        emit ProxyImplementationChanged(PoolImplementation, _PoolImplementation);
        PoolImplementation = _PoolImplementation;
    }

    function setPoolImplementationAdmin(address _admin) external {
        require(msg.sender == owner);
        emit AdminChanged(PoolImplementationAdmin, _admin);
        PoolImplementationAdmin = _admin;
    }

    /// @inheritdoc IFactory
    function enableFeeAmount(uint24 fee, int24 tickSpacing) public override {
        require(msg.sender == owner);
        require(fee < 1000000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that
        // TickBitmap#nextInitializedTickWithinOneWord overflows int24 container from a valid tick
        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(feeAmountTickSpacing[fee] == 0);

        feeAmountTickSpacing[fee] = tickSpacing;
        emit FeeAmountEnabled(fee, tickSpacing);
    }
}
