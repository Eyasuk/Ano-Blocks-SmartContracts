const Usdt = artifacts.require("Usdt");

module.exports = function(deployer) {
    deployer.deploy(Usdt,"Tether","USDT");
};
