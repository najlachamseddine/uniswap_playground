pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV3Liquidity, IERC20, IWETH} from "../src/UniswapV3Liquidity.sol";
import "forge-std/console.sol";


// address constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14; //0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
// address constant DAI = 0x68194a729C2450ad26072b3D33ADaCbcef39D574; //0x6B175474E89094C44Da98b954EedeAC495271d0F;
// address constant USDC = 0xf08A50178dfcDe18524640EA6618a1f965821715; //0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;


address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;



contract UniswapV3LiquidityTest is Test {

    UniswapV3Liquidity uni;
    IWETH weth = IWETH(WETH);
    IERC20 dai = IERC20(DAI);
    address private constant DAI_WHALE = 0xe81D6f03028107A20DBc83176DA82aE8099E9C42;


function setUp() public {
    uni = new UniswapV3Liquidity();
    vm.prank(DAI_WHALE);
    dai.transfer(address(this), 20 * 1e18);

    weth.deposit{value: 2 * 1e18}();

    dai.approve(address(uni), 20 * 1e18);
    weth.approve(address(uni), 2 * 1e18);
}



function testLiquidity() public {

    // Track total liquidity
    uint128 liquidity;

    // Mint new position
    uint256 daiAmount = 10 * 1e18;
    uint256 wethAmount = 1e18;

    (uint256 tokenId, uint128 liquidityDelta, uint256 amount0, uint256 amount1) = uni.mintNewPosition(daiAmount, wethAmount);

    liquidity += liquidityDelta;

    console2.log("-------Mint new position-------");
    console2.log("tokenId", tokenId);
    console2.log("liquidity", liquidity);
    console2.log("liquidity delta", liquidityDelta);
    console2.log("amount 0", amount0);
    console2.log("amount 1", amount1);

    //Collect fees
    (uint256 fee0, uint256 fee1) = uni.collectAllFees(tokenId);

    console2.log("----- Collect fees---------");
    console2.log("fee 0", fee0);
    console2.log("fee 1", fee1);

    // Increase liquidity
    uint256 daiAmountToAdd = 5 * 1e18;
    uint256 wethAmountToAdd = 0.5 * 1e18;

    (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRange(tokenId, daiAmountToAdd, wethAmountToAdd);

    liquidity += liquidityDelta;

    console2.log("-------Increase liquidity----------");
    console2.log("liquidity", liquidity);
    console2.log("liquidity delta", liquidityDelta);
    console2.log("amount 0", amount0);
    console2.log("amount 1", amount1);

    // Decrease liquidity
    (amount0, amount1) = uni.decreaseLiquidityCurrentRange(tokenId, liquidity);

    console2.log("-------Decrease liquidity ----------");
    console2.log("amount 0", amount0);
    console2.log("amount 1", amount1);

}

}