// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Fix: Cố định version mới, tránh lỗi của bản cũ

contract GoodVault {
    mapping(address => uint256) public balances;
    address public immutable owner; // Fix: Dùng immutable cho biến chỉ gán 1 lần

    // Modifier để kiểm soát quyền truy cập
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        // Fix: Dùng msg.sender thay vì tx.origin để tránh tấn công phishing
        balances[msg.sender] += msg.value; 
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // Fix: Checks-Effects-Interactions Pattern
        // 1. Effects: Cập nhật state trước
        balances[msg.sender] = 0;

        // 2. Interactions: Thực hiện call sau
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // Fix: Đổi tên để tránh Shadowing và thêm onlyOwner
    function destroy() public onlyOwner {
        // Lưu ý: selfdestruct đã bị deprecated trong các EVM version mới (Cancun)
        // nhưng vẫn giữ ở đây để demo cách fix lỗi access control của Slither.
        selfdestruct(payable(owner)); 
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}