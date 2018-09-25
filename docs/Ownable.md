# Ownable (Ownable.sol)

**Ownable**

The Ownable contract has an owner address, and provides basic authorization control
functions, this simplifies the implementation of "user permissions".

## Contract Members
**Constants & Variables**

```js
address public owner;
```

**Events**

```js
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

## Modifiers

- [onlyOwner](#onlyowner)

### onlyOwner

Throws if called by any account other than the owner.

```js
modifier onlyOwner() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [renounceOwnership](#renounceownership)
- [transferOwnership](#transferownership)
- [_transferOwnership](#_transferownership)

### renounceOwnership

Renouncing to ownership will leave the contract without an owner.
It will not be possible to call the functions with the `onlyOwner`
modifier anymore.

```js
function renounceOwnership() public onlyOwner
```

### transferOwnership

Allows the current owner to transfer control of the contract to a newOwner.

```js
function transferOwnership(address _newOwner) public onlyOwner
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _newOwner | address | The address to transfer ownership to. | 

### _transferOwnership

Transfers control of the contract to a newOwner.

```js
function _transferOwnership(address _newOwner) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _newOwner | address | The address to transfer ownership to. | 

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
