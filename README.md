# Arbitrageur between SGR (Sögur Token) and ETH
## 【Introduction of Arbitrageur between SGR (Sögur Token) and ETH】
- This is a solidity smart contract that allows a user to get a opportunity to execute automatic arbitrage between SGR (Sögur token) and ETH.


&nbsp;

***

## 【Workflow】
![【Diagram】Arbitrageur btw Sogur and Uniswap](https://user-images.githubusercontent.com/19357502/100517139-02808a80-31cc-11eb-8b6a-dae2bfe99846.jpg)

&nbsp;

***

## 【Setup】
### ① Add `.env` file
- Based on `.env.example` , you add  `.env` file

<br>

### ② Install modules
```
$ npm install
```

<br>

### ③ Compile & migrate contracts (on Ropsten testnet)
```
$ npm run migrate:ropsten
```

<br>

### ④ Execute script (it's instead of testing)
```
$ npm run script:arbitrage
```

&nbsp;

***

## 【Remarks】
- Before you exeute script (Step④ above), you need to whitelisted by Sogur support. (When you execute script on Ropsten)


&nbsp;


***

## 【References】
- Sögur 
  - Smart contract  
    https://github.com/SogurCurrency/smart-contracts  

  - Deployed contract address (on Mainnet and Ropsten)  
    https://github.com/SogurCurrency/Gitcoin-hackathon/issues/2

  - Gitcoin bounty: Arbitrage Profit By Transacting In Both Uniswap And Sögur’s Smart Contract  
    https://gitcoin.co/issue/SogurCurrency/Gitcoin-hackathon/4/100024001  

<br>

- Uniswap 
  - Flash Swap  
    https://uniswap.org/docs/v2/core-concepts/flash-swaps/  

  - Flash Swaps for developers  
    https://uniswap.org/docs/v2/smart-contract-integration/using-flash-swaps/     

  - ExampleFlashSwap.sol  
    https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/examples/ExampleFlashSwap.sol  

  - FlashSwap example  
    https://github.com/Austin-Williams/uniswap-flash-swapper  
