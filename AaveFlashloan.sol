// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract SimpleFlashLoan is FlashLoanSimpleReceiverBase {
    address payable owner;
    address public usdcMainnet = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdcSepolia = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
    address public poolAddressMainnet = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    address public poolAddressSepolia = 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A;

    constructor() FlashLoanSimpleReceiverBase(IPoolAddressesProvider(poolAddressSepolia))
    {
        owner = payable(msg.sender);
    }

    function FlashLoan(uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = usdcSepolia;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }
    
    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        //Any trade logic

        
        
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    receive() external payable {}

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(address(this).balance >= amount, "Insufficient balance in contract");
        
        owner.transfer(amount);
    }
}
