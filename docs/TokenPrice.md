# This contract keeps track of the VRH token price. (TokenPrice.sol)

**contract TokenPrice is [CustomPausable](CustomPausable.md)**

**TokenPrice**

## Contract Members
**Constants & Variables**

```js
uint256 public tokenPriceInCents;
```

**Events**

```js
event TokenPriceChanged(uint256 _newPrice, uint256 _oldPrice);
```

## Functions

- [setTokenPrice](#settokenprice)

### setTokenPrice

```js
function setTokenPrice(uint256 _cents) public onlyAdmin whenNotPaused
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _cents | uint256 |  | 

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
