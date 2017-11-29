pragma solidity ^0.4.11;

import "../Contracts/Consortium.sol";

contract TestUser {

    Consortium consorcio;
    
    function setConsorcio(address _address) public {
        consorcio = Consortium(_address);
    }

    function pay(uint amount) public {
        consorcio.transfer(amount);
    }

    function() payable public {}
}
