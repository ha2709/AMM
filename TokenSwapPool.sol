// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract swapPoolWEI_LINK{
    uint public constantProduct;
    uint public contractWEIBalance;
    uint public contractLINKBalance;
    address public ChainkLinkAddressRinkeby=0x ;
    address payable public liquidityProviderAddress = payable(0xc1202e7d42655F23097476f6D48006fE56d38d4f);

    ERC20TokenContract tokenObject = ERC20TokenContract(ChainkLinkAddressRinkeby);

    modifier LiquidityProviderAddressCheck() {
        require(msg.sender ==0xc1202e7d42655F23097476f6D48006fE56d38d4f, "only Admin at the Address can access this function")
        _;
    }

    function Step1_createpool() public payable LiquidityProviderAddressCheck {
     
        require(constantProduct == 0, "Pool already created");
        require(msg.value == 4, "Must be 4 WEI for pool createion");
        require(tokenObject.balanceOf(address(liquidityProviderAddress))>=4,
        "Must have 4*10^-18 LINK for poll creation" );
        require(tokenObject.allowance(liquidityProviderAddress, address(this))>=4,
        "Must allow 4 tokens from your wallet in the ERC20 contract ");
        tokenObject.transferFrom(liquidityProviderAddress, address(this),4);
        // need to approve every time before you send link from erc20 contract
        contractWEIBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
        constantProduct = contractWEIBalance*contractLINKBalance;
    }
    function Step2_swapWEIforLink() public payable {
        require(contractLINKBalance == 4 && contractWEIBalance == 4, 
        "Must have $ WEI");
        require( msg.value == (((constantProduct)/(contractLINKBalance-2))-contractWEIBalance),
        "You need to put 4 WEI");
        tokenObject.transfer(msg.sender,2); 
        // 2 LINK from contract to user
        contractWEIBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
    }

    // Need to approve every time before you send link
    function step3_swapLINKforWEI() public {
        require(contractLINKBalance == 2 && contractWEIBalance ==8,
        "Must have * WEI");
        require(tokenObject.balanceOf(address(msg.sender))>=((constantProduct)/(contractWEIBalance-4))-contractLINKBalance,
        "You need at least 2 LINK");
        require(tokenObject.allowance(msg.sender,address(this))>=((constantProduct)/(contractWEIBalance-4))-contractLINKBalance,
        "Must allow 2 tokens from your wallet");
        tokenObject.transferFrom(msg.sender,address(this), ((constantProduct)/(contractWEIBalance-4))-contractLINKBalance);
        // 2 LINK from user to contract
        payable(msg.sender).transfer(4);
        // 4 WEI from contract to user
        contractWEIBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));

    }

    function withdrawAllLINKandWEI() LiquidityProviderAddressCheck {
        payable(liquidityProviderAddress).transfer(contractWEIBalance);
        tokenObject.transfer(liquidityProviderAddress, contractLINKBalance);
        constantProduct = 0;
        contractLINKBalance = 0;
        contractWEIBalance = 0;

    }

}