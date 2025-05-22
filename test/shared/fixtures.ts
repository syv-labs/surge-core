import { BigNumber } from 'ethers'
import { ethers, upgrades } from 'hardhat'
import { MockTimePool } from '../../typechain/MockTimePool'
import { getAdminAddress } from '@openzeppelin/upgrades-core'
import { TestERC20 } from '../../typechain/TestERC20'
import { Factory } from '../../typechain/Factory'
import { TestCallee } from '../../typechain/TestCallee'
import { TestRouter } from '../../typechain/TestRouter'
import { MockTimePoolDeployer } from '../../typechain/MockTimePoolDeployer'
import { encodePriceSqrt } from './utilities'

import { Fixture } from 'ethereum-waffle'

interface FactoryFixture {
  factory: Factory
}

async function factoryFixture(): Promise<FactoryFixture> {
  const factoryFactory = await ethers.getContractFactory('Factory')
    const Pool = await ethers.getContractFactory('Pool')
    const pool = await Pool.deploy()
    const factory = await upgrades.deployProxy(factoryFactory, [pool.address, pool.address], { initializer: 'initialize' }) as Factory
    const proxyAdmin = await getAdminAddress(ethers.provider, factory.address)
    await factory.setPoolImplementationAdmin(proxyAdmin)
    return {factory }
}

interface TokensFixture {
  token0: TestERC20
  token1: TestERC20
  token2: TestERC20
}

async function tokensFixture(): Promise<TokensFixture> {
  const tokenFactory = await ethers.getContractFactory('TestERC20')
  const tokenA = (await tokenFactory.deploy(BigNumber.from(2).pow(255))) as TestERC20
  const tokenB = (await tokenFactory.deploy(BigNumber.from(2).pow(255))) as TestERC20
  const tokenC = (await tokenFactory.deploy(BigNumber.from(2).pow(255))) as TestERC20

  const [token0, token1, token2] = [tokenA, tokenB, tokenC].sort((tokenA, tokenB) =>
    tokenA.address.toLowerCase() < tokenB.address.toLowerCase() ? -1 : 1
  )

  return { token0, token1, token2 }
}

type TokensAndFactoryFixture = FactoryFixture & TokensFixture

interface PoolFixture extends TokensAndFactoryFixture {
  swapTargetCallee: TestCallee
  swapTargetRouter: TestRouter
  createPool(
    fee: number,
    tickSpacing: number,
    firstToken?: TestERC20,
    secondToken?: TestERC20
  ): Promise<MockTimePool>
}

// Monday, October 5, 2020 9:00:00 AM GMT-05:00
export const TEST_POOL_START_TIME = 1601906400

export const poolFixture: Fixture<PoolFixture> = async function (): Promise<PoolFixture> {
  const { factory } = await factoryFixture()
  const { token0, token1, token2 } = await tokensFixture()

  const MockTimePoolDeployerFactory = await ethers.getContractFactory('MockTimePoolDeployer')
  const MockTimePoolFactory = await ethers.getContractFactory('MockTimePool')

  const calleeContractFactory = await ethers.getContractFactory('TestCallee')
  const routerContractFactory = await ethers.getContractFactory('TestRouter')

  const swapTargetCallee = (await calleeContractFactory.deploy()) as TestCallee
  const swapTargetRouter = (await routerContractFactory.deploy()) as TestRouter

  return {
    token0,
    token1,
    token2,
    factory,
    swapTargetCallee,
    swapTargetRouter,
    createPool: async (fee, tickSpacing, firstToken = token0, secondToken = token1) => {
      const mockTimePoolDeployer = (await MockTimePoolDeployerFactory.deploy()) as MockTimePoolDeployer
      const tx = await mockTimePoolDeployer.deploy(
        factory.address,
        firstToken.address,
        secondToken.address,
        fee,
        tickSpacing
      )

      const receipt = await tx.wait()
      const poolAddress = receipt.events?.[0].args?.pool as string
      return MockTimePoolFactory.attach(poolAddress) as MockTimePool
    },
  }
}
