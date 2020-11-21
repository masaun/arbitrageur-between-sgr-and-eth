pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import { SafeMathOpenZeppelin } from "./libraries/SafeMathOpenZeppelin.sol";

import './FlashSwapHelper.sol';
import './sogur/interfaces/ISGRToken.sol';
import './sogur/interfaces/ISGRAuthorizationManager.sol';


/***
 * @notice - This contract that new version of ArbitrageurBtwSogurAndUniswap.sol
 **/
contract ArbitrageurBtwSogurAndUniswap {
    using SafeMathOpenZeppelin for uint;

    /// Arbitrage ID
    uint public currentArbitrageId;

    /// Mapping for saving bought amount and sold amount
    mapping (uint => mapping (address => uint)) ethAmountWhenBuySGR;   /// Key: arbitrageId -> userAddress -> ETH amount that was transferred for buying SGRToken
    mapping (uint => mapping (address => uint)) sgrAmountWhenSellSGR;  /// Key: arbitrageId -> userAddress -> SGR amount that was transferred for selling SGRToken

    FlashSwapHelper immutable flashSwapHelper;
    ISGRToken immutable SGRToken;
    ISGRAuthorizationManager immutable SGRAuthorizationManager;

    address payable FLASH_SWAP_HELPER;
    address SGR_TOKEN;

    constructor(address payable _flashSwapHelper, address _sgrToken, address _sgrAuthorizationManager) public {
        flashSwapHelper = FlashSwapHelper(_flashSwapHelper);
        SGRToken = ISGRToken(_sgrToken);
        SGRAuthorizationManager = ISGRAuthorizationManager(_sgrAuthorizationManager);

        FLASH_SWAP_HELPER = _flashSwapHelper;
        SGR_TOKEN = _sgrToken;
    }


    ///------------------------------------------------------------
    /// Workflow of arbitrage
    ///------------------------------------------------------------

    /***
     * @notice - Executor of flash swap for arbitrage profit (1: by using the flow of buying)
     **/
    function executeArbitrageByBuying(address payable userAddress, uint SGRAmount) public returns (bool) {
        /// Publish new arbitrage ID
        uint newArbitrageId = getNextArbitrageId();
        currentArbitrageId++;

        /// Buy SGR tokens on the SGR contract and Swap SGR tokens for ETH on the Uniswap
        buySGR(newArbitrageId);
        swapSGRForETH(userAddress, SGRAmount);
    }

    /***
     * @notice - Executor of flash swap for arbitrage profit (2: by using the flow of selling)
     **/
    function executeArbitrageBySelling(address payable userAddress, uint SGRAmount) public returns (bool) {
        /// Publish new arbitrage ID
        uint newArbitrageId = getNextArbitrageId();
        currentArbitrageId++;

        /// Sell SGR tokens on the SGR contract and Swap ETH for SGR tokens on the Uniswap
        sellSGR(newArbitrageId, SGRAmount);
        swapETHForSGR(userAddress, SGRAmount);
    }


    ///------------------------------------------------------------
    /// Parts of workflow of arbitrage (1st part)
    ///------------------------------------------------------------

    /***
     * @notice - Buying SGR from Sögur's smart contract (by sending ETH to it)
     **/
    function buySGR(uint arbitrageId) public payable returns (bool) {
        /// At the 1st, ETH should be transferred from a user's wallet to this contract

        /// At the 2rd, operations below are executed.
        SGRToken.exchange();  /// Exchange ETH for SGR.
        ethAmountWhenBuySGR[arbitrageId][msg.sender] = msg.value;  /// [Note]: Save the ETH amount that was transferred for buying SGRToken 
    }

    /***
     * @notice - Swap the received SGR back to ETH on Uniswap
     **/
    function swapSGRForETH(address payable userAddress, uint SGRAmount) public returns (bool) {
        /// Transfer SGR tokens from this contract to the FlashSwapHelper contract 
        SGRToken.transfer(FLASH_SWAP_HELPER, SGRAmount);

        /// Execute swap
        flashSwapHelper.swapSGRForETH(userAddress, SGRAmount);
    }
    
    /***
     * @notice - Selling SGR for ETH from Sögur's smart contract
     * @dev - Only specified the contract address of SGRToken.sol as a "to" address in transferFrom() method of SGRToken.sol
     **/
    function sellSGR(uint arbitrageId, uint SGRAmount) public returns (bool) {
        /// At the 1st, SGR tokens should be transferred from a user's wallet to this contract by using transfer() method. 

        /// At the 2rd, operation below is executed
        SGRToken.transferFrom(msg.sender, address(this), SGRAmount); /// [Note]: SGR exchanged with ETH via transferFrom() method
        sgrAmountWhenSellSGR[arbitrageId][msg.sender] = SGRAmount;   /// [Note]: Save the SGR amount that was transferred for selling SGRToken
    }

    /***
     * @notice - Swap the received ETH back to SGR on Uniswap (ETH - SGR)
     **/    
    function swapETHForSGR(address userAddress, uint SGRAmount) public payable returns (bool) {
        /// Transfer ETH from this contract to the FlashSwapHelper contract 
        FLASH_SWAP_HELPER.transfer(msg.value);

        /// Execute swap
        flashSwapHelper.swapETHForSGR(userAddress, SGRAmount);
    }



    ///------------------------------------------------------------
    /// Internal functions
    ///------------------------------------------------------------



    ///------------------------------------------------------------
    /// Getter functions
    ///------------------------------------------------------------

    function getEthAmountWhenBuySGR(uint arbitrageId, address userAddress) public view returns (uint _ethAmountWhenBuySGR) {
        return ethAmountWhenBuySGR[arbitrageId][userAddress];
    }    

    function getSgrAmountWhenSellSGR(uint arbitrageId, address userAddress) public view returns (uint _sgrAmountWhenSellSGR) {
        return sgrAmountWhenSellSGR[arbitrageId][userAddress];
    }


    ///------------------------------------------------------------
    /// Private functions
    ///------------------------------------------------------------

    function getNextArbitrageId() private view returns (uint nextArbitrageId) {
        return currentArbitrageId.add(1);
    }


}
