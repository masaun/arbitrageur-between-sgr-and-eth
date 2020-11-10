# Flash Swap with Sogur

***
## 【Introduction of Flash Swap with Sogur】
- Flash Swap with Sogur
  - This is a solidity smart contract that allows a user to ...


&nbsp;

***

## Setup
### ① Install modules
```
$ npm install
```

<br>

### ② Run ganache-cli
（Please make sure whether port number is `8545` or not）
```
$ ganache-cli
```

<br>

### ③ Compile & migrate contracts
```
$ npm run migrate:local
```

<br>

### ④ Test contracts（※ In progress to implement）
```
$ npm run test:local
```


&nbsp;

***

## 【References】
- Sogur   
  - Smart contract  
    https://github.com/SogurCurrency/smart-contracts

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
