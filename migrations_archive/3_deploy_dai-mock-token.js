const DAIMockToken = artifacts.require("DAIMockToken");

module.exports = function(deployer) {
    deployer.deploy(DAIMockToken);
};
