pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./CustomPausable.sol";

contract PrivateSale is FinalizableCrowdsale, CustomPausable {

  uint public tokenPrice; //price of the 1 token in cents
  uint public ETH_USD; //price of 1 ETH in cents
  uint public BNB_USD;
  ERC20 public BNBToken;
  mapping(address => bool) public KYC;
  uint public totalTokensSold;
  uint public bonusTokensSold;
  uint public maxTokensAvailable;
  uint private amountInUSD; // to track the current contribution
  uint public minContributionInUSD; //in cents
  uint public ICOEndDate;
  mapping(address => uint) public bonusHolders;

  modifier isInvestorWhitelisted(address _investor) {
    if(!KYC[_investor]) {
      revert();
    }
    _;
  }

  constructor(uint _startTime, uint _endTime, uint _tokenPrice, uint _ETH_USD, uint _BNB_USD, ERC20 _BNBToken, ERC20 _token, uint _maxTokensAvailable, uint _minContributionInUSD) public
  TimedCrowdsale(_startTime, _endTime) Crowdsale(1, msg.sender, _token) {
    require(_tokenPrice > 0);
    require(_maxTokensAvailable > 0);
    require(_minContributionInUSD > 0);
    require(_BNB_USD > 0);
    require(_ETH_USD > 0);
    tokenPrice = _tokenPrice;
    ETH_USD = _ETH_USD;
    BNB_USD = _BNB_USD;
    maxTokensAvailable = _maxTokensAvailable;
    BNBToken = _BNBToken;
    minContributionInUSD = minContributionInUSD;
  }

  function setTokenPrice(uint _tokenPrice) public whenNotPaused onlyAdmin {
    require(_tokenPrice > 0);
    tokenPrice = _tokenPrice;
  }

  function _forwardFunds() internal {

  }

  function setICOEndDate(uint _endTime) public onlyAdmin whenNotPaused {
    require(_endTime > now);
    require(ICOEndDate == 0);
    ICOEndDate = _endTime;
  }
  function withdrawFunds(uint _amount) public whenNotPaused onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);
  }

  function assignBonus(address _investor, uint _tokenAmount) internal {
    bonusHolders[_investor] = bonusHolders[_investor].add(_tokenAmount);
  }

  function withdrawBonus() public whenNotPaused {
    require(ICOEndDate != 0);
    require(now > ICOEndDate + 90 days); // 3 months
    require(bonusHolders[msg.sender] > 0);
    token.transfer(msg.sender, bonusHolders[msg.sender]);
    bonusHolders[msg.sender] = 0;
  }

  // Binance token contribution
  function contributeInBNB() public isInvestorWhitelisted(msg.sender) whenNotPaused onlyWhileOpen {
    uint allowance = BNBToken.allowance(msg.sender, this);
    BNBToken.transferFrom(msg.sender, this, allowance);
    amountInUSD = convertToUSD(allowance, BNB_USD);
    require(amountInUSD >= minContributionInUSD);
    uint numTokens = amountInUSD.mul(10**18).div(tokenPrice);
    uint bonus = calculateBonus(amountInUSD, numTokens);
    require(totalTokensSold.add(numTokens).add(bonus) <= maxTokensAvailable);
    token.transfer(msg.sender, numTokens);
    assignBonus(msg.sender, bonus);
    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
    bonusTokensSold = bonusTokensSold.add(bonus);
  }

  // ETH USD is the price of 1 ETH in cents
  function setETH_USDPrice(uint _ETH_USD) public whenNotPaused onlyAdmin {
    require(_ETH_USD > 0);
    ETH_USD = _ETH_USD;
  }

  // _BNB_USD is the price of 1 whole(10*18) BNB token in cents
  function setBNB_USDPrice(uint _BNB_USD) public whenNotPaused onlyAdmin {
    require(_BNB_USD > 0);
    BNB_USD = _BNB_USD;
  }

  // _minContributionInUSD is minimum contribution allowed in cents
  function setMinimumContribution(uint _minContributionInUSD) public whenNotPaused onlyAdmin {
    require(_minContributionInUSD > 0);
    minContributionInUSD = _minContributionInUSD;
  }



  function addAddressToKYC(address _investor) public whenNotPaused onlyAdmin {
    require(_investor!=address(0));
    if(!KYC[_investor]) {
      KYC[_investor] = true;
    }
  }

  function addAddressesToKYC(address[] _investors) public whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && !KYC[_investors[i]]) {
        KYC[_investors[i]] = true;
      }
    }
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
  function calculateBonus(uint _tokenAmount, uint _USD) public view returns (uint256) {
    if(_USD < 1500000) {
      return 0;
    } else if(_USD >= 1500000 && _USD <= 10000000) {
      return _tokenAmount.mul(35).div(100);
    } else if(_USD > 10000000 && _USD <= 25000000) {
      return _tokenAmount.mul(40).div(100);
    } else if(_USD > 25000000) {
      return _tokenAmount.mul(50).div(100);
    }
  }

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal  whenNotPaused isInvestorWhitelisted(_beneficiary) {
    amountInUSD = convertToUSD(_weiAmount, ETH_USD);
    require(amountInUSD >= minContributionInUSD);
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  function convertToUSD(uint _weiAmount, uint costOf1Token) public view returns (uint256) {
    return _weiAmount.mul(costOf1Token).div(10**18);
  }

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(ETH_USD).div(tokenPrice).div(10**18);
  }

  function increaseMaxTokensForSale() public whenNotPaused onlyAdmin {
    uint allowance = token.allowance(msg.sender, this)
    maxTokensAvailable = maxTokensAvailable.add(allowance);
    token.transferFrom(msg.sender, this, allowance);
  }

  function getTokenAmountForWei(uint256 _weiAmount) public view returns (uint256) {
    return _getTokenAmount(_weiAmount);
  }

  function withdrawToken(address _token) public onlyAdmin {
    ERC20 t = ERC20(_token);
    require(t.transfer(msg.sender, t.balanceOf(this)));
  }

  function finalization() internal {
    uint unsold = token.balanceOf(this).sub(bonusTokensSold);
    if(unsold > 0) {
      token.transfer(msg.sender, unsold);
    }
  }
}
