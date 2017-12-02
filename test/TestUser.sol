pragma solidity ^0.4.11;

import "../Contracts/Consortium.sol";

contract TestUser {

    Consortium consorcio;
    
    function TestUser() public {

    }

    function setConsorcio(address _address) public {
        consorcio = Consortium(_address);
    }

    function pay(uint amount) public {
        //consorcio.transfer(amount)(); // dos horas perdidas por el estipendio de gas...
        //consorcio.call.value(100).gas(1000)();
        require(consorcio.call.value(amount)() );

    }

    function confirmPayment(uint id) public {
        consorcio.confirmPayment(id);
    }
	
    function submitPayment(address payTo, uint amount, string name) public returns (uint) {
        return consorcio.submitPayment(payTo, amount, name);
    }
		
        
    function executePayment(uint paymentId)
        public
    {
        consorcio.executePayment(paymentId);
    }        

    function() payable public {} 
}
