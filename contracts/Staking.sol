// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;



contract Staking{
    address public immutable  _owner;
    address public immutable  _ft_contract;
    uint public _total_stake_balance;
    uint public _total_paid_reward_balance;
    uint public _total_staker;
    
    struct AccountInfo{
        uint account_balance;
        uint stake_start_time;
        uint unstake_start_time;
        uint unstake_available_block;
    }

    mapping(address => AccountInfo) accounts_info;
    
    address[] accounts_address;

    event LogNeedToUnstake();
    event Staked(uint amount);
    event Unstaked();
    event Harvested();
    event Withdrawed();
    event Tranfered(bool success,bytes data);

    constructor(address ft_contract){
        _owner = msg.sender;
        _ft_contract = ft_contract;
        _total_stake_balance = 0;
        _total_paid_reward_balance = 0;
        _total_staker = 0; 
    }

    function get_total_stake_balance() public view returns(uint) {return _total_stake_balance;}
    function get_total_paid_reward_balance() public view returns(uint) {return _total_paid_reward_balance;}
    function get_total_staker() public view returns(uint) {return _total_staker;}

    function get_account_info(address account) public view 
        returns(uint balance,
                uint stake_start_time, 
                uint unstake_start_time, 
                uint unstake_available_block ){
        balance = accounts_info[account].account_balance;
        stake_start_time = accounts_info[account].stake_start_time;
        unstake_start_time = accounts_info[account].unstake_start_time;
        unstake_available_block = accounts_info[account].unstake_available_block;
    }

    function register_account(address account) internal{
        accounts_address.push(account);
        accounts_info[account].account_balance = 0;
        accounts_info[account].stake_start_time = 0;
        accounts_info[account].unstake_start_time = 0;
        accounts_info[account].unstake_available_block = 0;
    }

    function deposit_and_stake(uint amount) public payable{
        address account = msg.sender;
        (bool success, bytes memory data) = _ft_contract.call{value: msg.value, gas: 5000}(
        	abi.encodeWithSignature("transfer(string,uint256)",_owner,amount )
        );
        
        emit Tranfered(success, data);
        AccountInfo memory account_info = accounts_info[account];
        if (account_info.account_balance != 0){
            emit LogNeedToUnstake();
        } else {
            account_info.account_balance += amount;
            account_info.stake_start_time = block.number;

            accounts_info[account].account_balance = account_info.account_balance;
            accounts_info[account].stake_start_time = account_info.stake_start_time;
            _total_stake_balance += amount;
            _total_staker +=1;

            emit Staked(amount);
        }
    }
 
    function calculate_account_reward(address account) private view returns(uint){
        AccountInfo memory account_info = accounts_info[account];
        uint reward = account_info.account_balance *(block.number - account_info.stake_start_time) *715*3/100000000000;
        return reward;
    }

    function unstake() external{
        address account = msg.sender;
        accounts_info[account].unstake_start_time = block.number;
        accounts_info[account].unstake_available_block = block.number + 10;

        emit Unstaked();
    }
    
    function harvest() public payable{
        address account = msg.sender;

        uint reward = calculate_account_reward(account);
	(bool success, bytes memory data) = _ft_contract.call{value: msg.value, gas: 5000}(
        	abi.encodeWithSignature("transferFrom(string,uint256)",_owner,account,reward )
        );
        emit Tranfered(success, data);
        _total_paid_reward_balance += reward;
        accounts_info[account].stake_start_time = block.number;
        accounts_info[account].unstake_start_time = 0;
        accounts_info[account].unstake_available_block = 0;

        emit Harvested();
    } 
    
    function withdraw() public payable{
        address account = msg.sender;
        uint reward = calculate_account_reward(account);

        (bool success, bytes memory data) = _ft_contract.call{value: msg.value, gas: 5000}(
        	abi.encodeWithSignature("transferFrom(string,uint256)",_owner,account,reward+ accounts_info[account].account_balance)
        );
        emit Tranfered(success, data);
        AccountInfo memory account_info = accounts_info[account];
        _total_paid_reward_balance += reward;
        _total_stake_balance -= account_info.account_balance;
        _total_staker -=1;

        accounts_info[account].account_balance = 0;
        accounts_info[account].stake_start_time = 0;
        accounts_info[account].unstake_start_time = 0;
        accounts_info[account].unstake_available_block = 0;

        emit Withdrawed();
    }

}
