// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Token {
    address private tokenOwner;
    address private charityAddress;
    address private stakeAddress;
    uint totalSupply = 100000;
    uint currentSupply = 0;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint amount);
    event Mint(address to, uint amount);

    constructor() {
        tokenOwner = msg.sender;
    }

    function mint(address to, uint amount) external {
        require(msg.sender == tokenOwner, "Error! You are not the token's owner");
        require(balances[to] + amount > balances[to]);
        uint mintableAmount = totalSupply - currentSupply;
        amount = mintableAmount > amount? amount : mintableAmount;
        balances[to] += amount;
        currentSupply += amount;

        emit Mint(to, amount);
    }

    function move(address from, address to, uint amount) internal {
        require(balances[from] >= amount);
        require(balances[to] + amount >= balances[to]);
        balances[from] -= amount;
        balances[to] += amount;
    }

    function transfer(address to, uint amount) external returns (bool success) {
        move(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool success) {
        if (msg.sender == charityAddress || msg.sender == stakeAddress) {
            move(from, to, amount);
            emit Transfer(from, to, amount);
            return true;
        } else {
            require(allowed[from][msg.sender] >= amount);
            allowed[from][msg.sender] -= amount;
            move(from, to, amount);
            emit Transfer(from, to, amount);
            return true;
        }
    }

    function approve(address spender, uint tokens) external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function balanceOf(address owner) external view returns (uint balance) {
        return balances[owner];
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return allowed[owner][spender];
    }

    function setStakeAddress(address contractAddress) external {
        require(msg.sender == tokenOwner);
        stakeAddress = contractAddress;
    }

    function setCharityAddress(address contractAddress) external {
        require(msg.sender == tokenOwner);
        charityAddress = contractAddress;
    }
}