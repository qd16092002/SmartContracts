// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./Voting.sol";

//import "./Token.sol";

contract Charity{
    //Token trans = new Token();
    struct Campaign{
        string name;
        uint Campaignid;
        string details;
        uint256 goal;
        address ownerID;
        uint fund;
        uint NumberofVotes;
        uint NumberofAcceptVote;
        uint time_to_start_voting;
        uint time_to_start_donating;
        bool isOpened;
        bool isVoting;
    }
    
    address public immutable transfer_address;

    /*function set_address(address _address) external {
        transfer_address = _address;
    }*/
    
    event Transfered(bool success, bytes data);

    constructor(address tf_address)
    {
       transfer_address = tf_address;
       campaign.push(Campaign("0",0,"0",0,0x0000000000000000000000000000000000000000,0,0,0,0,0,false,false)); 
    }

    Voting voting = new Voting();
    Campaign[] campaign;
    uint CampaignId = 0;
    uint current_time;
    
    function CreateCampaign(string memory _name, string memory _details, uint _goal, address _ownerID) public
    {
        CampaignId++;
        Campaign memory tempcpg = Campaign(_name,CampaignId,_details,_goal,_ownerID,0,0,0,0,0,false,true);
        campaign.push(tempcpg);
        campaign[CampaignId].time_to_start_voting = block.timestamp;
    }
    
    function get_Campaign_Info(uint _campaignid) public view
        returns(string memory name,
                string memory details,
                uint256 goal,
                address owner,
                uint fund,
                bool isopened,
                bool isvoting
    ) {
        name = campaign[_campaignid].name;
        details = campaign[_campaignid].details;
        goal = campaign[_campaignid].goal;
        owner = campaign[_campaignid].ownerID;
        fund = campaign[CampaignId].fund;
        isopened = campaign[_campaignid].isOpened;
        isvoting = campaign[_campaignid].isVoting;    
    }
    
    function Votings(bool _vote) external payable {
        current_time = block.timestamp;
        require(current_time < campaign[CampaignId].time_to_start_voting + 3 minutes, "Voting phase is over");
        require(msg.sender != campaign[CampaignId].ownerID, "You can not vote for your own campaign.");
        require(campaign[CampaignId].isVoting == true, "Voting phase is over.");
        voting.vote_campaign(_vote);
        (bool success, bytes memory data) = transfer_address.call{value: msg.value}(
                abi.encodeWithSignature("transfer(string, uint256)", campaign[CampaignId].ownerID, 1));
                emit Transfered(success, data);
    }    
    
    function ActivateCampaign() external payable
    {   current_time = block.timestamp;
        require(current_time > campaign[CampaignId].time_to_start_voting + 3 minutes, "The vote phase is not over yet.");
        campaign[CampaignId].NumberofAcceptVote = voting.get_accept_vote();
        campaign[CampaignId].NumberofVotes = voting.get_total_vote();
        require(msg.sender == campaign[CampaignId].ownerID, "You are not allowed!!!");
        if(campaign[CampaignId].NumberofAcceptVote >= campaign[CampaignId].NumberofVotes/2)
        {
            campaign[CampaignId].isVoting = false;
            campaign[CampaignId].isOpened = true;
            campaign[CampaignId].time_to_start_donating = current_time;
        }

        for (uint i=0; i<campaign[CampaignId].NumberofAcceptVote; i++) 
        {
            address temp = voting.get_accept_account(i);
            (bool success, bytes memory data) = transfer_address.call{value: msg.value}(
                abi.encodeWithSignature("transfer(string, uint256)", temp, 2));
                emit Transfered(success, data);
        }

    }
    
    function DeactivateCampaign() external payable
    {
        current_time = block.timestamp;
        require(current_time > campaign[CampaignId].time_to_start_voting + 3 minutes, "The vote phase is not over yet.");
        campaign[CampaignId].NumberofAcceptVote = voting.get_accept_vote();
        campaign[CampaignId].NumberofVotes = voting.get_total_vote();
        require(msg.sender == campaign[CampaignId].ownerID, "You are not allowed!!!"); 
        if(campaign[CampaignId].NumberofAcceptVote <= campaign[CampaignId].NumberofVotes / 2)
        {
            campaign[CampaignId].isVoting = false;
            campaign[CampaignId].isOpened = false;
        }
        for (uint i=0; i<voting.get_total_vote()-voting.get_accept_vote(); i++)
        {
            address temp = voting.get_decline_account(i);
            (bool success, bytes memory data) = transfer_address.call{value: msg.value}(
                abi.encodeWithSignature("transfer(string, uint256)", temp, 2));
                emit Transfered(success, data);
        }
    }
    
    function Donate(uint256 _amount) external payable {
        require(campaign[CampaignId].fund < campaign[CampaignId].goal, "We've gathered enough. Thank you for your help.");
        current_time = block.timestamp;
        require(current_time<=campaign[CampaignId].time_to_start_donating + 15 minutes, "Time for donating is over.");
        require(campaign[CampaignId].isOpened == true, "This campaign is not availabed");
        (bool success, bytes memory data) = transfer_address.call{value: msg.value}(
                abi.encodeWithSignature("transfer(string, uint256)", campaign[CampaignId].ownerID, _amount));
                emit Transfered(success, data);
        campaign[CampaignId].fund += _amount;
    }
    
    function get_vote_info() public view 
        returns(uint number_of_votes,
                uint number_of_accept_votes
        )
    {
        number_of_accept_votes = voting.get_accept_vote();
        number_of_votes = voting.get_total_vote();
    }
}    
