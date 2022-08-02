// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./cryptoflathelper.sol";

contract CryptoFlat is CryptoFlatHelper {
    address payable owner;
    address payable tenant;
    uint32 rentYears = 1;
    uint256 depositRequire = 0.63 ether;
    uint256 price = 0.19 ether;
    uint256 deposit;
    uint256 paymentsCount;
    uint256 lastPaymentTime;
    uint256 bookedTime;
    bool isBooked = false;

    constructor() payable checkPrice(depositRequire) {
        owner = payable(msg.sender);
        deposit = msg.value;
    }

    function cancelRent() private {
        isBooked = false;
        tenant = payable(address(0));
    }

    function cancelByTenant() public onlyOwner(tenant) onlyBooked(isBooked) {    
        owner.transfer(deposit);
        deposit = 0;
        cancelRent();
    }

    function cancelByOwner() public onlyOwner(owner) onlyBooked(isBooked) {
        if (block.timestamp - lastPaymentTime >= 30 days || hasExpired() == true) {
            owner.transfer(deposit);
        } else {
            tenant.transfer(deposit);
        }
        deposit = 0;
        cancelRent();
    }

    function book() public payable notBooked(isBooked) checkPrice(price) {
        require(msg.sender != owner,  "You are owner.");
        tenant = payable(msg.sender);
        isBooked = true;
        bookedTime = block.timestamp;
        paymentsCount = rentYears * 12;
        pay();
    }

    function pay() public payable onlyBooked(isBooked) checkPrice(price) {
        require(msg.sender != owner,  "You are owner.");
        require(isTimeToPay() == true, "To early.");
        owner.transfer(msg.value);
        paymentsCount--;
        lastPaymentTime = block.timestamp;
    }

    function isTimeToPay() public view onlyOwner(tenant) returns(bool) {
        require(paymentsCount > 1);
        if (block.timestamp - lastPaymentTime >= 29 days) {
            return true;
        } else {
            return false;
        }
    }

    function hasExpired() public view onlyBooked(isBooked) returns(bool) {
        if (block.timestamp - bookedTime >= rentYears * 365 days) {
            return true;
        } else {
            return false;
        }
    }
}