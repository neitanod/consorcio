pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
//import "../contracts/Consortium.sol";
import "./TestUser.sol";
import "./ThrowProxy.sol";

contract TestConsortium {
    uint public initialBalance = 1 ether;

    //Consortium consorcio = Consortium(DeployedAddresses.Consortium());    
    Consortium consorcio;
    TestUser user1;
    TestUser user2;
    TestUser externalUser;

    function beforeAll() public {
        consorcio = new Consortium(5100);
        
        user1 = new TestUser();
        user1.setConsorcio(consorcio);
        user1.transfer(100);

        user2 = new TestUser();
        user2.setConsorcio(consorcio);
        user2.transfer(100);

        externalUser = new TestUser();
        externalUser.setConsorcio(consorcio);
        externalUser.transfer(100);
    }

    function testIsNotInitalized() public {
        bool actual = consorcio.isInitialized();
        bool expected = false;

        Assert.equal(actual, expected, "Initialized should be false");
    }

    function testShouldNotAcceptFundingBeforeInitialized() public {
        Assert.isNotZero(user1.balance, "User1 should have balance.");
        Assert.isZero(consorcio.balance, "Balance should be zero.");
        
        ThrowProxy throwProxy = new ThrowProxy(address(user1)); // http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
        TestUser(address(throwProxy)).pay(100);
        
        bool success = throwProxy.execute.gas(200000)();
        Assert.isFalse(success, "Should be false, as it should throw");
        Assert.isZero(consorcio.balance, "Balance should be zero."); 
    }

    function testInitialization() public {
        bool expected = false;

        consorcio.addHolder("Juan", address(user1), 5100);
        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be false");        

        consorcio.addHolder("Pedro", address(user2), 4900);
        expected = true;
        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be true");
    }

    function testShouldAcceptFundingAfterInit() public {
        Assert.isNotZero(user1.balance, "User1 should have balance.");
        Assert.isZero(consorcio.balance, "Balance should be zero.");

        user1.pay(100);
        Assert.isNotZero(consorcio.balance, "Balance should not be zero."); 
        Assert.equal(consorcio.balance, 100, "Balance should 100."); 

        Assert.equal(consorcio.totalHoldersDepositedAmount(), 100, "totalHoldersDepositedAmount should 100."); 

        user2.pay(100);
        Assert.equal(consorcio.balance, 200, "Balance should 200."); 
        Assert.equal(consorcio.totalHoldersDepositedAmount(), 200, "totalHoldersDepositedAmount should 200."); 
        
        externalUser.pay(20);
        Assert.equal(consorcio.balance, 220, "Balance should 220."); 
        Assert.equal(consorcio.totalHoldersDepositedAmount(), 200, "totalHoldersDepositedAmount should 200."); 
    }


}
