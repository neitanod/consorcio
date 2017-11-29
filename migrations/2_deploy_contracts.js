var Consortium = artifacts.require("Consortium");
var TestUser = artifacts.require("TestUser");

module.exports = function(deployer) {
  /* 
  deployer.deploy(Consortium).then(function() {
    return deployer.deploy(TestUser, Consortium.address);
  });
  */
  deployer.deploy(Consortium);
};
