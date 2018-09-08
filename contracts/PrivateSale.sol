/*
Copyright 2018 Virtual Rehab (http://virtualrehab.co)
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./CustomWhitelist.sol";
import "./TokenPrice.sol";
import "./EtherPrice.sol";
import "./BinanceCoinPrice.sol";
import "./BonusHolder.sol";


///@title Virtual Rehab Private Sale.
///@author Binod Nirvan, Subramanian Venkatesan (http://virtualrehab.co)
///@notice This contract enables contributors to participate in Virtual Rehab Private Sale.
///
///The Virtual Rehab Private Sale provides early investors with an opportunity
///to take part into the Virtual Rehab token sale ahead of the pre-sale and main sale launch.
///All early investors are expected to successfully complete KYC and whitelisting
///to contribute to the Virtual Rehab token sale.
///
///US investors must be accredited investors and must provide all requested documentation
///to validate their accreditation. We, unfortunately, do not accept contributions
///from non-accredited investors within the US along with any contribution
///from China, Republic of Korea, and New Zealand. Any questions or additional information needed
///can be sought by sending an e-mail to investors＠virtualrehab.co.
///
//////Accepted Currencies: Ether, Binance Coin.
contract PrivateSale is TokenPrice, EtherPrice, BinanceCoinPrice, BonusHolder, FinalizableCrowdsale, CustomWhitelist {
  ///@notice The ERC20 token contract of Binance Coin. Must be: 0xB8c77482e45F1F44dE1745F52C74426C631bDD52
  ERC20 public binanceCoin;


  ///@notice The total amount of VRH tokens sold in the private round.
  uint256 public totalTokensSold;

  ///@notice The total amount of VRH tokens allocated for the private sale.
  uint256 public totalSaleAllocation;

  ///@notice The minimum contribution in dollar cent value.
  uint256 public minContributionInUSDCents;

  ///@notice Signifies if the private sale was started.
  bool public initialized;

  event MinimumContributionChanged(uint256 _newContribution, uint256 _oldContribution);
  event SaleInitialized();

  event FundsWithdrawn(address indexed _wallet, uint256 _amount);
  event ERC20Withdrawn(address indexed _contract, uint256 _amount);
  event TokensAllocatedForSale(uint256 _newAllowance, uint256 _oldAllowance);

  ///@notice Creates and constructs this private sale contract.
  ///@param _startTime The date and time of the private sale start.
  ///@param _endTime The date and time of the private sale end.
  ///@param _tokenPriceInCents The price per VRH token in cents.
  ///@param _etherPriceInCents The price of Ether in cents.
  ///@param _binanceCoinPriceInCents The price of Binance coin in cents.
  ///@param _binanceCoin Binance coin contract. Must be: 0xB8c77482e45F1F44dE1745F52C74426C631bDD52.
  ///@param _vrhToken VRH token contract.
  ///@param _minContributionInUSDCents The minimum contribution in dollar cent value.
  constructor(uint256 _startTime, uint256 _endTime, uint256 _tokenPriceInCents, uint256 _etherPriceInCents, uint256 _binanceCoinPriceInCents, ERC20 _binanceCoin, ERC20 _vrhToken, uint256 _minContributionInUSDCents) public
  TimedCrowdsale(_startTime, _endTime)
  Crowdsale(1, msg.sender, _vrhToken)
  TokenPrice(_tokenPriceInCents)
  EtherPrice(_etherPriceInCents)
  BinanceCoinPrice(_binanceCoinPriceInCents)
  BonusHolder(_vrhToken) {
    require(_minContributionInUSDCents > 0);
    //require(address(_binanceCoin) == 0xB8c77482e45F1F44dE1745F52C74426C631bDD52);

    binanceCoin = _binanceCoin;
    minContributionInUSDCents = _minContributionInUSDCents;
  }

  ///@notice Initializes the private sale.
  function initializePrivateSale() external onlyAdmin {
    require(!initialized);

    increaseTokenSaleAllocation();

    initialized = true;

    emit SaleInitialized();
  }

  ///@notice Enables a contributor to contribute using Binance coin.
  function contributeInBNB() external ifWhitelisted(msg.sender) whenNotPaused onlyWhileOpen {
    require(initialized);

    ///Check the amount of Binance coins allowed to (be transferred by) this contract by the contributor.
    uint256 allowance = binanceCoin.allowance(msg.sender, this);

    ///Calculate equivalent amount in dollar cent value.
    uint256 contributionCents  = convertToCents(allowance, binanceCoinPriceInCents);

    ///Check if the contribution can be accepted.
    require(contributionCents  >= minContributionInUSDCents);

    ///Calcuate the amount of tokens per the contribution.
    uint256 numTokens = contributionCents.mul(10**18).div(tokenPriceInCents);

    ///Calcuate the bonus based on the number of tokens and the dollar cent value.
    uint256 bonus = calculateBonus(numTokens, contributionCents);

    require(totalTokensSold.add(numTokens).add(bonus) <= totalSaleAllocation);

    ///Receive the Binance coins immeidately.
    binanceCoin.transferFrom(msg.sender, this, allowance);

    ///Send the VRH tokens to the contributor.
    token.transfer(msg.sender, numTokens);

    ///Assign the bonus to be vested and later withdrawn.
    assignBonus(msg.sender, bonus);

    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
  }

  function setMinimumContribution(uint256 _cents) external whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit MinimumContributionChanged(minContributionInUSDCents, _cents);
    minContributionInUSDCents = _cents;
  }

  ///@notice The equivant dollar amount of each contribution request.
  uint256 private amountInUSDCents;

  ///@notice Additional validation rules before token contribution is actually allowed.
  ///@param _beneficiary The contributor who wishes to purchase the VRH tokens.
  ///@param _weiAmount The amount of Ethers (in wei) wished to contribute.
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal  whenNotPaused ifWhitelisted(_beneficiary) {
    require(initialized);

    amountInUSDCents  = convertToCents(_weiAmount, etherPriceInCents);
    require(amountInUSDCents  >= minContributionInUSDCents);

    ///Continue validating the purchaes.
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  ///@notice This function is automatically called when a contribution request passes all validations.
  ///@dev Overriden to keep track of the bonuses.
  ///@param _beneficiary The contributor who wishes to purchase the VRH tokens.
  ///@param _tokenAmount The amount of tokens wished to purchase.
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    ///amountInUSDCents is set on _preValidatePurchase
    uint256 bonus = calculateBonus(_tokenAmount, amountInUSDCents);

    ///Ensure that the sale does not exceed allocation.
    require(totalTokensSold.add(_tokenAmount).add(bonus) <= totalSaleAllocation);

    ///Assign bonuses so that they can be later withdrawn.
    assignBonus(_beneficiary, bonus);

    ///Update the sum of tokens sold during the private sale.
    totalTokensSold = totalTokensSold.add(_tokenAmount).add(bonus);

    ///Continue processing the purchase.
    super._processPurchase(_beneficiary, _tokenAmount);
  }

  ///@dev Todo: the accuracy of this function needs to be rechecked.
  ///@param _tokenAmount The total amount in VRH tokens.
  ///@param _cents The amount in US dollar cents.
  function calculateBonus(uint256 _tokenAmount, uint256 _cents) public pure returns (uint256) {
    if(_cents >= 25000000) {
      return _tokenAmount.mul(50).div(100);
    } else if(_cents >= 10000000) {
      return _tokenAmount.mul(40).div(100);
    } else if(_cents >=1500000){
      return _tokenAmount.mul(35).div(100);
    } else {
      return 0;
    }
  }

  ///@notice Converts the amount of Ether (wei) or amount of any token having 18 decimal place divisible
  ///to cent value based on the cent price supplied.
  function convertToCents(uint256 _weiAmount, uint256 _priceInCents) public pure returns (uint256) {
    return _weiAmount.mul(_priceInCents).div(10**18);
  }

  ///@notice Calculates the number of VRH tokens for the supplied wei value.
  ///@param _weiAmount The total amount of Ether in wei value.
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(etherPriceInCents).div(tokenPriceInCents);
  }

  ///@dev Used only for test, drop this function before deployment.
  ///@param _weiAmount The total amount of Ether in wei value.
  function getTokenAmountForWei(uint256 _weiAmount) external view returns (uint256) {
    return _getTokenAmount(_weiAmount);
  }

  ///@notice Recalculates and/or reassigns the total tokens allocated for the private sale.
  function increaseTokenSaleAllocation() public whenNotPaused onlyAdmin {
    ///Check the allowance of this contract to spend.
    uint256 allowance = token.allowance(msg.sender, this);

    ///Get the current allocation.
    uint256 current = totalSaleAllocation;

    ///Update the total token allocation for the private sale.
    totalSaleAllocation = totalSaleAllocation.add(allowance);

    ///Transfer (receive) the allocated VRH tokens.
    token.transferFrom(msg.sender, this, allowance);

    emit TokensAllocatedForSale(totalSaleAllocation, current);
  }


  ///@notice Enables the admins to withdraw Binance coin
  ///or any ERC20 token accidentally sent to this contract.
  function withdrawToken(address _token) external onlyAdmin {

    bool isVRH = _token == address(token);
    ERC20 erc20 = ERC20(_token);
    uint256 balance = erc20.balanceOf(this);
    //This stops admins from stealing the allocated bonus of the investors.
    ///The bonus VRH tokens should remain in this contract.
    if(isVRH) {
      balance = balance.sub(bonusRemaining());
    }
    require(erc20.transfer(msg.sender, balance));
    emit ERC20Withdrawn(_token, balance);
  }


  ///@dev Must be called after crowdsale ends, to do some extra finalization work.
  function finalizeCrowdsale() public onlyAdmin {
    require(!isFinalized);
    require(hasClosed());

    uint256 unsold = token.balanceOf(this).sub(bonusProvided);

    if(unsold > 0) {
      token.transfer(msg.sender, unsold);
    }

    emit Finalized();
    isFinalized = true;
  }

  ///@notice Signifies whether or not the private sale has ended.
  ///@return Returns true if the private sale has ended.
  function hasClosed() public view returns (bool) {
    return (totalTokensSold >= totalSaleAllocation) || super.hasClosed();
  }

  ///@dev Reverts the finalization logic.
  ///@notice Use finalizeCrowdsale instead.
  function finalization() internal {
    revert();
  }

  ///@notice Stops the crowdsale contract from sending ethers.
  function _forwardFunds() internal {
    //Swallow
  }

  ///@notice Enables the admins to withdraw Ethers present in this contract.
  function withdrawFunds(uint256 _amount) external whenNotPaused onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);

    emit FundsWithdrawn(msg.sender, _amount);
  }

  function tokenRemainingForSale() public view returns(uint256) {
    return totalSaleAllocation.sub(totalTokensSold);
  }
}
