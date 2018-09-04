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



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}







/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}











/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}








/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}



/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}



/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

/*
Copyright 2018 Binod Nirvan

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


/*
Copyright 2018 Binod Nirvan

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


 


/*
Copyright 2018 Binod Nirvan

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





contract CustomAdmin is Ownable {
  mapping(address => bool) public admins;

  event AdminAdded(address indexed _address);
  event AdminRemoved(address indexed _address);

  /**
   * @dev Throws if called by any account that's not an administrator.
   */
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }
  /**
   * @dev Add an address to the adminstrator list.
   * @param _address address
   */
  function addAdmin(address _address) onlyAdmin  public {
    require(_address != address(0));
    require(!admins[_address]);

    //The owner is already an admin and cannot be added.
    require(_address != owner);

    admins[_address] = true;

    emit AdminAdded(_address);
  }

  /**
   * @dev Remove an address from the administrator list.
   * @param _address address
   */
  function removeAdmin(address _address) onlyAdmin  public {
    require(_address != address(0));
    require(admins[_address]);

    //The owner cannot be removed as admin.
    require(_address != owner);

    admins[_address] = false;
    emit AdminRemoved(_address);
  }
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract CustomPausable is CustomAdmin {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyAdmin whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyAdmin whenPaused public {
    paused = false;
    emit Unpause();
  }
}


contract CustomWhitelist is CustomPausable {
  mapping(address => bool) public whitelist;

  event WhitelistAdded(address indexed _investor);
  event WhitelistRemoved(address indexed _investor);

  modifier ifWhitelisted(address _investor) {
    require(_investor!=address(0));
    require(whitelist[_investor]);

    _;
  }
  
  function addWhitelist(address _investor) external whenNotPaused onlyAdmin {
    require(_investor!=address(0));

    if(!whitelist[_investor]) {
      whitelist[_investor] = true;

      emit WhitelistAdded(_investor);
    }
  }

  function addManyWhitelist(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && !whitelist[_investors[i]]) {
        whitelist[_investors[i]] = true;

        emit WhitelistAdded(_investors[i]);
      }
    }
  }

  function removeWhitelist(address _investor) external whenNotPaused onlyAdmin {
    require(_investor != address(0));
    if(whitelist[_investor]) {
      whitelist[_investor] = false;

      emit WhitelistRemoved(_investor);
    }
  }

  function removeManyWhitelist(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && whitelist[_investors[i]]) {
        whitelist[_investors[i]] = false;
        
        emit WhitelistRemoved(_investors[i]);
      }
    }
  }
}
/*
Copyright 2018 Binod Nirvan, Subramanian Venkatesan

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




contract TokenPrice is CustomPausable {
  ///@notice The price per token in cents.
  uint256 public tokenPriceInCents ;

  event TokenPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) {
    require(_cents > 0);
    tokenPriceInCents  = _cents;
  }


  function setTokenPrice(uint256 _cents) public onlyAdmin whenNotPaused {
    require(_cents > 0);

    emit TokenPriceChanged(_cents, tokenPriceInCents );
    tokenPriceInCents  = _cents;
  }
}

/*
Copyright 2018 Binod Nirvan, Subramanian Venkatesan

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




contract EtherPrice is CustomPausable {
  uint256 public etherPriceInCents; //price of 1 ETH in cents

  event EtherPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) {
    require(_cents > 0);

    etherPriceInCents = _cents;

    emit EtherPriceChanged(0, etherPriceInCents);
  }

  function setEtherPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);
    
    emit EtherPriceChanged(_cents, etherPriceInCents);
    etherPriceInCents = _cents;
  }
}

/*
Copyright 2018 Binod Nirvan, Subramanian Venkatesan

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
 
 


contract BinanceCoinPrice is CustomPausable {
  uint256 public binanceCoinPriceInCents;

  event BinanceCoinPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) {
    require(_cents > 0);

    binanceCoinPriceInCents = _cents;
    emit BinanceCoinPriceChanged(0, _cents);
  }

  function setBinanceCoinPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit BinanceCoinPriceChanged(_cents, binanceCoinPriceInCents);
    binanceCoinPriceInCents = _cents;
  }
}
/*
Copyright 2018 Binod Nirvan, Subramanian Venkatesan

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






contract BonusHolder is CustomPausable {
  using SafeMath for uint256;

  mapping(address => uint256) public bonusHolders;
  uint256 public releaseDate;
  ERC20 public bonusCoin;

  event BonusReleaseDateSet(uint256 _releaseDate);
  event BonusWithdrawn(address indexed _address, uint _amount);

  constructor(ERC20 _bonusCoin){
    bonusCoin = _bonusCoin;
  }

  function setReleaseDate(uint256 _releaseDate) public onlyAdmin whenNotPaused {
    require(releaseDate == 0);
    require(_releaseDate > now);

    releaseDate = _releaseDate;

    emit BonusReleaseDateSet(_releaseDate);
  }

  function assignBonus(address _investor, uint256 _tokenAmount) internal {
    bonusHolders[_investor] = bonusHolders[_investor].add(_tokenAmount);
  }

  function withdrawBonus() public whenNotPaused {
    require(releaseDate != 0);
    require(now > releaseDate);
    uint256 amount = bonusHolders[msg.sender];
    require(amount > 0);

    
    bonusHolders[msg.sender] = 0;
    bonusCoin.transfer(msg.sender, amount);

    emit BonusWithdrawn(msg.sender, amount);
  }
}



///@title Virtual Rehab Private Sale.
///@author Binod Nirvan, Subramanian Venkatesan (http://virtualrehab.co)
///@notice This contract enables contributors to participate in Virtual Rehab Private Sale.
///In order to contribute, an investor has to complete the KYC and become whitelisted.
///Accepted Currencies: Ether, Binance Coin
contract PrivateSale is TokenPrice, EtherPrice, BinanceCoinPrice, BonusHolder, FinalizableCrowdsale, CustomWhitelist {
  ///@notice The ERC20 token contract of Binance Coin.
  ERC20 public binanceCoin;

  ///@notice The total amount of VRH tokens sold in the private round.
  uint256 public totalTokensSold;

  ///@notice The total amount of bonus VRH tokens provided to the contributors.
  uint256 public bonusProvided;

  ///@notice The total amount of VRH tokens allocated for the private sale.
  uint256 public totalSaleAllocation;

  ///@notice The equivant dollar amount of each contribution request.
  uint256 private amountInUSDCents;

  ///@notice The minimum contribution in dollar cent value.
  uint256 public minContributionInUSDCents;

  ///@notice Signifies if the private sale was started.
  bool public initialized;


  event MinimumContributionChanged(uint256 _newContribution, uint256 _oldContribution);
  event SaleInitialized();

  event FundsWithdrawn(address indexed _wallet, uint256 _amount);
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
    require(_binanceCoinPriceInCents > 0);

    binanceCoin = _binanceCoin;
    minContributionInUSDCents = _minContributionInUSDCents;
  }

  ///@notice Initializes the private sale.
  function initializePrivateSale() {
    require(!initialized);

    increaseTokenSaleAllocation();

    initialized = true;

    emit SaleInitialized();
  }

  ///@notice Enables a contributor to contribute using Binance coin.
  function contributeInBNB() public ifWhitelisted(msg.sender) whenNotPaused onlyWhileOpen {
    require(initialized);

    ///check the amount of Binance coins allowed by the contributor.
    uint256 allowance = binanceCoin.allowance(msg.sender, this);

    ///Calculate equivalent amount in dollar cent value.
    amountInUSDCents  = convertToCents(allowance, binanceCoinPriceInCents);

    ///Check if the contribution can be accepted.
    require(amountInUSDCents  >= minContributionInUSDCents);

    ///Calcuate the amount of tokens per the contribution.
    uint256 numTokens = amountInUSDCents.mul(10**18).div(tokenPriceInCents);

    ///Calcuate the bonus based on the number of tokens and the dollar cent value.
    uint256 bonus = calculateBonus(numTokens, amountInUSDCents);
    
    require(totalTokensSold.add(numTokens).add(bonus) <= totalSaleAllocation);

    ///Receive the Binance coins immeidately.
    binanceCoin.transferFrom(msg.sender, this, allowance);

    ///Send the VRH tokens to the contributor.
    token.transfer(msg.sender, numTokens);

    assignBonus(msg.sender, bonus);

    totalTokensSold = totalTokensSold.add(numTokens).add(bonus);
    bonusProvided = bonusProvided.add(bonus);
  }

  function setMinimumContribution(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit MinimumContributionChanged(minContributionInUSDCents, _cents);
    minContributionInUSDCents = _cents;
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

    ///Keep track of the provided bonus.
    bonusProvided = bonusProvided.add(bonus);

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
  function getTokenAmountForWei(uint256 _weiAmount) public view returns (uint256) {
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
  function withdrawToken(address _token) public onlyAdmin {
    ERC20 erc20 = ERC20(_token);
    
    erc20.transfer(msg.sender, erc20.balanceOf(this));
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
  function withdrawFunds(uint256 _amount) public whenNotPaused onlyAdmin {
    require(_amount <= address(this).balance);
    msg.sender.transfer(_amount);

    emit FundsWithdrawn(msg.sender, _amount);
  }
}