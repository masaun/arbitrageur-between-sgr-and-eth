const ArbitrageurBtwSogurAndUniswap = artifacts.require("ArbitrageurBtwSogurAndUniswap");

module.exports = function(deployer) {
    deployer.deploy(ArbitrageurBtwSogurAndUniswap);
};
