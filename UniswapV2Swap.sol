// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV2Swap {
    address public constant uniswapV2RouterAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public owner;
    
    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function ethToToken(address _token) external payable onlyOwner {

        address[] memory path = new address[](2);
        path[0] = IUniswapV2Router02(uniswapV2RouterAddr).WETH();
        path[1] = _token;
        
        IUniswapV2Router02(uniswapV2RouterAddr).swapExactETHForTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp + 15 minutes
        );
    }

    function tokenToEth(address _token) external payable onlyOwner {
        require(msg.value == 0, "No need to send ETH for this operation");

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = IUniswapV2Router02(uniswapV2RouterAddr).WETH();
        
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens received");
        IERC20(_token).approve(uniswapV2RouterAddr, tokenBalance);
        
        IUniswapV2Router02(uniswapV2RouterAddr).swapExactTokensForETH(
            tokenBalance,
            0,
            path,
            address(this),
            block.timestamp + 15 minutes
        );

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            payable(owner).transfer(ethBalance);
        }
    }

    function singleSwapv2(address tokenAddress) external payable onlyOwner {
        require(msg.value > 0, "Amount of ETH must be greater than zero");

        address[] memory pathToToken = new address[](2);
        pathToToken[0] = IUniswapV2Router02(uniswapV2RouterAddr).WETH();
        pathToToken[1] = tokenAddress;
        IUniswapV2Router02(uniswapV2RouterAddr).swapExactETHForTokens{value: msg.value}(
            0,
            pathToToken,
            address(this),
            block.timestamp + 15 minutes
        );

        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens received");

        IERC20(tokenAddress).approve(uniswapV2RouterAddr, tokenBalance);

        address[] memory pathToEth = new address[](2);
        pathToEth[0] = tokenAddress;
        pathToEth[1] = IUniswapV2Router02(uniswapV2RouterAddr).WETH();
        IUniswapV2Router02(uniswapV2RouterAddr).swapExactTokensForETH(
            tokenBalance,
            0,
            pathToEth,
            address(this),
            block.timestamp + 15 minutes
        );

        uint256 remainingEth = address(this).balance;
        if (remainingEth > 0) {
            payable(owner).transfer(remainingEth);
        }
    }

    receive() external payable {}

    function rescueTokens(address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(owner, amount);
    }

    function rescueETH() public onlyOwner {
        require(address(this).balance >= 0, "Insufficient balance");
        payable(owner).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    function contractBalance(address tokenAddress) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }
}
