const FlashSwapHelper = artifacts.require("FlashSwapHelper");

//@dev - Import from exported file
var contractAddressList = require('./addressesList/contractAddress/contractAddress.js');
var tokenAddressList = require('./addressesList/tokenAddress/tokenAddress.js');
var walletAddressList = require('./addressesList/walletAddress/walletAddress.js');

const _uniswapV2Pair = contractAddressList["Ropsten"]["Uniswap"]["UniswapV2Pair"];  /// Empty now
const _uniswapV2Router01 = contractAddressList["Ropsten"]["Uniswap"]["UniswapV2Router01"];
const _uniswapV2Router02 = contractAddressList["Ropsten"]["Uniswap"]["UniswapV2Router02"];
const _sgrToken = contractAddressList["Ropsten"]["Sogur"]["SGRToken"];

module.exports = function(deployer) {
    deployer.deploy(FlashSwapHelper, _uniswapV2Pair, _uniswapV2Router01, _uniswapV2Router02, _sgrToken);
};
