require('dotenv').config();

const Tx = require('ethereumjs-tx').Transaction;
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider(`https://kovan.infura.io/v3/${ process.env.INFURA_KEY }`);
const web3 = new Web3(provider);

/* Wallet */
const walletAddress1 = process.env.WALLET_ADDRESS;
const privateKey1 = process.env.PRIVATE_KEY;

/* Global variable */
let ArbitrageurBtwSogurAndUniswap = {};
ArbitrageurBtwSogurAndUniswap = require("../../build/contracts/ArbitrageurBtwSogurAndUniswap.json");

/* Set up contract */
arbitrageurBtwSogurAndUniswapABI = ArbitrageurBtwSogurAndUniswap.abi;
arbitrageurBtwSogurAndUniswapAddr = ArbitrageurBtwSogurAndUniswap["networks"]["3"]["address"];    /// Deployed address on Ropsten
arbitrageurBtwSogurAndUniswap = new web3.eth.Contract(ArbitrageurBtwSogurAndUniswapABI, ArbitrageurBtwSogurAndUniswapAddr);


/***
 * @notice - Execute all methods
 **/
async function main() {
    await buySGR();
}
main();


/*** 
 * @dev - Send mintAuthToken() of NftAuthToken contract 
 **/
async function buySGR() {
    const arbitrageId = 1;
    let inputData1 = await arbitrageurBtwSogurAndUniswa.methods.buySGR(arbitrageId).encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, arbitrageurBtwSogurAndUniswapAddr, inputData1)
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
            value:    web3.utils.toHex(web3.utils.toWei('0', 'ether')),
            gasLimit: web3.utils.toHex(2100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('6', 'gwei')),
            data: inputData  
        }
        console.log('=== txObject ===', txObject)

        /// Sign the transaction
        privateKey = Buffer.from(privateKey, 'hex');
        let tx = new Tx(txObject, { 'chain': 'kovan'});  /// Chain ID = kovan
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
