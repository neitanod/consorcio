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
        //consorcio.call.value(100).gas(1000)();
        //consorcio.transfer(amount)(); // dos horas perdidas por el estipendio de gas...
        require(consorcio.call.value(amount)() );

    }

    function voteYes(uint id) public {
        //consorcio.call.value(100).gas(1000)();
        //consorcio.transfer(amount)(); // dos horas perdidas por el estipendio de gas...
        consorcio.confirmPayment(id);
    }

    function() payable public {} 
}
