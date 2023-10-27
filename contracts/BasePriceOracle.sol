pragma solidity ^0.5.16;

import "./PriceOracle.sol";
import "./CErc20.sol";

contract BasePriceOracle is PriceOracle {
    mapping(address => uint) prices;
    address public provider;
    event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);

	constructor() public {
		provider = msg.sender;
	}

    modifier onlyProvider() {
        require(provider == msg.sender, 'not provider: wut?');
        _;
    }
    function setProvider(address newProvider) public onlyProvider {
		provider = newProvider;
	}

    function _getUnderlyingAddress(CToken cToken) internal view returns (address) {
        address asset;
        if (compareStrings(cToken.symbol(), "cEther")) {
            asset = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else {
            asset = address(CErc20(address(cToken)).underlying());
        }
        return asset;
    }

    function getUnderlyingPrice(CToken cToken) external view returns (uint) {
        return prices[_getUnderlyingAddress(cToken)];
    }

    function setUnderlyingPrice(CToken cToken, uint underlyingPriceMantissa) public onlyProvider {
        address asset = _getUnderlyingAddress(cToken);
        emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
        prices[asset] = underlyingPriceMantissa;
    }

    function setDirectPrice(address asset, uint price) public onlyProvider {
        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    // v1 price oracle interface for use as backing of proxy
    function assetPrices(address asset) external view returns (uint) {
        return prices[asset];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
