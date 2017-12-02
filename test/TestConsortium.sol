pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./TestUser.sol";
import "./ThrowProxy.sol";

contract TestConsortium {
    uint public initialBalance = 10000;

    //Consortium consorcio = Consortium(DeployedAddresses.Consortium());    
    Consortium consorcio;
    TestUser user1;
    TestUser user2;
	TestUser user3;
    TestUser externalUser;

    function beforeAll() public {
        consorcio = new Consortium(5100); // 51% mayority rule
        
        user1 = new TestUser();
        user1.setConsorcio(consorcio);
        user1.transfer(1000);

        user2 = new TestUser();
        user2.setConsorcio(consorcio);
        user2.transfer(1000);

		user3 = new TestUser();
        user3.setConsorcio(consorcio);
        user3.transfer(1000);
		
        externalUser = new TestUser();
        externalUser.setConsorcio(consorcio);
        externalUser.transfer(1000);    
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

        consorcio.addHolder("Juan", address(user1), 3000); // Juan = 30%
        consorcio.addHolder("Jose", address(user2), 3000); // Jose = 30%

        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be false");        

        consorcio.addHolder("Pedro", address(user3), 4000); // Pedro = 40%  
		
		// 30% + 30% +40% = 100% => el consorcio ya deberia haber finalizado la inicializacion.
        expected = true;
		
        Assert.equal(consorcio.isInitialized(), expected, "Initialized should be true");
    }

    function testHasFunds() public {
        Assert.isNotZero(this.balance, "I should have balance.");
    }

    function testShouldAcceptFundingAfterInit() public {
        Assert.isNotZero(user1.balance, "User1 should have balance or else the test is invalid.");
        Assert.isZero(consorcio.balance, "Consorcio balance should be zero.");

        user1.pay(100); // SteakHolder Deposit 
		
        Assert.isNotZero(consorcio.balance, "Balance should not be zero."); 
        Assert.equal(consorcio.balance, 100, "Balance should 100."); 

        Assert.equal(consorcio.totalHoldersDepositedAmount(), 100, "totalHoldersDepositedAmount should 100."); 
    }

    function testShouldAcceptFundingAfterInit2() public {
        user2.pay(100);
        Assert.equal(consorcio.balance, 200, "Balance should 200."); 
        Assert.equal(consorcio.totalHoldersDepositedAmount(), 200, "Money paid by stakeholders (totalHoldersDepositedAmount) should 200."); 
        
        // Simulate a third party payment, (i.e. tax return, bank withrawal, or anything else that is not change the % invested by each stakeholder)
		externalUser.pay(20);
		
        Assert.equal(consorcio.balance, 220, "Balance should 220."); 
        Assert.equal(consorcio.totalHoldersDepositedAmount(), 200, "Money paid by stakeholders (totalHoldersDepositedAmount) should 200."); 
    }

	function testNotAnyoneCanSubmitPayment() public {
        
	    ThrowProxy throwProxy = new ThrowProxy(address(externalUser)); // http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
        TestUser(address(throwProxy)).submitPayment(address(externalUser), 100, "Electricidad");
		
		bool success = throwProxy.execute.gas(200000)();
        Assert.isFalse(success, "Should be false, as it should throw");
    }
	
    function testSubmitPayment() public {
        var id = user1.submitPayment.gas(1000000)(address(externalUser), 100, "Electricidad");
        Assert.equal(id, 0, "should be the first payment!"); 
    }

    function testPaymentApproval1() public {
        uint id=0;   
        user1.confirmPayment(id);

        bool isApproved = consorcio.isConfirmed.gas(1000000)(id);        
        Assert.equal(isApproved, false, "should not be approved."); 
	}
	    
	function testPaymentApproval2() public {
        uint id=0;
        user2.confirmPayment(id); // now user2 also vote yes, so, it should be approved

        bool isApproved = consorcio.isConfirmed.gas(1000000)(id);        
        Assert.equal(isApproved, true, "now should be approved"); 
    }

    function testPaymentExecution() public {
        uint id=0;
        var balanceAnterior = externalUser.balance;
        
        user1.executePayment.gas(100000000)(id);
        Assert.equal(balanceAnterior+100, externalUser.balance, "Target User Balance should have been increased by 100."); 
    }      
}
