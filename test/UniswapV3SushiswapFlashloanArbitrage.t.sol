pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV3SushsiswapFlashloanArbitrage} from "../src/UniswapV3SushiswapFlashloanArbitrage.sol";

address constant SUSHISWAP_ROUTER_02 = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
address constant UNISWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

contract UniswapV3SushiswapFlashloanArbitrageTest is Test {
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // DAI / WETH 0.3% fee
    address constant POOL_UNISWAP = 0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8;
    uint24 constant POOL_FEE = 3000;

    UniswapV3SushsiswapFlashloanArbitrage arbitrage;
    address constant user = address(11);

    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);

    function setUp() public {
        arbitrage = new UniswapV3SushsiswapFlashloanArbitrage(POOL_UNISWAP);
        deal(WETH, user, 1e6 * 1e18);
        vm.prank(user);
        dai.approve(address(arbitrage), type(uint256).max);
    }

    function test_flash() public {
        uint256 dai_before = dai.balanceOf(user);
        vm.prank(user);
        arbitrage.flash(1e6 * 1e18, 0);
        uint256 dai_after = dai.balanceOf(user);
        uint256 fee = dai_before - dai_after;
        console2.log("DAI FEE", fee);
    }
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