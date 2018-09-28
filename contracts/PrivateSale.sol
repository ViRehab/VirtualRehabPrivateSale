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
import "./CreditsTokenPrice.sol";
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
///Accepted Currencies: Ether, Binance Coin.
contract PrivateSale is TokenPrice, EtherPrice, BinanceCoinPrice, CreditsTokenPrice, BonusHolder, FinalizableCrowdsale, CustomWhitelist {
  ///@notice The ERC20 token contract of Binance Coin. Must be: 0xB8c77482e45F1F44dE1745F52C74426C631bDD52
  ERC20 public binanceCoin;

  ///@notice The ERC20 token contract of Credits Token. Must be: 0x46b9Ad944d1059450Da1163511069C718F699D31
  ERC20 public creditsToken;

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
  ///@param _binanceCoin Binance coin contract. Must be: 0xB8c77482e45F1F44dE1745F52C74426C631bDD52.
  ///@param _creditsToken credits Token contract. Must be: 0x46b9Ad944d1059450Da1163511069C718F699D31.
  ///@param _vrhToken VRH token contract.
  constructor(uint256 _startTime, uint256 _endTime, ERC20 _binanceCoin, ERC20 _creditsToken, ERC20 _vrhToken) public
  TimedCrowdsale(_startTime, _endTime)
  Crowdsale(1, msg.sender, _vrhToken)
  BonusHolder(_vrhToken) {
    //require(address(_binanceCoin) == 0xB8c77482e45F1F44dE1745F52C74426C631bDD52);
    creditsToken = _creditsToken;
    binanceCoin = _binanceCoin;
  }

  ///@notice Initializes the private sale.
  ///@param _etherPriceInCents Ether Price in cents
  ///@param _tokenPriceInCents VRHToken Price in cents
  ///@param _binanceCoinPriceInCents Binance Coin Price in cents
  ///@param _creditsTokenPriceInCents Credits Token Price in cents
  ///@param _minContributionInUSDCents The minimum contribution in dollar cent value
  function initializePrivateSale(uint _etherPriceInCents, uint _tokenPriceInCents, uint _binanceCoinPriceInCents, uint _creditsTokenPriceInCents, uint _minContributionInUSDCents) external onlyAdmin {
    require(!initialized);
    require(_etherPriceInCents > 0);
    require(_tokenPriceInCents > 0);

    setEtherPrice(_etherPriceInCents);
    setTokenPrice(_tokenPriceInCents);
    setBinanceCoinPrice(_binanceCoinPriceInCents);
    setCreditsTokenPrice(_creditsTokenPriceInCents);
    setMinimumContribution(_minContributionInUSDCents);

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
    uint256 contributionCents  = convertToCents(allowance, binanceCoinPriceInCents, 18);

    ///Check if the contribution can be accepted.
    require(contributionCents  >= minContributionInUSDCents);

    ///Calculate the amount of tokens per the contribution.
    uint256 numTokens = contributionCents.mul(1 ether).div(tokenPriceInCents);

    ///Calculate the bonus based on the number of tokens and the dollar cent value.
    uint256 bonus = calculateBonus(numTokens, contributionCents);

    require(totalTokensSold.add(numTokens).add(bonus) <= totalSaleAllocation);

    ///Receive the Binance coins immediately.
    require(binanceCoin.transferFrom(msg.sender, this, allowance));

    ///Send the VRH tokens to the contributor.
    require(token.transfer(msg.sender, numTokens));

    ///Assign the bonus to be vested and later withdrawn.
    assignBonus(msg.sender, bonus);

    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
  }

  function contributeInCreditsToken() external ifWhitelisted(msg.sender) whenNotPaused onlyWhileOpen {
    require(initialized);

    ///Check the amount of Binance coins allowed to (be transferred by) this contract by the contributor.
    uint256 allowance = creditsToken.allowance(msg.sender, this);

    ///Calculate equivalent amount in dollar cent value.
    uint256 contributionCents = convertToCents(allowance, creditsTokenPriceInCents, 6);

    ///Check if the contribution can be accepted.
    require(contributionCents >= minContributionInUSDCents);

    ///Calculate the amount of tokens per the contribution.
    uint256 numTokens = contributionCents.mul(1 ether).div(tokenPriceInCents);

    ///Calculate the bonus based on the number of tokens and the dollar cent value.
    uint256 bonus = calculateBonus(numTokens, contributionCents);

    require(totalTokensSold.add(numTokens).add(bonus) <= totalSaleAllocation);

    ///Receive the Credits Token immediately.
    require(creditsToken.transferFrom(msg.sender, this, allowance));

    ///Send the VRH tokens to the contributor.
    require(token.transfer(msg.sender, numTokens));

    ///Assign the bonus to be vested and later withdrawn.
    assignBonus(msg.sender, bonus);

    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
  }

  function setMinimumContribution(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit MinimumContributionChanged(minContributionInUSDCents, _cents);
    minContributionInUSDCents = _cents;
  }

  ///@notice The equivalent dollar amount of each contribution request.
  uint256 private amountInUSDCents;

  ///@notice Additional validation rules before token contribution is actually allowed.
  ///@param _beneficiary The contributor who wishes to purchase the VRH tokens.
  ///@param _weiAmount The amount of Ethers (in wei) wished to contribute.
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused ifWhitelisted(_beneficiary) {
    require(initialized);

    amountInUSDCents = convertToCents(_weiAmount, etherPriceInCents, 18);
    require(amountInUSDCents >= minContributionInUSDCents);

    ///Continue validating the purchase.
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  ///@notice This function is automatically called when a contribution request passes all validations.
  ///@dev Overridden to keep track of the bonuses.
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
  function convertToCents(uint256 _tokenAmount, uint256 _priceInCents, uint256 _decimals) public pure returns (uint256) {
    return _tokenAmount.mul(_priceInCents).div(10**_decimals);
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
    require(token.transferFrom(msg.sender, this, allowance));

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
      require(token.transfer(msg.sender, unsold));
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
    //Nothing to do here.
  }

  ///@notice Enables the admins to withdraw Ethers present in this contract.
  function withdrawFunds(uint256 _amount) external whenNotPaused onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);

    emit FundsWithdrawn(msg.sender, _amount);
  }

  function changeClosingTime(uint256 _closingTime) external whenNotPaused onlyAdmin {
    closingTime = _closingTime;
  }

  function tokenRemainingForSale() public view returns(uint256) {
    return totalSaleAllocation.sub(totalTokensSold);
  }
}
