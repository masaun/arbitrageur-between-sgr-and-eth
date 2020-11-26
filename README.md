# Flash Swap with Sogur

***
## 【Introduction of Flash Swap with Sogur】
- Flash Swap with Sogur
  - This is a solidity smart contract that allows a user to get a opportunity to execute automatic arbitrage between ETH and SGR (Sogur token).


&nbsp;

***

## Setup
### ① Install modules
```
$ npm install
```

<br>

### ② Compile & migrate contracts (on Ropsten testnet)
```
$ npm run migrate:ropsten
```

<br>

### ③ Execute script (it's instead of testing)
```
$ npm run script:arbitrage
```

&nbsp;

***

## 【References】
- Sogur   
  - Smart contract  
    https://github.com/SogurCurrency/smart-contracts  

  - Gitcoin bounty: Arbitrage Profit By Transacting In Both Uniswap And Sogur’s Smart Contract  
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
