pragma solidity ^0.4.4;

contract Consortium {
    
    /* Events */
    event HolderDeposit(string holderName, uint value);
    event ExternalDeposit(address sender, uint value);

    /* Constants */     
    uint constant MAX_OWNER_COUNT = 10;
    uint constant MAX_PARTICIPATION = 10000; // one hundred percent representation 
    
    /* Storage */     
    
    // holders
    address[] holderAccounts;
    mapping (address => string) holderNames;
    mapping (address => uint) holderParticipations;
    mapping (address => uint) holderDeposits;
    
    // settings
    uint requiredVotes;
    
    // status
    bool initialized=false;
    uint holderCount=0;
    uint totalParticipation=0;
    
    // payments
    
    
    /* Modifiers */    
    
    modifier onlyDuringInitialization {
        require(initialized==false);
        _;
    }
    
    modifier onlyAfterInitialization {
        require(initialized==true);
        _;
    }
    
    modifier onlyIfIsHolder {
        require(isHolder(msg.sender));
        _;
    }
    
    function Consortium(uint _requiredVotes) public {
        require(requiredVotes<=MAX_PARTICIPATION);
        
        requiredVotes = _requiredVotes;
        initialized=false;
    }
    
    /* Public Functions */
    
    function addHolder(string name, address account, uint participation)  
        public onlyDuringInitialization returns (bool InitializationComplete) {
        
        require(participation>0);
        require(totalParticipation+participation<=MAX_PARTICIPATION);
        require(holderCount<MAX_OWNER_COUNT);
        require(!isHolder(account));
        
        totalParticipation+=participation;
        holderParticipations[account]=participation;
        holderNames[account]=name;
        holderAccounts.push(account);
        
        holderCount++;
        
        if(totalParticipation==MAX_PARTICIPATION)
            initialized=true;
            
        return initialized;
    }

    /* Fallback */    
    function() payable public onlyAfterInitialization {
        if (msg.value > 0) {
            if (isHolder(msg.sender)) {
                var name = holderNames[msg.sender];
                holderDeposits[msg.sender] += msg.value; // holder deposit accountability
                HolderDeposit(name, msg.value); // Log External Event
            } else {
                ExternalDeposit(msg.sender, msg.value);
            }
        }
    }
    
    /* Call functions */
    function isInitialized() public constant returns (bool) {
        return initialized;
    }
    
    function isHolder(address account) public constant returns (bool) {
        if (holderParticipations[account]>0)
            return true;
        else
            return false;
    }
    
    function getHolder(uint i) public constant returns (string name, address account, uint participation, uint deposits) {
        require(i>=0 && i<holderCount);
        account = holderAccounts[i];
        return (holderNames[account], account, holderParticipations[account], holderDeposits[account]);
    }
    
    function getHolderCount() public constant returns (uint) {
        return holderCount;
    }
    
    /* Internal Functions */
    
}