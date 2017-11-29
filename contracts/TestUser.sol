pragma solidity ^0.4.11;

import "./Consortium.sol";

contract TestUser {
    uint public initialBalance = 1 ether;

    Consortium consorcio;
    
    function setConsorcio(address _address) public {
        consorcio = Consortium(_address);
    }

    function pay() public {
        consorcio.transfer(10);
    }

    function() payable public {}
}
