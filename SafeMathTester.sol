// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract SafeMathTester {
    uint8 public bigNumber = 255; //The biggest of uint8 is 255 hence uint256. Uint8 is wrppaed in 0=255 after 255 goes back to 0.

    function add() public {
        unchecked {bigNumber = bigNumber + 1;}//unchecked keyword makes your transaction more gas efficient.
    }
}



//Below code is same as above for version 0.6.0 and below



// contract SafeMathTester {
//     uint8 public bigNumber = 255; //The biggest of uint8 is 255 hence uint256. Uint8 is wrppaed in 0=255 after 255 goes back to 0.

//     function add() public {
//         bigNumber = bigNumber + 1;
//     }
// }