require('dotenv').config();

const Tx = require('ethereumjs-tx').Transaction;
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider(`https://ropsten.infura.io/v3/${ process.env.INFURA_KEY }`);
const web3 = new Web3(provider);

/* Wallet */
const walletAddress1 = process.env.WALLET_ADDRESS_1;
const privateKey1 = process.env.PRIVATE_KEY_1;

/* Import contract addresses */
let contractAddressList = require('../addressesList/contractAddress/contractAddress.js');

/* Set up contract */
let ArbitrageurBtwSogurAndUniswap = {};
ArbitrageurBtwSogurAndUniswap = require("../../build/contracts/ArbitrageurBtwSogurAndUniswap.json");
arbitrageurBtwSogurAndUniswapABI = ArbitrageurBtwSogurAndUniswap.abi;
arbitrageurBtwSogurAndUniswapAddr = "0x58eA9C155ace1a7549F709f8a2B1DA00Aca53cfd";  /// Deployed address on Ropsten
//arbitrageurBtwSogurAndUniswapAddr = ArbitrageurBtwSogurAndUniswap["networks"]["3"]["address"];    /// Deployed address on Ropsten
arbitrageurBtwSogurAndUniswap = new web3.eth.Contract(arbitrageurBtwSogurAndUniswapABI, arbitrageurBtwSogurAndUniswapAddr);

let SGRAuthorizationManager = {};
SGRAuthorizationManager = require("../../build/contracts/ISGRAuthorizationManager.json");
sgrAuthorizationManagerABI = SGRAuthorizationManager.abi;
sgrAuthorizationManagerAddr = contractAddressList["Ropsten"]["Sogur"]["SGRAuthorizationManager"];
sgrAuthorizationManager = new web3.eth.Contract(sgrAuthorizationManagerABI, sgrAuthorizationManagerAddr);


let SGRToken = {};
SGRToken = require("../../build/contracts/ISGRToken.json");
sgrTokenABI = SGRToken.abi;
sgrTokenAddr = contractAddressList["Ropsten"]["Sogur"]["SGRToken"];
sgrToken = new web3.eth.Contract(sgrTokenABI, sgrTokenAddr);


/***
 * @notice - Execute all methods
 **/
async function main() {
    await depositETHIntoSGRcontract();
    await testBuySGR();
    await buySGR();
}
main();


/*** 
 * @dev - Send mintAuthToken() of NftAuthToken contract 
 **/
async function buySGR() {
    const arbitrageId = 1;
    let inputData1 = await arbitrageurBtwSogurAndUniswap.methods.buySGR(arbitrageId).encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, arbitrageurBtwSogurAndUniswapAddr, inputData1);
}


async function testBuySGR() { /// [Result]: Error "invalid ETH-SDR rate"
    let inputData1 = await sgrToken.methods.exchange().encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, sgrTokenAddr, inputData1);
}


async function depositETHIntoSGRcontract() {  /// [Result]: Success to exchange ETH for SGR
    let inputData1 = await sgrToken.methods.deposit().encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, sgrTokenAddr, inputData1);
}



/***
 * @notice - Sign and Broadcast the transaction
 **/
async function sendTransaction(walletAddress, privateKey, contractAddress, inputData) {
    try {
        const txCount = await web3.eth.getTransactionCount(walletAddress);
        const nonce = await web3.utils.toHex(txCount);
        console.log('=== txCount, nonce ===', txCount, nonce);

        /// Build the transaction
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            from:     walletAddress,
            to:       contractAddress,  /// Contract address which will be executed
            value:    web3.utils.toHex(web3.utils.toWei('0.1', 'ether')),  /// [Note]: 0.1 ETH as a msg.value
            gasLimit: web3.utils.toHex(2100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('100', 'gwei')),   /// [Note]: Gas Price is 100 Gwei 
            data: inputData  
        }
        console.log('=== txObject ===', txObject)

        /// Sign the transaction
        privateKey = Buffer.from(privateKey, 'hex');
        let tx = new Tx(txObject, { 'chain': 'ropsten' });  /// Chain ID = Ropsten
        tx.sign(privateKey);

        const serializedTx = tx.serialize();
        const raw = '0x' + serializedTx.toString('hex');

        /// Broadcast the transaction
        const transaction = await web3.eth.sendSignedTransaction(raw);
        console.log('=== transaction ===', transaction)

        /// Return the result above
        return transaction;
    } catch(e) {
        console.log('=== e ===', e);
        return String(e);
    }
}
