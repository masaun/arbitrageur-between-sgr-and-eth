pragma solidity ^0.6.6;

/**
 * @title SGR Token Info Interface.
 */
interface ISGRTokenInfo {
    /**
     * @return the name of the sgr token.
     */
    function getName() external pure returns (string memory);

    /**
     * @return the symbol of the sgr token.
     */
    function getSymbol() external pure returns (string memory);

    /**
     * @return the number of decimals of the sgr token.
     */
    function getDecimals() external pure returns (uint8);
}
