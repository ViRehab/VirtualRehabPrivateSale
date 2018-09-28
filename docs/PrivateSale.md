# Virtual Rehab Private Sale. (PrivateSale.sol)

**contract PrivateSale is [TokenPrice](TokenPrice.md), [EtherPrice](EtherPrice.md), [BinanceCoinPrice](BinanceCoinPrice.md), [CreditsTokenPrice](CreditsTokenPrice.md), [BonusHolder](BonusHolder.md), [FinalizableCrowdsale](FinalizableCrowdsale.md), [CustomWhitelist](CustomWhitelist.md)**

**PrivateSale**

This contract enables contributors to participate in Virtual Rehab Private Sale.

///The Virtual Rehab Private Sale provides early investors with an opportunity
to take part into the Virtual Rehab token sale ahead of the pre-sale and main sale launch.
All early investors are expected to successfully complete KYC and whitelisting
to contribute to the Virtual Rehab token sale.

///US investors must be accredited investors and must provide all requested documentation
to validate their accreditation. We, unfortunately, do not accept contributions
from non-accredited investors within the US along with any contribution
from China, Republic of Korea, and New Zealand. Any questions or additional information needed
can be sought by sending an e-mail to investors＠virtualrehab.co.

///Accepted Currencies: Ether, Binance Coin, Credits Token.

## Constructor

Creates and constructs this private sale contract.

```js
constructor(uint256 _startTime, uint256 _endTime) public
```

**Arguments**

## Contract Members
**Constants & Variables**

```js
//public members
contract ERC20 public binanceCoin;
contract ERC20 public creditsToken;
uint256 public totalTokensSold;
uint256 public totalSaleAllocation;
uint256 public minContributionInUSDCents;
bool public initialized;

//private members
uint256 private amountInUSDCents;
```

**Events**

```js
event MinimumContributionChanged(uint256 _newContribution, uint256 _oldContribution);
event SaleInitialized();
event FundsWithdrawn(address indexed _wallet, uint256 _amount);
event ERC20Withdrawn(address indexed _contract, uint256 _amount);
event TokensAllocatedForSale(uint256 _newAllowance, uint256 _oldAllowance);
```

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _startTime | uint256 | The date and time of the private sale start. | 
| _endTime | uint256 | The date and time of the private sale end. | 

## Functions

- [initializePrivateSale](#initializeprivatesale)
- [contributeInBNB](#contributeinbnb)
- [contributeInCreditsToken](#contributeincreditstoken)
- [setMinimumContribution](#setminimumcontribution)
- [_preValidatePurchase](#_prevalidatepurchase)
- [_processPurchase](#_processpurchase)
- [calculateBonus](#calculatebonus)
- [convertToCents](#converttocents)
- [_getTokenAmount](#_gettokenamount)
- [getTokenAmountForWei](#gettokenamountforwei)
- [increaseTokenSaleAllocation](#increasetokensaleallocation)
- [withdrawToken](#withdrawtoken)
- [finalizeCrowdsale](#finalizecrowdsale)
- [hasClosed](#hasclosed)
- [finalization](#finalization)
- [_forwardFunds](#_forwardfunds)
- [withdrawFunds](#withdrawfunds)
- [changeClosingTime](#changeclosingtime)
- [tokenRemainingForSale](#tokenremainingforsale)

### initializePrivateSale

Initializes the private sale.

```js
function initializePrivateSale(uint256 _etherPriceInCents, uint256 _tokenPriceInCents, uint256 _binanceCoinPriceInCents, uint256 _creditsTokenPriceInCents, uint256 _minContributionInUSDCents) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _etherPriceInCents | uint256 | Ether Price in cents | 
| _tokenPriceInCents | uint256 | VRHToken Price in cents | 
| _binanceCoinPriceInCents | uint256 | Binance Coin Price in cents | 
| _creditsTokenPriceInCents | uint256 | Credits Token Price in cents | 
| _minContributionInUSDCents | uint256 | The minimum contribution in dollar cent value | 

### contributeInBNB

Enables a contributor to contribute using Binance coin.

```js
function contributeInBNB() external ifWhitelisted whenNotPaused onlyWhileOpen
```

### contributeInCreditsToken

```js
function contributeInCreditsToken() external ifWhitelisted whenNotPaused onlyWhileOpen
```

### setMinimumContribution

```js
function setMinimumContribution(uint256 _cents) public whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _cents | uint256 |  | 

### _preValidatePurchase

:small_red_triangle: overrides [TimedCrowdsale._preValidatePurchase](TimedCrowdsale.md#_prevalidatepurchase)

Additional validation rules before token contribution is actually allowed.

```js
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused ifWhitelisted
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | The contributor who wishes to purchase the VRH tokens. | 
| _weiAmount | uint256 | The amount of Ethers (in wei) wished to contribute. | 

### _processPurchase

:small_red_triangle: overrides [Crowdsale._processPurchase](Crowdsale.md#_processpurchase)

This function is automatically called when a contribution request passes all validations.

```js
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | The contributor who wishes to purchase the VRH tokens. | 
| _tokenAmount | uint256 | The amount of tokens wished to purchase. | 

### calculateBonus

Todo: the accuracy of this function needs to be rechecked.

```js
function calculateBonus(uint256 _tokenAmount, uint256 _cents) public pure
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAmount | uint256 | The total amount in VRH tokens. | 
| _cents | uint256 | The amount in US dollar cents. | 

### convertToCents

Converts the amount of Ether (wei) or amount of any token having 18 decimal place divisible
to cent value based on the cent price supplied.

```js
function convertToCents(uint256 _tokenAmount, uint256 _priceInCents, uint256 _decimals) public pure
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAmount | uint256 |  | 
| _priceInCents | uint256 |  | 
| _decimals | uint256 |  | 

### _getTokenAmount

:small_red_triangle: overrides [Crowdsale._getTokenAmount](Crowdsale.md#_gettokenamount)

Calculates the number of VRH tokens for the supplied wei value.

```js
function _getTokenAmount(uint256 _weiAmount) internal view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _weiAmount | uint256 | The total amount of Ether in wei value. | 

### getTokenAmountForWei

Used only for test, drop this function before deployment.

```js
function getTokenAmountForWei(uint256 _weiAmount) external view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _weiAmount | uint256 | The total amount of Ether in wei value. | 

### increaseTokenSaleAllocation

Recalculates and/or reassigns the total tokens allocated for the private sale.

```js
function increaseTokenSaleAllocation() public whenNotPaused onlyAdmin
```

### withdrawToken

Enables the admins to withdraw Binance coin
or any ERC20 token accidentally sent to this contract.

```js
function withdrawToken(address _token) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _token | address |  | 

### finalizeCrowdsale

Must be called after crowdsale ends, to do some extra finalization work.

```js
function finalizeCrowdsale() public onlyAdmin
```

### hasClosed

:small_red_triangle: overrides [TimedCrowdsale.hasClosed](TimedCrowdsale.md#hasclosed)

Signifies whether or not the private sale has ended.

```js
function hasClosed() public view
returns(bool)
```

**Returns**

Returns true if the private sale has ended.

### finalization

:small_red_triangle: overrides [FinalizableCrowdsale.finalization](FinalizableCrowdsale.md#finalization)

Use finalizeCrowdsale instead.

```js
function finalization() internal
```

### _forwardFunds

:small_red_triangle: overrides [Crowdsale._forwardFunds](Crowdsale.md#_forwardfunds)

Stops the crowdsale contract from sending ethers.

```js
function _forwardFunds() internal
```

### withdrawFunds

Enables the admins to withdraw Ethers present in this contract.

```js
function withdrawFunds(uint256 _amount) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _amount | uint256 |  | 

### changeClosingTime

```js
function changeClosingTime(uint256 _closingTime) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _closingTime | uint256 |  | 

### tokenRemainingForSale

```js
function tokenRemainingForSale() public view
returns(uint256)
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
