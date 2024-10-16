pragma solidity ^0.8.24;

import "forge-std/console.sol";

contract UniswapV2SwapExamplesGenericRouter {
// https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02
address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

event LogPrint(string);

// sepolia
// address private constant UNISWAP_V2_ROUTER = 0x425141165d3DE9FEC831896C016617a52363b687;
// address private constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
// address private constant DAI = 0x68194a729C2450ad26072b3D33ADaCbcef39D574;
// address private constant USDC = 0xf08A50178dfcDe18524640EA6618a1f965821715;

IUniswapV2Router private router;
IERC20 public weth = IERC20(WETH);
IERC20 private dai = IERC20(DAI);

constructor(address _swapRouter) {
    router = IUniswapV2Router(_swapRouter);
}

// Swap WETH to DAI
function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin) external returns (uint256 amountOut) {

    weth.transferFrom(msg.sender, address(this), amountIn);
    weth.approve(address(router), amountIn);

    address[] memory path;
    path = new address[](2); 
    path[0] = WETH;
    path[1] = DAI;

    try router.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp) returns (uint256[] memory amounts){
            console.log(amounts[1]);
           return amounts[1];
    } catch Error(string memory reason) {
        emit LogPrint(reason);
    }

}

function swapSingleHopExactAmountInGenericTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path) external returns (uint256 amountOut) {

    weth.transferFrom(msg.sender, address(this), amountIn);
    weth.approve(address(router), amountIn);

    try router.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp) returns (uint256[] memory amounts){
            console.log(amounts[1]);
           return amounts[1];
    } catch Error(string memory reason) {
        emit LogPrint(reason);
    }

}


// Swap DAI -> WETH -> USDC
function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin) external returns (uint256 amountOut) {

    dai.transferFrom(msg.sender, address(this), amountIn);
    dai.approve(address(router), amountIn);

    address[] memory path;
    path = new address[](3); 
    path[0] = DAI;
    path[1] = WETH;
    path[2] = USDC;

    uint256[] memory amounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp);

    return amounts[2];
}

// Swap WETH to DAI
function swapSingleHopExactAmountOut(uint256 amountOutDesired, uint256 amountInMax) external returns(uint256 amountOut) {
    weth.transferFrom(msg.sender, address(this), amountInMax);
    weth.approve(address(router), amountInMax);

    address[] memory path;
    path = new address[](2);
    path[0] = WETH;
    path[1] = DAI;

    uint256[] memory amounts = router.swapTokensForExactTokens(amountInMax, amountOutDesired, path, msg.sender, block.timestamp);

    if (amounts[0] < amountInMax) {
        weth.transferFrom(address(this), msg.sender, amountInMax - amounts[0]);
    }
    return amounts[1];
}

// Swap DAI -> WETH -> USDC
function swapMultiHopExactAmountOut(uint256 amountOutDesired, uint256 amountInMax) external returns(uint256 amountOut) {
    dai.transferFrom(msg.sender, address(this), amountInMax);
    dai.approve(address(router), amountInMax);

    address[] memory path;
    path = new address[](3);
    path[0] = DAI;
    path[1] = WETH;
    path[2] = USDC;

    uint256[] memory amounts = router.swapTokensForExactTokens(amountInMax, amountOutDesired, path, msg.sender, block.timestamp);
    if (amounts[0] < amountInMax) {
        dai.transferFrom(address(this), msg.sender, amountInMax - amounts[0]);
    }
    return amounts[2];
    
}

}
interface IUniswapV2Router {
    // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02#swapexacttokensfortokens
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}