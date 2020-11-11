pragma solidity ^0.6.6;

import "./ISGRTokenManager.sol";
import "./ISGRTokenInfo.sol";

/**
 * Details of usage of licenced software see here: https://www.sogur.com/software/readme_v1
 */

/**
 * @title Sogur Token.
 * @dev ERC20 compatible.
 * @dev Exchange ETH for SGR.
 * @dev Exchange SGR for ETH.
 */
interface SGRToken {

    /**
     * @dev Return the contract which implements the ISGRTokenManager interface.
     */
    function getSGRTokenManager() external view returns (ISGRTokenManager);

    /**
    * @dev Return the contract which implements ISGRTokenInfo interface.
    */
    function getSGRTokenInfo() external view returns (ISGRTokenInfo);

    /**
    * @dev Return the sgr token name.
    */
    function name() external view returns (string memory);
    /**
     * @dev Return the sgr token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Return the sgr token number of decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Exchange ETH for SGR.
     * @notice Can be executed from externally-owned accounts as well as from other contracts.
     */
    function exchange() external payable;

    /**
     * @dev Initialize the contract.
     * @param _sgaToSGRTokenExchangeAddress the contract address.
     * @param _sgaToSGRTokenExchangeSGRSupply SGR supply for the SGAToSGRTokenExchange contract.
     */
    function init(address _sgaToSGRTokenExchangeAddress, uint256 _sgaToSGRTokenExchangeSGRSupply) external;


    /**
     * @dev Transfer SGR to another account.
     * @param _to The address of the destination account.
     * @param _value The amount of SGR to be transferred.
     * @return Status (true if completed successfully, false otherwise).
     * @notice If the destination account is this contract, then exchange SGR for ETH.
     */
    function transfer(address _to, uint256 _value) external returns (bool);

    /**
     * @dev Transfer SGR from one account to another.
     * @param _from The address of the source account.
     * @param _to The address of the destination account.
     * @param _value The amount of SGR to be transferred.
     * @return Status (true if completed successfully, false otherwise).
     * @notice If the destination account is this contract, then the operation is illegal.
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    /**
     * @dev Deposit ETH into this contract.
     */
    function deposit() external payable;

    /**
     * @dev Withdraw ETH from this contract.
     */
    function withdraw() external;

    /**
     * @dev Mint SGR for SGN holders.
     * @param _value The amount of SGR to mint.
     */
    function mintSgrForSgnHolders(uint256 _value) external;

    /**
     * @dev Transfer SGR to an SGN holder.
     * @param _to The address of the SGN holder.
     * @param _value The amount of SGR to transfer.
     */
    function transferSgrToSgnHolder(address _to, uint256 _value) external;

    /**
     * @dev Transfer ETH to an SGR holder.
     * @param _to The address of the SGR holder.
     * @param _value The amount of ETH to transfer.
     */
    function transferEthToSgrHolder(address _to, uint256 _value) external;

    /**
     * @dev Get the amount of available ETH.
     * @return The amount of available ETH.
     */
    function getEthBalance() external view returns (uint256);

    /**
     * @dev Get the address of the reserve-wallet and the deficient amount of ETH in this contract.
     * @return The address of the reserve-wallet and the deficient amount of ETH in this contract.
     */
    function getDepositParams() external view returns (address, uint256);

    /**
     * @dev Get the address of the reserve-wallet and the excessive amount of ETH in this contract.
     * @return The address of the reserve-wallet and the excessive amount of ETH in this contract.
     */
    function getWithdrawParams() external view returns (address, uint256);

}
