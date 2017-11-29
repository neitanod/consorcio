pragma solidity ^0.4.4;

contract Consortium {
    
    /* Events */
    event HolderDeposit(string holderName, uint value);
    event ExternalDeposit(address sender, uint value);
    event PaymentSubmission(string submitedBy, string paymentName, address destination, uint value);
    event PaymentExecution(uint indexed paymentId);
    event PaymentExecutionFailure(uint indexed paymentId);
    event PaymentConfirmationVote(address indexed sender, uint indexed paymentId);
    event PaymentRevocationVote(address indexed sender, uint indexed paymentId);

    /* Constants */     
    uint constant MAX_OWNER_COUNT = 10;
    uint constant MAX_PARTICIPATION = 10000; // one hundred percent representation 
    
    /* Storage */     
    
    // settings
    uint requiredVotes;
    
    // status
    bool public isInitialized=false;
    uint public holderCount=0;
    uint totalParticipation=0;
    uint public totalHoldersDepositedAmount=0;

    // holders
    address[] holderAccounts;
    mapping (address => string) holderNames;
    mapping (address => uint) holderParticipations;
    mapping (address => uint) holderDeposits;
    
    // payments
    struct Payment {
        address destination;
        string name;
        uint value;
        bool executed;
    }
    uint public paymentCount;
    mapping (uint => Payment) public payments;
    mapping (uint => mapping (address => bool)) public confirmations;
    
    /* Modifiers */    
    
    modifier onlyDuringInitialization {
        require(isInitialized==false);
        _;
    }
    
    modifier onlyAfterInitialization {
        require(isInitialized==true);
        _;
    }
    
    modifier onlyIfIsHolder {
        require(isHolder(msg.sender));
        _;
    }
    
    
    modifier paymentExists(uint paymentId) {
        require(payments[paymentId].destination != 0);
        _;
    }

    modifier confirmed(uint paymentId, address holder) {
        require(confirmations[paymentId][holder]);
        _;
    }

    modifier notConfirmed(uint paymentId, address holder) {
        require(!confirmations[paymentId][holder]);
        _;
    }

    modifier notExecuted(uint paymentId) {
        require(payments[paymentId].executed);
        _;
    }

    /* Constructor */
    function Consortium(uint _requiredVotes) public {
        require(requiredVotes<=MAX_PARTICIPATION);
        
        requiredVotes = _requiredVotes;
        isInitialized = false;
    }
    
    /* Public Functions */
    
    function addHolder(string name, address account, uint participation)  
        public onlyDuringInitialization returns (bool initializationComplete) 
        {
        
        require(participation>0);
        require(totalParticipation+participation<=MAX_PARTICIPATION);
        require(holderCount<MAX_OWNER_COUNT);
        require(!isHolder(account));
        
        totalParticipation += participation;
        holderParticipations[account] = participation;
        holderNames[account] = name;
        holderAccounts.push(account);
        
        holderCount++;
        
        if (totalParticipation == MAX_PARTICIPATION)
            isInitialized = true;
            
        return isInitialized;
    }

    function submitPayment(address destination, uint value, string name)
        public
        onlyAfterInitialization 
        onlyIfIsHolder
        returns (uint paymentId)
    {
        require(destination!=0);
        require(value>=0);

        paymentId = paymentCount;
        payments[paymentId] = Payment({
            destination: destination, 
            value: value, 
            name: name, 
            executed: false
        });
        paymentCount += 1;
        PaymentSubmission(holderNames[msg.sender], name, destination, value);
    }

    
    /// @dev Allows an owner to confirm a payment.
    /// @param paymentId Payment ID.
    function confirmPayment(uint paymentId)
        public
        onlyIfIsHolder
        paymentExists(paymentId)
        notConfirmed(paymentId, msg.sender)
    {
        confirmations[paymentId][msg.sender] = true;
        PaymentConfirmationVote(msg.sender, paymentId);
        executePayment(paymentId);
    }

    /// @dev Allows a holder to revoke a confirmation for a payment.
    /// @param paymentId Payment ID.
    function revokeConfirmation(uint paymentId)
        public
        onlyIfIsHolder
        confirmed(paymentId, msg.sender)
        notExecuted(paymentId)
    {
        confirmations[paymentId][msg.sender] = false;
        PaymentRevocationVote(msg.sender, paymentId);
    }

    /// @dev Allows any holder to execute a confirmed payment.
    /// @param paymentId Payment ID.
    function executePayment(uint paymentId)
        public
        onlyIfIsHolder
        confirmed(paymentId, msg.sender)
        notExecuted(paymentId)
    {
        if (isConfirmed(paymentId)) {
            Payment storage py = payments[paymentId];
            py.executed = true;
            if (py.destination.call.value(py.value)())
                PaymentExecution(paymentId);
            else {
                PaymentExecutionFailure(paymentId);
                py.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a payment.
    /// @param paymentId Payment ID.
    /// @return Confirmation status.
    function isConfirmed(uint paymentId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i<holderCount; i++) {
            if (confirmations[paymentId][holderAccounts[i]])
                count += holderParticipations[holderAccounts[i]];
            if (count >= requiredVotes)
                return true;
        }
    }

    /* Fallback */    
    function() payable onlyAfterInitialization public {
        if (msg.value > 0) {
            if (isHolder(msg.sender)) {
                var name = holderNames[msg.sender];
                holderDeposits[msg.sender] += msg.value; // holder deposit accountability
                totalHoldersDepositedAmount += msg.value;
                HolderDeposit(name, msg.value); // Log External Event
            } else {
                ExternalDeposit(msg.sender, msg.value);
            }
        }
    }
    
    /* Call functions */    
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
   
    /* Internal Functions */
    
}