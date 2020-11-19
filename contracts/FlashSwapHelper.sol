pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import './uniswap-v2-core/interfaces/IUniswapV2Pair.sol';
import './uniswap-v2-periphery/libraries/UniswapV2Library.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router01.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol';
import './uniswap-v2-periphery/interfaces/IERC20.sol';
import './uniswap-v2-periphery/interfaces/IWETH.sol';

import './sogur/interfaces/ISGRToken.sol';

/***
 * @notice - This contract that ...
 **/
contract FlashSwapHelper {
    IUniswapV2Router01 public uniswapV2Router01;

    IUniswapV2Pair immutable uniswapV2Pair;
    IUniswapV2Router02 immutable uniswapV2Router02;
    IWETH immutable WETH;
    ISGRToken immutable SGRToken;

    address immutable SGR_TOKEN;

    constructor(address _uniswapV2Pair, address _uniswapV2Router01, address _uniswapV2Router02, address _sgrToken) public {
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        uniswapV2Router01 = IUniswapV2Router01(_uniswapV2Router01);
        uniswapV2Router02 = IUniswapV2Router02(_uniswapV2Router02);
        WETH = IWETH(uniswapV2Router01.WETH());
        SGRToken = ISGRToken(_sgrToken);

        SGR_TOKEN = _sgrToken; 
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
    /// General Swap on Uniswap v2
    ///------------------------------------------------------------

    /***
     * @notice - Swap SGRToken for ETH (Swap between SGRToken - ETH)
     *         - Ref: https://soliditydeveloper.com/uniswap2
     **/
    function swapSGRForETH(address payable userAddress, uint SGRAmount) public payable {
        /// [ToDo]: Should add a method for compute ETHAmountMin
        uint ETHAmountMin;

        /// amountOutMin must be retrieved from an oracle of some kind
        uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint amountIn = SGRAmount;
        uint amountOutMin = ETHAmountMin;  /// [Todo]: Retrieve a minimum amount of ETH
        uniswapV2Router02.swapExactTokensForETH(amountIn, amountOutMin, getPathForSGRToETH(), address(this), deadline);

        /// refund leftover SGRToken to user
        // (bool success,) = msg.sender.call{ value: address(this).balance }("");
        // require(success, "refund failed");

        /// Transfer ETH from this contract to user's wallet
        transferETHIncludeProfitAmountAndInitialAmounToUser(userAddress);
    }
  
    function getEstimatedSGRForETH(uint ETHAmount) public view returns (uint[] memory) {
        uint amountOut = ETHAmount;
        return uniswapV2Router02.getAmountsIn(amountOut, getPathForSGRToETH());
    }

    function getPathForSGRToETH() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = SGR_TOKEN;
        path[1] = uniswapV2Router02.WETH();
        
        return path;
    }
  
    /***
     * @notice - Swap ETH for SGRToken (Swap between ETH - SGRToken)
     **/
    function swapETHForSGR(address userAddress, uint SGRAmount) public payable {
        uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint amountOut = SGRAmount;
        uniswapV2Router02.swapETHForExactTokens{ value: msg.value }(amountOut, getPathForETHToSGR(), address(this), deadline);

        /// Refund leftover ETH to user
        msg.sender.call.value(address(this).balance)("");

        /// Transfer SGR from this contract to user's wallet
        transferSGRIncludeProfitAmountAndInitialAmounToUser(userAddress);
    }
  
    function getEstimatedETHToSGR(uint SGRAmount) public view returns (uint[] memory) {
        uint amountOut = SGRAmount;
        return uniswapV2Router02.getAmountsIn(amountOut, getPathForETHToSGR());
    }

    function getPathForETHToSGR() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router02.WETH();
        path[1] = SGR_TOKEN;
        
        return path;
    }

    /***
     * @notice - important to receive ETH
     **/
    receive() payable external {}


    ///------------------------------------------------------------
    /// Parts of workflow of arbitrage (2nd part)
    ///------------------------------------------------------------

    /***
     * @notice - Transfer ETH that includes profit amount and initial amount into a user.
     **/
    function transferETHIncludeProfitAmountAndInitialAmounToUser(address payable userAddress) public returns (bool) {
        uint ETHBalanceOfContract = address(this).balance;
        userAddress.transfer(ETHBalanceOfContract);  /// Transfer ETH from this contract to userAddress's wallet
    }

    /***
     * @notice - Transfer SGR tokens that includes profit amount and initial amount into a user.
     **/
    function transferSGRIncludeProfitAmountAndInitialAmounToUser(address userAddress) public returns (bool) {
        uint SGRBalanceOfContract = SGRToken.balanceOf(address(this));
        SGRToken.transfer(userAddress, SGRBalanceOfContract);  /// Transfer SGR from this contract to userAddress's wallet        
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
