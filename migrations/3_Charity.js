const Charity = artifacts.require("Charity");

module.exports = function(deployer) {
    deployer.deploy(Charity, "0x9499e4Fcf505a7Cd1886D169197143fc6F661657");
};