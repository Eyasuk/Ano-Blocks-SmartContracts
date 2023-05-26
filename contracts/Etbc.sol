// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Etbc is ERC20, Pausable, Ownable {
    IERC20 public collateralToken;
    uint256 public collateralRatio;
    uint256 public constant COLLATERAL_RATIO_PRECISION = 1e6;

    event Mint(
        address indexed to,
        uint256 collateralAmount,
        uint256 stablecoinAmount
    );
    event Redeem(
        address indexed from,
        uint256 collateralAmount,
        uint256 stablecoinAmount
    );

    constructor(IERC20 _collateralToken, uint256 _collateralRatio)
        ERC20("Etbc Stablecoin", "ETBC")
    {
        collateralToken = _collateralToken;
        collateralRatio = _collateralRatio;
    }

    function setCollateralRatio(uint256 _collateralRatio) external onlyOwner {
        collateralRatio = _collateralRatio;
    }

    function mint(uint256 collateralAmount) external whenNotPaused {
        require(collateralAmount > 0, "Invalid collateral amount");

        uint256 stablecoinAmount = calculateStablecoinAmount(collateralAmount);

        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );
        _mint(msg.sender, stablecoinAmount);

        emit Mint(msg.sender, collateralAmount, stablecoinAmount);
    }

    function mintForDeposit(uint256 collateralAmount, address user)
        external
        whenNotPaused
    {
        require(collateralAmount > 0, "Invalid collateral amount");

        uint256 stablecoinAmount = calculateStablecoinAmount(collateralAmount);

        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );
        _mint(user, stablecoinAmount);

        emit Mint(user, collateralAmount, stablecoinAmount);
    }

    function redeem(uint256 stablecoinAmount) external whenNotPaused {
        require(stablecoinAmount > 0, "Invalid stablecoin amount");

        uint256 collateralAmount = calculateCollateralAmount(stablecoinAmount);

        _burn(msg.sender, stablecoinAmount);
        collateralToken.transfer(msg.sender, collateralAmount);

        emit Redeem(msg.sender, collateralAmount, stablecoinAmount);
    }

    function calculateStablecoinAmount(uint256 collateralAmount)
        public
        view
        returns (uint256)
    {
        return
            (collateralAmount * collateralRatio) / COLLATERAL_RATIO_PRECISION;
    }

    function calculateCollateralAmount(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        return
            (stablecoinAmount * COLLATERAL_RATIO_PRECISION) / collateralRatio;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
