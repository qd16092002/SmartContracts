// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
contract Voting{
    uint public _total_voted;
    uint public _accept_vote;
    address[] public AcceptVoteAccounts;
    address[] public DeclineVoteCampaign;
    bool public isVoted;

    constructor(){
        _total_voted = 0;
        _accept_vote = 0;
    }

    function vote_campaign(bool _votetype) external{
        address _vote_address = msg.sender;
        for(uint i=0; i<_accept_vote; i++)
            {if (_vote_address==AcceptVoteAccounts[i]) isVoted = true;}
        for(uint i=0; i<_total_voted - _accept_vote; i++)
            {if (_vote_address==DeclineVoteCampaign[i]) isVoted = true;}
        require(isVoted==false,"You have already voted.");
        if (_votetype) {
            _total_voted += 1;
            _accept_vote += 1;
            AcceptVoteAccounts.push(_vote_address);
        } else{
            _total_voted += 1;
            DeclineVoteCampaign.push(_vote_address);
        }
    }

    function get_total_vote() public view returns(uint){ return _total_voted;}

    function get_accept_vote() public view returns(uint){ return _accept_vote;}

    function get_accept_account(uint n) public view returns(address) { return AcceptVoteAccounts[n];}

    function get_decline_account(uint n) public view returns(address) { return DeclineVoteCampaign[n];}

    
}