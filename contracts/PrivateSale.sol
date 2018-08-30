pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./CustomPausable.sol";

contract PrivateSale is FinalizableCrowdsale, CustomPausable {

  uint public tokenPrice;
  uint public ETH_USD;
  uint public BNB_USD;
  mapping(address => bool) public KYC;

  modifier isInvestorWhitelisted(address _investor) {
    if(!KYC[_investor]) {
      revert();
    }
    _;
  }

  constructor(uint _startTime, uint _endTime, uint _tokenPrice, uint _ETH_USD, uint _BNB_USD, ERC20 _token) public
  TimedCrowdsale(_startTime, _endTime) Crowdsale(1, msg.sender, _token) {
    require(_tokenPrice > 0);
    require(_BNB_USD > 0);
    require(_ETH_USD > 0);
    tokenPrice = _tokenPrice;
    ETH_USD = _ETH_USD;
    BNB_USD = _BNB_USD;
  }

  function setTokenPrice(uint _tokenPrice) public onlyAdmin {
    require(_tokenPrice > 0);
    tokenPrice = _tokenPrice;
  }

  function _forwardFunds() internal {

  }

  function withdrawFunds(uint _amount) public onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);
  }

  function setETH_USDPrice(uint _ETH_USD) public onlyAdmin {
    require(_ETH_USD > 0);
    ETH_USD = _ETH_USD;
  }

  function setBNB_USDPrice(uint _BNB_USD) public onlyAdmin {
    require(_BNB_USD > 0);
    BNB_USD = _BNB_USD;
  }

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal  whenNotPaused isInvestorWhitelisted(_beneficiary) {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(ETH_USD).div(tokenPrice).div(10**18);
  }
}
