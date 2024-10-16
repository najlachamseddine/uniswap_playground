pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2SwapExamples, IERC20, IWETH} from "../src/UniswapV2SwapExamples.sol";
import "forge-std/console.sol";


// address constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14; //0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
// address constant DAI = 0x68194a729C2450ad26072b3D33ADaCbcef39D574; //0x6B175474E89094C44Da98b954EedeAC495271d0F;
// address constant USDC = 0xf08A50178dfcDe18524640EA6618a1f965821715; //0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;


address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;



contract UniswapV2SwapExamplesTest is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private usdc = IERC20(USDC);

    UniswapV2SwapExamples public uni;

    function setUp() public {
        // 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 // mainnet
        //  weth = IWETH(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
        uni = new UniswapV2SwapExamples();
        vm.deal(address(this), 10 ether);
    }

    function testDeposit() public {
        uint256 balBefore = weth.balanceOf(address(this));
        console.log("balance before", balBefore);

        weth.deposit{value: 100}();

        uint256 balAfter = weth.balanceOf(address(this));
        console.log("balance after", balAfter);

    } 


     // Swap WETH -> DAI
    function xtestSwapSingleHopExactAmountIn() public {
        console.logString(">>>>>>>>>>>>>TEST-1");
        uint256 wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        console.logString(">>>>>>>>>>>>>TEST-1-1");
        weth.approve(address(uni), wethAmount);
        console.logString(">>>>>>>>>>>>>TEST-1-2");
        console.logString("test-1-before");
        uint256 daiAmountMin = 1;
        uint256 daiAmountOut = uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);
        console.logString("test-1-after");
        console2.log("DAI", daiAmountOut);
        // console.logUint(daiAmountOut);
        assertGe(daiAmountOut, daiAmountMin, "amount out < min");
    }

    // Swap DAI -> WETH -> USDC
    function xtestswapMultiHopExactAmountIn() public {
        uint256 wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1;
        uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);

        uint256 daiAmountIn = 1e18;
        dai.approve(address(uni), daiAmountIn);

        uint256 usdcAmountMin = 1;
        uint256 usdcAmountOut = uni.swapMultiHopExactAmountIn(daiAmountIn, usdcAmountMin);
        
          console2.log("USDC", usdcAmountOut);
        // console.logUint(daiAmountOut);
        assertGe(usdcAmountOut, usdcAmountMin, "amount out < min");

    }

    // Swap WETH -> DAI
    function xtestswapSingleHopExactAmountOut() public {
        uint256 wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 amountOutDesired = 1e18;
        uint256 amountOut = uni.swapSingleHopExactAmountOut(amountOutDesired, wethAmount);
        assertEq(amountOut, amountOutDesired, "out != desired");

    }

    // Swap DAI -> WETH -> USDC
    function xtestswapMultiHopExactAmountOut() public {
        uint256 wethAmount = 1e18;
        weth.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmount = 10 * 1e18;
        uni.swapSingleHopExactAmountOut(wethAmount, daiAmount);

        dai.approve(address(uni), daiAmount);

        uint256 amountOutDesired = 1e6;
        uint256 amountOut = uni.swapMultiHopExactAmountOut(amountOutDesired, daiAmount);
        assertEq(amountOut,amountOutDesired, "out != desired");

    }
}

// https://sepolia.infura.io/v3/9a36ca959f654f67b5cfbbea5f07d18f


// forge build
// forge test --fork-url https://sepolia.infura.io/v3/9a36ca959f654f67b5cfbbea5f07d18f -vvvv
// forge test --fork-url https://mainnet.infura.io/v3/9a36ca959f654f67b5cfbbea5f07d18f -vvvv
// $ alias forge='/home/najla/.foundry/bin/forge'
// $ forge test --fork-url https://mainnet.infura.io/v3/9a36ca959f654f67b5cfbbea5f07d18f --match-path test/UniswapV2SwapExamples.t.sol -vvvv