pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Consortium.sol";
import "../contracts/TestUser.sol";

contract TestConsortium {
    uint public initialBalance = 1 ether;

    //Consortium consorcio = Consortium(DeployedAddresses.Consortium());    
    Consortium consorcio;
    TestUser user1;

    function beforeAll() public {
        consorcio = new Consortium(5100);
        
        user1 = TestUser(DeployedAddresses.TestUser());
        user1.setConsorcio(consorcio);
        user1.transfer(100);
    }

    function testIsNotInitalized() public {
        bool actual = consorcio.isInitialized();
        bool expected = false;

        Assert.equal(actual, expected, "Initialized should be false");
    }

    function testShouldNotAcceptPaymentIfNotInitilized() public {
        Assert.isNotZero(user1.balance, "User1 should have balance.");
        Assert.isZero(consorcio.balance, "Balance should be zero.");
        
        ThrowProxy throwProxy = new ThrowProxy(address(user1)); 
        TestUser(address(throwProxy)).pay();
        
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be false, as it should throw");
        Assert.isZero(consorcio.balance, "Balance should be zero."); //forced to check in onther
    }


    function testInitialization() public {
        bool expected = false;

        consorcio.addHolder("Juan", address(0x1), 2000);
        consorcio.addHolder("Pedro", address(0x2), 2100);
        consorcio.addHolder("Ramon", address(0x3), 2200);
        consorcio.addHolder("Luis", address(0x4), 2300);
        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be false");        

        consorcio.addHolder("Jorge", address(0x5), 1400);
        expected = true;
        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be true");
    }

    function testPayment() public {
        Assert.isNotZero(user1.balance, "User1 should have balance.");
        Assert.isZero(consorcio.balance, "Balance should be zero.");
        user1.pay();
        Assert.isNotZero(consorcio.balance, "Balance should not be zero."); //forced to check in onther
    }


}


contract ThrowProxy {
  address public target;
  bytes data;

  function ThrowProxy(address _target) public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() public {
    data = msg.data;
  }

  function execute() public returns (bool) {
    return target.call(data);
  }
}


