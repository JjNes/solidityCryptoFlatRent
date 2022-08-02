// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract CryptoFlatHelper {

    modifier notBooked(bool _isBooked) {
        require(_isBooked == false, "Wait until the rent time.");
        _;
    }

    modifier onlyBooked(bool _isBooked) {
        require(_isBooked == true, "Flat must be booked.");
        _;
    }

    modifier checkPrice(uint256 _price){
        require(msg.value >= _price, "Incorrect price.");
        _;
    }

    modifier onlyOwner(address _owner) {
        require(msg.sender == _owner, "Only owner can do this.");
        _;
    }
}