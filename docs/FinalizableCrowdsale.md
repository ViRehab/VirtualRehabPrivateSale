# FinalizableCrowdsale (FinalizableCrowdsale.sol)

**contract FinalizableCrowdsale is [Ownable](Ownable.md), [TimedCrowdsale](TimedCrowdsale.md)**

**FinalizableCrowdsale**

Extension of Crowdsale where an owner can do extra work
after finishing.

## Contract Members
**Constants & Variables**

```js
bool public isFinalized;
```

**Events**

```js
event Finalized();
```

## Functions

- [finalize](#finalize)
- [finalization](#finalization)

### finalize

Must be called after crowdsale ends, to do some extra finalization
work. Calls the contract's finalization function.

```js
function finalize() public onlyOwner
```

### finalization

Can be overridden to add finalization logic. The overriding function
should call super.finalization() to ensure the chain of finalization is
executed entirely.

```js
function finalization() internal
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
