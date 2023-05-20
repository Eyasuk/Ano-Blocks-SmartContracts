const Etbc = artifacts.require("Etbc");

module.exports = function(deployer) {
    deployer.deploy(Etbc,5777);
};
