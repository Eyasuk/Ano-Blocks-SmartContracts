const Etbc = artifacts.require("Etbc");

module.exports = function(deployer) {
    deployer.deploy(Etbc,"0xc9572565Bf72C5fBBecf317681482dd42761eBba",250000000);
};
