//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//1. Limit self-triage to 15/29 mins.
//2. Don't be afraid to ask AI, but don't skip learning.
//3. Hallucinations are when AI makes something up that it thinks its right.
//4. Use the forums!!!
//5. google the exact error
//6. Post in stack exchange or peeranha.
//7. Posting an issue on github/git

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//Libraries cannot have any state variables and all its functions are marked internal.

library PriceConverter {

    function getPrice() internal view returns(uint256) {//this function will get live prices of ETH in USD using chainlink Data feeds.
    //To do above we get the SC address from Chainlink under data feed for Sepolia, ETH/USD and then we get the ABI as well from the githun repo for chainlink which you can get from chainlink website
    //Address> 0x694AA1769357215DE4FAC081bf1f309aDC325306
    //ABI
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    (,int256 price, , , )= priceFeed.latestRoundData(); //The reasomn Price is int256 bcos some price feeds could be negative.decimals()
    //Price of Eth in terms of USD.
    //It will return like this 200000000000
    return uint256(price* 1e10); //This will get price here to match up with msg.value by adding the remaining 10 decimal places to the above 8.
    //msg.value is uint256 while price is int256 in order for them to match we convert price to uint256 we do typecasting by wraping price in uint256 like above.
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {// we are gonna covert the ethAmount to its value in dollars.
        //Lets say ethAmount is 2 ETH is (2_000000000000000000)
        //And ethPrice is $2000_000000000000000000 per Eth
        uint256 ethPrice = getPrice();
        //(2000_000000000000000000 * 2_000000000000000000) / 1e18 ......The multiplication will give us 36zeros divided by 18zeros brings down to 18zeros.
        //$2000 = 1 ETH then $4000 = 2 ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //The reason we divide by 1e18 is because both ethPrice and ethAmopunt both have 18 decimals. Math below.
                        // 1000000000000000000 * 1000000000000000000 = 1000000000000000000000000000000000000 / 1000000000000000000 = 1000000000000000000
        return ethAmountInUsd;
    }
}