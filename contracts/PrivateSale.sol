pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./CustomWhitelist.sol";
import "./EtherPrice.sol";
import "./BinanceCoinPrice.sol";
import "./BonusHolder.sol";

contract PrivateSale is EtherPrice, BinanceCoinPrice, BonusHolder, FinalizableCrowdsale, CustomWhitelist {
  uint public tokenPrice; //price of the 1 token in cents
  ERC20 public BinanceCoin;
  uint public totalTokensSold;
  uint public bonusTokensSold;
  uint public maxTokensAvailable;
  uint private amountInUSD; // to track the current contribution
  uint public minContributionInUSD; //in cents
  bool public initialized;


  event TokenPriceChanged(uint _newPrice, uint _oldPrice);
  event MinimumContributionChanged(uint _newContribution, uint _oldContribution);
  event SaleInitialized();

  event FundsWithdrawn(uint _amount, address _msgSender);
  event TokensAddedToSale(uint _newAllowance, uint _oldAllowance);


  constructor(uint _startTime, uint _endTime, uint _tokenPrice, uint _etherPriceInCents, uint _binanceCoinPriceInCents, ERC20 _BinanceCoin, ERC20 _token, uint _minContributionInUSD) public
  TimedCrowdsale(_startTime, _endTime) Crowdsale(1, msg.sender, _token)
  EtherPrice(_etherPriceInCents)
  BinanceCoinPrice(_binanceCoinPriceInCents)
  BonusHolder(_token) {
    require(_tokenPrice > 0);
    require(_minContributionInUSD > 0);
    require(_binanceCoinPriceInCents > 0);
    tokenPrice = _tokenPrice;
    binanceCoinPriceInCents = _binanceCoinPriceInCents;
    BinanceCoin = _BinanceCoin;
    minContributionInUSD = _minContributionInUSD;
  }

  function initializePrivateSale() public onlyAdmin {
    require(!initialized);
    increaseMaxTokensForSale();
    initialized = true;
    emit SaleInitialized();
  }

  function setTokenPrice(uint _tokenPrice) public onlyAdmin whenNotPaused {
    require(_tokenPrice > 0);
    emit TokenPriceChanged(_tokenPrice, tokenPrice);
    tokenPrice = _tokenPrice;
  }

  function _forwardFunds() internal {

  }


  function withdrawFunds(uint _amount) public whenNotPaused onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);
    emit FundsWithdrawn(_amount, msg.sender);
  }

  // Binance token contribution
  function contributeInBNB() public isInvestorWhitelisted(msg.sender) whenNotPaused onlyWhileOpen {
    uint allowance = BinanceCoin.allowance(msg.sender, this);
    BinanceCoin.transferFrom(msg.sender, this, allowance);
    amountInUSD = convertToUSD(allowance, binanceCoinPriceInCents);
    require(amountInUSD >= minContributionInUSD);
    uint numTokens = amountInUSD.mul(10**18).div(tokenPrice);
    uint bonus = calculateBonus(numTokens, amountInUSD);
    require(totalTokensSold.add(numTokens).add(bonus) <= maxTokensAvailable);
    token.transfer(msg.sender, numTokens);
    assignBonus(msg.sender, bonus);
    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
    bonusTokensSold = bonusTokensSold.add(bonus);
  }


  // _minContributionInUSD is minimum contribution allowed in cents
  function setMinimumContribution(uint _minContributionInUSD) public whenNotPaused onlyAdmin {
    require(_minContributionInUSD > 0);
    emit MinimumContributionChanged(minContributionInUSD, _minContributionInUSD);
    minContributionInUSD = _minContributionInUSD;
  }

  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    uint bonus = calculateBonus(_tokenAmount, amountInUSD);
    require(totalTokensSold.add(_tokenAmount).add(bonus) <= maxTokensAvailable);
    bonusTokensSold = bonusTokensSold.add(bonus);
    assignBonus(_beneficiary, bonus);
    totalTokensSold = totalTokensSold.add(_tokenAmount).add(bonus);
    super._processPurchase(_beneficiary, _tokenAmount);
  }

  // TODO: change this from hardcoded to an array of bonuses;
  // TODO: change this from hardcoded to an array of bonuses;
 function calculateBonus(uint _tokenAmount, uint _USD) public view returns (uint256) {
   if(_USD >= 25000000) {
     return _tokenAmount.mul(50).div(100);
   } else if(_USD >= 10000000) {
     return _tokenAmount.mul(40).div(100);
   } else if(_USD >=1500000){
     return _tokenAmount.mul(35).div(100);
   } else {
     return 0;
   }
 }

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal  whenNotPaused isInvestorWhitelisted(_beneficiary) {
    require(initialized);
    amountInUSD = convertToUSD(_weiAmount, etherPriceInCents);
    require(amountInUSD >= minContributionInUSD);
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  function convertToUSD(uint _weiAmount, uint costOf1Token) public view returns (uint256) {
    return _weiAmount.mul(costOf1Token).div(10**18);
  }

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(etherPriceInCents).div(tokenPrice);
  }

  function increaseMaxTokensForSale() public whenNotPaused onlyAdmin {
    uint allowance = token.allowance(msg.sender, this);
    uint oldTokensAvailable = maxTokensAvailable;
    maxTokensAvailable = maxTokensAvailable.add(allowance);
    emit TokensAddedToSale(maxTokensAvailable, oldTokensAvailable);
    token.transferFrom(msg.sender, this, allowance);
  }

  function getTokenAmountForWei(uint256 _weiAmount) public view returns (uint256) {
    return _getTokenAmount(_weiAmount);
  }

  function withdrawToken(address _token) public onlyAdmin {
    ERC20 t = ERC20(_token);

    require(t.transfer(msg.sender, t.balanceOf(this)));
  }

  function finalizeCrowdsale() public onlyAdmin {
    require(!isFinalized);
    require(hasClosed());
    uint unsold = token.balanceOf(this).sub(bonusTokensSold);
    if(unsold > 0) {
      token.transfer(msg.sender, unsold);
    }
    emit Finalized();
    isFinalized = true;
  }

  function hasClosed() public view returns (bool) {
    return (totalTokensSold >= maxTokensAvailable) || super.hasClosed();
  }

  function finalization() internal {
    revert();
  }
}
