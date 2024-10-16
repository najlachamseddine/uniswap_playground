pragma solidity ^0.8.24;

// https://docs.uniswap.org/contracts/v3/guides/flash-integrations/inheritance-constructors
// https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3Pool.sol#L791

import {UniswapV2SwapExamplesGenericRouter, IERC20, IWETH} from "./UniswapV2SwapExamplesGenericRouter.sol";

contract UniswapV3SushsiswapFlashloanArbitrage {
    address private constant SUSHISWAP_V2_ROUTER =
        0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    IUniswapV3Pool private immutable poolUniswap;
    IERC20 private immutable token0;
    IERC20 private immutable token1;
    UniswapV2SwapExamplesGenericRouter uni;
    UniswapV2SwapExamplesGenericRouter sushi;

    constructor(address _poolUniswap) {
        poolUniswap = IUniswapV3Pool(_poolUniswap);
        token0 = IERC20(poolUniswap.token0());
        token1 = IERC20(poolUniswap.token1());
        sushi = new UniswapV2SwapExamplesGenericRouter(SUSHISWAP_V2_ROUTER);
        uni = new UniswapV2SwapExamplesGenericRouter(UNISWAP_V2_ROUTER);
    }

    function flash(uint256 amount0, uint256 amount1) external {
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount0: amount0,
                amount1: amount1,
                caller: msg.sender
            })
        );
        IUniswapV3Pool(poolUniswap).flash(address(this), amount0, amount1, data);
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external {
        require(msg.sender == address(poolUniswap), "not authorized");

        FlashCallbackData memory decoded = abi.decode(
            data,
            (FlashCallbackData)
        );

        if (decoded.amount0 > 0) {
            // do the sushiswap swap
            address[] memory pathSushi;
            pathSushi = new address[](2);
            pathSushi[0] = address(token0);
            pathSushi[1] = address(token1);
            uint256 amountOutSushi = sushi.swapSingleHopExactAmountInGenericTokens(decoded.amount0, 1, pathSushi);

            // do the uniswap swap back to refund the loan
            address[] memory pathUni;
            pathUni = new address[](2);
            pathUni[0] = address(token1);
            pathUni[1] = address(token0);
            uint256 amountOutUni = uni.swapSingleHopExactAmountInGenericTokens(
                amountOutSushi,
                decoded.amount0,
                pathUni
            );
            require(amountOutUni >= decoded.amount0, "amountOutUni < amount0");
        }

        if (decoded.amount1 > 0) {
            address[] memory pathSushi;
            pathSushi = new address[](2);
            pathSushi[0] = address(token1);
            pathSushi[1] = address(token0);
            uint256 amountOutSushi = sushi
                .swapSingleHopExactAmountInGenericTokens(decoded.amount0, 1, pathSushi);

            address[] memory pathUni;
            pathUni = new address[](2);
            pathUni[0] = address(token0);
            pathUni[1] = address(token1);
            uint256 amountOutUni = uni.swapSingleHopExactAmountInGenericTokens(
                amountOutSushi,
                decoded.amount1,
                pathUni
            );
             require(amountOutUni >= decoded.amount1, "amountOutUni < amount1");
        }

        if (fee0 > 0) {
            token0.transferFrom(decoded.caller, address(this), fee0);
        }

        if (fee1 > 0) {
            token1.transferFrom(decoded.caller, address(this), fee1);
        }

        if (fee0 > 0) {
            token0.transfer(address(poolUniswap), decoded.amount0 + fee0);
        }

        if (fee1 > 0) {
            token1.transfer(address(poolUniswap), decoded.amount1 + fee1);
        }
    }
}

interface IUniswapV3Pool {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

