# Migrations.sol

**Migrations**

## Contract Members
**Constants & Variables**

```js
address public owner;
uint256 public last_completed_migration;
```

## Modifiers

- [restricted](#restricted)

### restricted

```js
modifier restricted() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [setCompleted](#setcompleted)
- [upgrade](#upgrade)

### setCompleted

```js
function setCompleted(uint256 completed) public restricted
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| completed | uint256 |  | 

### upgrade

```js
function upgrade(address new_address) public restricted
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| new_address | address |  | 

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
