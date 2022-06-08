//["0xd098d0b2d0b0d0bdd0bed0b220d0982e20d0982e000000000000000000000000", "0xd09fd0b5d182d180d0bed0b220d09f2e20d09f2e000000000000000000000000", "0xd0a1d0b8d0b4d0bed180d0bed0b220d0a12e20d0a12e00000000000000000000"]

pragma solidity ^0.5.1;

contract Voting {
    
    string myText;
    string resultList;
    
    struct Voter {   
        uint rights; 
        bool voted;  
        uint vote;  
    }

    struct Candidate {  
        bytes32 name;   
        uint voteCount; 
    }

    address payable public admin;
    
    mapping(address => Voter) public voters;
    
    Candidate[] public candidates;
 
    constructor(bytes32[] memory candNames) public {
        admin = msg.sender;
        voters[admin].rights = 1;

        for (uint i = 0; i < candNames.length; i++) {
            candidates.push(Candidate({
                name: candNames[i],
                voteCount: 0
            }));
        }
    }
    
    function () external payable {
    }
    
    event PaymentEvent(string message, string returnValue);
    function doPayment(uint candidate) public payable {
        
        Voter storage sender = voters[msg.sender];
        require(sender.rights != 0, "This voter has no right to vote.");
        require(!sender.voted, "Already voted.");
        emit PaymentEvent("Payment was sent", myText);
        sender.voted = true;
        sender.vote = candidate;

        candidates[candidate].voteCount += sender.rights;
    }
    
    function giveRightToVote(address voter) public payable {
        require(msg.sender == admin, "Only admin can give right to vote.");
        require(!voters[voter].voted, "The voter has already voted.");
        require(voters[voter].rights == 0);
        voters[voter].rights = 1;
    }
    
    function IsAdmin() public view returns (uint32) {
        if (msg.sender == admin) {
            return 1;
        }
        else {
            return 0;
        }
    }
    
    function getVotingList() public returns (string memory) {
        
        resultList = "";
        string memory votesCount = "- the number of votes: ";
        string memory name = "Candidate: ";
        string memory currentVotesCount;
        string memory currentName;
        string memory currentRow;
        
        for (uint p = 0; p < candidates.length; p++) {
            currentName = bytes32ToString(candidates[p].name);
            currentVotesCount = uint2str(candidates[p].voteCount);
            currentName = concat(name, currentName);
            currentVotesCount = concat(votesCount, currentVotesCount);
            currentRow = concat(concat(currentName, currentVotesCount), "\n");
            resultList = concat(resultList, currentRow);
        }
        return resultList;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
     
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    function concat(string memory s1, string memory s2 ) internal pure returns(string memory) {      
        
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        string memory s1s2 = new string(b1.length + b2.length);
        bytes memory b1b2 = bytes(s1s2);
        uint k = 0;
        uint i;

        for(i = 0; i < b1.length; i ++){
            b1b2[k++] = b1[i];
        }

        for(i = 0; i < b2.length; i ++){
            b1b2[k++] = b2[i];
        }
       
        return string(b1b2);
    }
    
    function winningCandidate() public view returns (uint winningCandidate_){
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winningCandidate_ = p;
            }
        }
    }
    
    function winnerName() public view returns (string memory)
    {
        string memory result = "";
        string memory winnerName_ = "";
        winnerName_ = bytes32ToString(candidates[winningCandidate()].name);
        result = concat("Election winner: ", winnerName_);
        return result;
    }
    
    function kill() public {
       if(msg.sender == admin) {
             selfdestruct(admin);
          }
    }
}
