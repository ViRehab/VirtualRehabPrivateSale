# Crowdsale (Crowdsale.sol)

**Crowdsale**

Crowdsale is a base contract for managing a token crowdsale,
allowing investors to purchase tokens with ether. This contract implements
such functionality in its most fundamental form and can be extended to provide additional
functionality and/or custom behavior.
The external interface represents the basic interface for purchasing tokens, and conform
the base architecture for crowdsales. They are *not* intended to be modified / overridden.
The internal interface conforms the extensible and modifiable surface of crowdsales. Override
the methods to add functionality. Consider using 'super' where appropriate to concatenate
behavior.

## Contract Members
**Constants & Variables**

```js
contract ERC20 public token;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
```

**Events**

```js
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
```

## Functions

- [](#)
- [buyTokens](#buytokens)
- [_preValidatePurchase](#_prevalidatepurchase)
- [_postValidatePurchase](#_postvalidatepurchase)
- [_deliverTokens](#_delivertokens)
- [_processPurchase](#_processpurchase)
- [_updatePurchasingState](#_updatepurchasingstate)
- [_getTokenAmount](#_gettokenamount)
- [_forwardFunds](#_forwardfunds)

### 

fallback function ***DO NOT OVERRIDE***

```js
function () external payable payable
```

### buyTokens

low level token purchase ***DO NOT OVERRIDE***

```js
function buyTokens(address _beneficiary) public payable payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address performing the token purchase | 

### _preValidatePurchase

Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
Example from CappedCrowdsale.sol's _preValidatePurchase method: 
  super._preValidatePurchase(_beneficiary, _weiAmount);
  require(weiRaised.add(_weiAmount) <= cap);

```js
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address performing the token purchase | 
| _weiAmount | uint256 | Value in wei involved in the purchase | 

### _postValidatePurchase

Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

```js
function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address performing the token purchase | 
| _weiAmount | uint256 | Value in wei involved in the purchase | 

### _deliverTokens

Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

```js
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address performing the token purchase | 
| _tokenAmount | uint256 | Number of tokens to be emitted | 

### _processPurchase

Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

```js
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address receiving the tokens | 
| _tokenAmount | uint256 | Number of tokens to be purchased | 

### _updatePurchasingState

Override for extensions that require an internal state to check for validity (current user contributions, etc.)

```js
function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Address receiving the tokens | 
| _weiAmount | uint256 | Value in wei involved in the purchase | 

### _getTokenAmount

Override to extend the way in which ether is converted to tokens.

```js
function _getTokenAmount(uint256 _weiAmount) internal view
returns(uint256)
```

**Returns**

Number of tokens that can be purchased with the specified _weiAmount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _weiAmount | uint256 | Value in wei to be converted into tokens | 

### _forwardFunds

Determines how ETH is stored/forwarded on purchases.

```js
function _forwardFunds() internal
```

## Contracts

- [CustomWhitelist](CustomWhitelist.md)
- [FinalizableCrowdsale](FinalizableCrowdsale.md)
- [EtherPrice](EtherPrice.md)
- [TokenPrice](TokenPrice.md)
- [PrivateSale](PrivateSale.md)
- [ERC20Basic](ERC20Basic.md)
- [SafeMath](SafeMath.md)
- [BinanceCoinPrice](BinanceCoinPrice.md)
- [ERC20Mock](ERC20Mock.md)
- [BasicToken](BasicToken.md)
- [SafeERC20](SafeERC20.md)
- [TimedCrowdsale](TimedCrowdsale.md)
- [StandardToken](StandardToken.md)
- [CustomPausable](CustomPausable.md)
- [Crowdsale](Crowdsale.md)
- [CreditsTokenPrice](CreditsTokenPrice.md)
- [CustomAdmin](CustomAdmin.md)
- [BonusHolder](BonusHolder.md)
- [Migrations](Migrations.md)
- [Ownable](Ownable.md)
- [ERC20](ERC20.md)
