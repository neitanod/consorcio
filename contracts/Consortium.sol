pragma solidity ^0.4.18;

contract Consortium {
    
    constant uint TOTAL = 10000;
    
    uint[] holder_participation;
    string[] holder_name;
    address[] holder_account;
    bool initialized=false;
    
    uint requiredVotes;
    uint holderCount=0;
    uint totalParticipation=0;
    
    modifier onlyDuringInitialization {
        require(initialized==false);
        _;
    }
    
    function Consortium(uint requiredVote) public {
        requiredVotes = requiredVote;
        initialized=false;
    }
    
    function AddHolder(string name, address account, uint participation)  
        public onlyDuringInitialization  {
        
        require(participation>0);
        require(totalParticipation+participation<=TOTAL);
        
        totalParticipation+=participation;
        holder_participation.push(participation);
        holder_name.push(name);
        holder_account.push(account);
        
        holderCount++;
        
        if(totalParticipation==TOTAL)
            initialized=true;
    }
        
    function IsInitialized() public constant returns (bool) {
        return initialized;
    }
    
    function getHolder(uint i) public constant returns (string name, address account, uint participation) {
        require(i>=0);
        require(i<holderCount);
        
        return (holder_name[i], holder_account[i], holder_participation[i]);
    }
    
}