// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract FallbackExample {
    uint256 public result;

    receive() external payable  {   //we don't add a function keyword for reveive beacuse solidity knows receive is a special keyword.
    //Whever we send ETH to this contract the receive function will get triggered as long as there is no data associated with the transaction
        result = 1;
    }     

    fallback() external  payable  {//very similar to receive function, except it can work when data is sent/associated with the transaction.
        result = 2;
    }        

}

//Ether is sent to contract
//      is msg.data empty?
//          /      \
//         yes     no
//         /        \
//      receive()?  fallback()
//       /   \
//     yes   no
//     /      \
//receive()  fallback()

