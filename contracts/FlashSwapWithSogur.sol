pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import './FlashSwapHelper.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol';
import './sogur/interfaces/ISGRToken.sol';

/***
 * @notice - This contract that ...
 **/
contract FlashSwapWithSogur {
    FlashSwapHelper immutable flashSwapHelper;
    IUniswapV2Router02 immutable uniswapV2Router02;
    ISGRToken immutable SGRToken;

    constructor(address _flashSwapHelper, address _uniswapV2Router02, address _sgrToken) public {
        flashSwapHelper = FlashSwapHelper(_flashSwapHelper);
        uniswapV2Router02 = IUniswapV2Router02(_uniswapV2Router02);
        SGRToken = ISGRToken(_sgrToken);
    }


    ///------------------------------------------------------------
    /// In advance, add a pair (SGR - ETH) liquidity into Uniswap Pool (and create factory contract address)
    ///------------------------------------------------------------

    /***
     * @notice - Add a pair (SGR - ETH) liquidity into Uniswap Pool (and create factory contract address)
     **/
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public returns (bool) {
        uniswapV2Router02.addLiquidityETH(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
    }
    

    ///------------------------------------------------------------
    /// Workflow of Flash Swap
    ///------------------------------------------------------------

    /***
     * @notice - Executor of flash swap for arbitrage profit (1: by using the flow of buying)
     **/
    function arbitrageByBuyingExecutor() public returns (bool) {
        buySGR();
        swapSGRForETH();
    }

    /***
     * @notice - Executor of flash swap for arbitrage profit (2: by using the flow of selling)
     **/
    function arbitrageBySellingExecutor(address sender, uint amount0, uint amount1, bytes memory data, address pairAddress0, address pairAddress1) public returns (bool) {
        sellSGR();
        swapETHForSGR(sender, amount0, amount1, data, pairAddress0, pairAddress1);
    }


    ///------------------------------------------------------------
    /// Parts of workflow of Flash Swap
    ///------------------------------------------------------------

    /***
     * @notice - Buying SGR from Sögur's smart contract (by sending ETH to it)
     **/
    function buySGR() public returns (bool) {
        SGRToken.exchange();
    }

    /***
     * @notice - Swap the received SGR back to ETH on Uniswap
     **/    
    function swapSGRForETH() public returns (bool) {

    }
    
    /***
     * @notice - Selling SGR for ETH from Sögur's smart contract
     **/
    function sellSGR() public returns (bool) {
        SGRToken.withdraw();  /// [ToDo]: withdraw method is for that ETH is transferred
    }

    /***
     * @notice - Swap the received ETH back to SGR on Uniswap (ETH - SGR)
     **/    
    function swapETHForSGR(address sender, uint amount0, uint amount1, bytes memory data, address pairAddress0, address pairAddress1) public returns (bool) {
        flashSwapHelper.uniswapV2Call(sender, amount0, amount1, data);
    }    



    ///------------------------------------------------------------
    /// Internal functions
    ///------------------------------------------------------------



    ///------------------------------------------------------------
    /// Getter functions
    ///------------------------------------------------------------



    ///------------------------------------------------------------
    /// Private functions
    ///------------------------------------------------------------


}
