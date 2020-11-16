pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import './FlashSwapHelper.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol';
import './sogur/interfaces/ISGRToken.sol';

/***
 * @notice - This contract that ...
 **/
contract ArbitrageurBtwSogurAndUniswap {
    FlashSwapHelper immutable flashSwapHelper;
    IUniswapV2Router02 immutable uniswapV2Router02;
    ISGRToken immutable SGRToken;

    constructor(address payable _flashSwapHelper, address _uniswapV2Router02, address _sgrToken) public {
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
    function ExecuteArbitrageByBuying(uint SGRAmount) public returns (bool) {
        /// Buy SGR tokens on the SGR contract and Swap SGR tokens for ETH on the Uniswap
        buySGR();
        swapSGRForETH(SGRAmount);

        /// Repay ETH for the SGR contract and transfer profit of ETH (remained ETH) into a user
        repayETHForSGRContract();
        transferProfitETHToUser();
    }

    /***
     * @notice - Executor of flash swap for arbitrage profit (2: by using the flow of selling)
     **/
    function ExecuteArbitrageBySelling(address sender, uint amount0, uint amount1, bytes memory data) public returns (bool) {
        /// Sell SGR tokens on the SGR contract and Swap ETH for SGR tokens on the Uniswap
        sellSGR();
        swapETHForSGR(ETHAmount);

        /// Repay SGR tokens for the SGR contract and transfer profit of SGR tokens (remained SGR tokens) into a user
        repaySGRForSGRContract();
        transferProfitSGRToUser();
    }


    ///------------------------------------------------------------
    /// Parts of workflow of Flash Swap (1st part)
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
    function swapSGRForETH(uint SGRAmount) public returns (bool) {
        flashSwapHelper.swapSGRForETH(SGRAmount);
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
    function swapETHForSGR(address sender, uint amount0, uint amount1, bytes memory data) public returns (bool) {
        flashSwapHelper.swapETHForSGR(ETHAmount);
        //flashSwapHelper.uniswapV2Call(sender, amount0, amount1, data);
    }


    ///------------------------------------------------------------
    /// Parts of workflow of Flash Swap (2nd part)
    ///------------------------------------------------------------

    /***
     * @notice - Repay ETH for the SGR contract and transfer profit of ETH (remained ETH) into a user
     **/
    function repayETHForSGRContract() public returns (bool) {}

    function transferProfitETHToUser() public returns (bool) {}

    /***
     * @notice - Repay SGR tokens for the SGR contract and transfer profit of SGR tokens (remained SGR tokens) into a user
     **/
    function repaySGRForSGRContract() public returns (bool) {}

    function transferProfitSGRToUser() public returns (bool) {}



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
