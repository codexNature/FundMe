//What we wanna do
//1: Get funds from users
//2: Withdraw funds to the owner of the contract.
//3:Set a minimum funcding amount in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner(); //replacing this with require statements for error spits outs this saves gas

contract FundMe {
    using PriceConverter for uint256;//We attached the PriceConverter library to all uint256

    uint256 public constant MINIMUM_USD = 5e18;//This is because the return for $5 will come with 18decimals.
                    //when constant keyword is added the minimumUsd no longer take up storage spot and is much easier to read.constant keyword makes gass fee cheaper.
                    //Constant keyword is used with variable set only once.
                    //constant variables have a different naming conditions usually all caps

    address[] public funders; //This keeps records of those that sends us money.
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded; //This will mapp who to how much was sent.

    //uint256 public myValue = 1;

    address public immutable i_owner;//The convension of writing the variable for immutable is to put i_variablename, like we have with owner on same line.
                    //immutable keyword are similar gas savings to constant. Immutable and constants are nice gas savers if i'm setting the variable once.

    constructor() {
        i_owner = msg.sender; //Constructor make it oissible for only the owner of the account to call withdraw function. msg.sender here is the owner of the contract.
    }

    function fund() public payable { //The payable keywork turns the button red. SC can hold funds just like a wallet. For a function to receive native blockchain token like Ethereum it needs to be marked payable
        
        //myValue = myValue + 2; //Every time the fund function goes through we have 2 added to the value. This line is a revert.
        require(msg.value.getConversionRate() >= MINIMUM_USD, "did not send enough ETH"); //1e18 = 1 ETH = 1000000000000000000 = 1*10**18. msg.value is the number of wei sent with the msg and require reqires a particular amount or minimum acct. The reuire here requires the user to spend atleast 1eth with this function.
        //getConversionRate of msg.Value needs to be greater that mininmuUSD. msg.value.getConversionRate() used like this because of library.
        //If you want to force a transaction to do something and need it to fail if not done it needs to be marked require.
        //A revert undoes any action that have been done, and send the remaining gas back.
        //A blockchain oracle is any device that interacts with the off-chain world to provide external data or computatiion to smart contracts.
        //Centralized oracles are a point of failure, we cannot have blockchain decentralized and have what feeds in external information centralized.
        //Chainlink is a  decentralized oracle network for bringing data and external computation into our smart contracts. Combining offchain and onchain.
        funders.push(msg.sender); //msg.sender is the sender of the message. address
        addressToAmountFunded[msg.sender] += msg.value; //This means equal to itself plus msg.value. This shows us how much they have spent in total.
    }

    function withdraw() onlyOwner public  { //To withdraw we want to reset all the mappings back down to zero, we use the for-loop for this.
        //require(msg.sender == owner, "Can only be completed by owner");//This is linked to the contructor which makes it so only the owner of the contract can call the withdraw function.
        //for(/* staring index, ending index, step amount */);
                //0, 10, 1
                //0,1,2,3,4,5,6,7,8,9,10

                //3, 12, 2
                //3,5,7,9,11
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex]; //we wanna use this to reset out addressToAmountFunded.
            addressToAmountFunded[funder] = 0;// we are gonna reset down to zero because we are withdrawing all the money.
        }
        //To reset the array
        funders = new address[](0);

        //withdraw the funds. To send funds from a SC. Three ways to do withdrawal.

        //1 transfer
        //msg.sender = address
        //payable(msg.sender) = payable address
            //payable(msg.sender).transfer(address(this).balance); //The this keyword refers to this whole contract.


        //2 send
            // bool sendSuccess = payable(msg.sender).send(address(this).balance);//The bool is for when it fails we still revert to require state below.
            // require(sendSuccess, "Send Failed.");


        //3 call //we can use it to call any function in all of ethereum without even having to ABI.
            (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");//The call retrunes two variables which is what we placed at the begining of the line
            //If the function called by call returns data or value we are gonna save that in the dataReturned. and if successfully call bool will be true and if not false
            require(callSuccess, "Call Failed"); //
      }



       //function getPrice() public view returns(uint256) {//this function will get live prices of ETH in USD using chainlink Data feeds.
    //To do above we get the SC address from Chainlink under data feed for Sepolia, ETH/USD and then we get the ABI as well from the githun repo for chainlink which you can get from chainlink website
    //Address> 0x694AA1769357215DE4FAC081bf1f309aDC325306
    //ABI
      //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      //(,int256 price, , , )= priceFeed.latestRoundData(); //The reasomn Price is int256 bcos some price feeds could be negative.decimals()
    //Price of Eth in terms of USD.
    //It will return like this 200000000000
      //return uint256(price* 1e10); //This will get price here to match up with msg.value by adding the remaining 10 decimal places to the above 8.
    //msg.value is uint256 while price is int256 in order for them to match we convert price to uint256 we do typecasting by wraping price in uint256 like above.
    //}

    //function getConversionRate(uint256 ethAmount) public view returns(uint256) {// we are gonna covert the ethAmount to its value in dollars.
        //Lets say ethAmount is 2 ETH is (2_000000000000000000)
        //And ethPrice is $2000_000000000000000000 per Eth
          //uint256 ethPrice = getPrice();
        //(2000_000000000000000000 * 2_000000000000000000) / 1e18 ......The multiplication will give us 36zeros divided by 18zeros brings down to 18zeros.
        //$2000 = 1 ETH then $4000 = 2 ETH
          //uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //The reason we divide by 1e18 is because both ethPrice and ethAmopunt both have 18 decimals. Math below.
                        // 1000000000000000000 * 1000000000000000000 = 1000000000000000000000000000000000000 / 1000000000000000000 = 1000000000000000000
          //return ethAmountInUsd;

    //}

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner");
        if(msg.sender != i_owner) { revert NotOwner(); }//This replaces the above line for lesser gas and it calls the error written outside the contract. NotOwner(). This saves us gas because we do not have top store the string in the require statement,
        _; //its gonna execute the require statement first and the uderscore is whatever else you wanna do in the function.
            // and if the underscore is above the require statement it means do require statement last within the function, do others first, in this case the function is the withdrawal function.
    }
    //A modifier allows us to create a keyword that we can put right in the function declaration to add some functionality very quickly and easily. paticulary things are gonna be using often


    //What happens if someone send ETH to the contract without calling the fund function.
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    //With the two functions above if someone send transaction to this contract it will reroute them to fund still.

}
