/////////////////////////////////
/// Testing on the local
////////////////////////////////

require('dotenv').config();

const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8545'));

/// FlashSwapWithSogur contract instance
let FlashSwapWithSogur = {};
FlashSwapWithSogur = artifacts.require("FlashSwapWithSogur");

const FLASHSWAP_WITH_SOGUR_ABI = FlashSwapWithSogur.abi;
const FLASHSWAP_WITH_SOGUR = FlashSwapWithSogur.address;
let flashSwapWithSogur = new web3.eth.Contract(FLASHSWAP_WITH_SOGUR_ABI, FLASHSWAP_WITH_SOGUR);


/// DAI (mock) contract instance
let DAI = {};
DAI = artifacts.require("DAIMockToken");

const DAI_ABI = DAI.abi;
const DAI_ADDRESS = DAI.address;
let dai = new web3.eth.Contract(DAI_ABI, DAI_ADDRESS);


/***
 * @dev - [Execution]: $ truffle test ./test/test-local/ArbitrageurBtwSogurAndUniswap.test --network local
 **/
contract("ArbitrageurBtwSogurAndUniswap contract", function (accounts) {

    /// Set up wallet
    let walletAddress1 = accounts[0];
    let walletAddress2 = accounts[1];

	it('', async () => {

        assert.equal();
    });

});
