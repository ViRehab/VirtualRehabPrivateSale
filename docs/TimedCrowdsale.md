# TimedCrowdsale (TimedCrowdsale.sol)

**contract TimedCrowdsale is [Crowdsale](Crowdsale.md)**

**TimedCrowdsale**

Crowdsale accepting contributions only within a time frame.

## Contract Members
**Constants & Variables**

```js
uint256 public openingTime;
uint256 public closingTime;
```

## Modifiers

- [onlyWhileOpen](#onlywhileopen)

### onlyWhileOpen

Reverts if not in crowdsale time range.

```js
modifier onlyWhileOpen() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [hasClosed](#hasclosed)
- [_preValidatePurchase](#_prevalidatepurchase)

### hasClosed

Checks whether the period in which the crowdsale is open has already elapsed.

```js
function hasClosed() public view
returns(bool)
```

**Returns**

Whether crowdsale period has elapsed

### _preValidatePurchase

:small_red_triangle: overrides [Crowdsale._preValidatePurchase](Crowdsale.md#_prevalidatepurchase)

Extend parent behavior requiring to be within contributing period

```js
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _beneficiary | address | Token purchaser | 
| _weiAmount | uint256 | Amount of wei contributed | 

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
