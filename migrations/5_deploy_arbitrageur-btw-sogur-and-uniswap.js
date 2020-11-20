const ArbitrageurBtwSogurAndUniswap = artifacts.require("ArbitrageurBtwSogurAndUniswap");
const FlashSwapHelper = artifacts.require("FlashSwapHelper");

//@dev - Import from exported file
var contractAddressList = require('./addressesList/contractAddress/contractAddress.js');
var tokenAddressList = require('./addressesList/tokenAddress/tokenAddress.js');
var walletAddressList = require('./addressesList/walletAddress/walletAddress.js');

const _flashSwapHelper = FlashSwapHelper.address;
const _sgrToken = contractAddressList["Ropsten"]["Sogur"]["SGRToken"];
const _sgrAuthorizationManager = contractAddressList["Ropsten"]["Sogur"]["SGRAuthorizationManager"];

module.exports = function(deployer) {
    deployer.deploy(ArbitrageurBtwSogurAndUniswap, _flashSwapHelper, _sgrToken, _sgrAuthorizationManager);
};
