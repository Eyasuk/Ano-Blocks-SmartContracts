const Ether = artifacts.require("Ether");

module.exports = function(deployer) {
    deployer.deploy(Ether,"Ether","ETH");
};
