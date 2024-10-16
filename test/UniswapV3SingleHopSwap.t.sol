pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV3SingleHopSwap, IERC20, IWETH} from "../src/UniswapV3SingleHopSwap.sol";
import "forge-std/console.sol";


address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

contract UniswapV3SingleHopSwapTest is Test {

    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    UniswapV3SingleHopSwap swap;

function setUp() public {
     swap = new UniswapV3SingleHopSwap();

}

function test_SwapExactInputSingleHop() public {
    uint256 amountIn = 1e18;
    weth.deposit{value: amountIn}();
    weth.approve(address(swap), amountIn);

    uint256 amountOutMin = 1;
    uint256 amount = swap.swapExactInputSingleHop(amountIn, amountOutMin);
    assertGt(amount, amountOutMin, "amount < amountOutMin");
    uint256 bal = dai.balanceOf(address(this));
    assertGt(bal, 0, "DAI balance = 0");
}

function test_SwapExactOutputSingleHop() public {
    uint256 amountInMax = 1e18;
    weth.deposit{value: amountInMax}();
    weth.approve(address(swap), amountInMax);

    uint256 amountOut = 1e18;
    uint256 amountIn = swap.swapExactOutputSingleHop(amountInMax, amountOut);
    assertGe(amountInMax, amountIn, "amountInMax < amountIn");
}


}