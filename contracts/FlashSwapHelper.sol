pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import './uniswap-v2-core/interfaces/IUniswapV2Callee.sol';
import './uniswap-v2-core/interfaces/IUniswapV2Pair.sol';
import './uniswap-v2-periphery/libraries/UniswapV2Library.sol';
import './uniswap-v2-periphery/interfaces/V1/IUniswapV1Factory.sol';
import './uniswap-v2-periphery/interfaces/V1/IUniswapV1Exchange.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router01.sol';
import './uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol';
import './uniswap-v2-periphery/interfaces/IERC20.sol';
import './uniswap-v2-periphery/interfaces/IWETH.sol';

import './sogur/interfaces/ISGRToken.sol';

/***
 * @notice - This contract that ...
 **/
contract FlashSwapHelper is IUniswapV2Callee {
    IUniswapV2Pair immutable uniswapV2Pair;
    IUniswapV2Router02 immutable uniswapV2Router02;
    IUniswapV1Factory immutable factoryV1;
    IWETH immutable WETH;
    ISGRToken immutable SGRToken;

    address immutable factory;
    address immutable SGR_TOKEN;

    constructor(address _uniswapV2Pair, address _uniswapV2Router02, address _factory, address _factoryV1, address router, address _sgrToken) public {
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        uniswapV2Router02 = IUniswapV2Router02(_uniswapV2Router02);
        factoryV1 = IUniswapV1Factory(_factoryV1);
        factory = _factory;
        WETH = IWETH(IUniswapV2Router01(_uniswapV2Router02).WETH());
        SGRToken = ISGRToken(_sgrToken);

        SGR_TOKEN = _sgrToken; 
    }


    ///------------------------------------------------------------
    /// General Swap on Uniswap v2
    ///------------------------------------------------------------

    /***
     * @notice - Swap SGRToken for ETH (Swap between SGRToken - ETH)
     *         - Ref: https://soliditydeveloper.com/uniswap2
     **/
    function swapSGRForETH(uint SGRAmount) public payable {
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
    function swapETHForSGR(uint SGRAmount) public payable {
        uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint amountOut = SGRAmount;
        uniswapV2Router02.swapETHForExactTokens{ value: msg.value }(amountOut, getPathForETHToSGR(), address(this), deadline);

        /// refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
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
    /// Flash Swap (that reference ExampleFlashSwap.sol)
    ///------------------------------------------------------------

    /***
     * @notice - Swap SGRToken for ETH (Swap between SGRToken - ETH)
     **/
    // needs to accept ETH from any V1 exchange and SGRToken. ideally this could be enforced, as in the router,
    // but it's not possible because it requires a call to the v1 factory, which takes too much gas
    //receive() external payable {}

    // gets tokens/SGRToken via a V2 flash swap, swaps for the ETH/tokens on V1, repays V2, and keeps the rest!
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address[] memory path = new address[](2);
        uint amountToken;  /// [Note]: This is SGR token
        uint amountETH;
    
        { // scope for token{0,1}, avoids stack too deep errors
            address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
            address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
            assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1)); // ensure that msg.sender is actually a V2 pair
            // rest of the function goes here!

            assert(amount0 == 0 || amount1 == 0); // this strategy is unidirectional
            path[0] = amount0 == 0 ? token0 : token1;
            path[1] = amount0 == 0 ? token1 : token0;
            amountToken = token0 == address(SGRToken) ? amount1 : amount0;
            amountETH = token0 == address(SGRToken) ? amount0 : amount1;
        }

        assert(path[0] == address(SGRToken) || path[1] == address(SGRToken)); // this strategy only works with a V2 SGRToken pair
        IERC20 token = IERC20(path[0] == address(SGRToken) ? path[1] : path[0]);
        IUniswapV1Exchange exchangeV1 = IUniswapV1Exchange(factoryV1.getExchange(address(token))); // get V1 exchange

        if (amountToken > 0) {
            (uint minETH) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            token.approve(address(exchangeV1), amountToken);
            uint amountReceived = exchangeV1.tokenToEthSwapInput(amountToken, minETH, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
            assert(amountReceived > amountRequired); // fail if we didn't get enough ETH back to repay our flash loan
            SGRToken.deposit{value: amountRequired}();
            assert(SGRToken.transfer(msg.sender, amountRequired)); // return SGRToken to V2 pair
            (bool success,) = sender.call{value: amountReceived - amountRequired}(new bytes(0)); // keep the rest! (ETH)
            assert(success);
        } else {
            (uint minTokens) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            SGRToken.withdraw();
            uint amountReceived = exchangeV1.ethToTokenSwapInput{value: amountETH}(minTokens, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountETH, path)[0];
            assert(amountReceived > amountRequired); // fail if we didn't get enough tokens back to repay our flash loan
            assert(token.transfer(msg.sender, amountRequired)); // return tokens to V2 pair
            assert(token.transfer(sender, amountReceived - amountRequired)); // keep the rest! (tokens)
        }
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
