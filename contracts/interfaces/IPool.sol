// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IPoolImmutables.sol';
import './pool/IPoolState.sol';
import './pool/IPoolDerivedState.sol';
import './pool/IPoolActions.sol';
import './pool/IPoolOwnerActions.sol';
import './pool/IPoolEvents.sol';

/// @title The interface for a Pool
/// @notice A pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IPool is
    IPoolImmutables,
    IPoolState,
    IPoolDerivedState,
    IPoolActions,
    IPoolOwnerActions,
    IPoolEvents
{

}
