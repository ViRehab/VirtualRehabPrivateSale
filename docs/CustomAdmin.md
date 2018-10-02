# This contract enables to create multiple contract administrators. (CustomAdmin.sol)

**contract CustomAdmin is [Ownable](Ownable.md)**

**CustomAdmin**

## Contract Members
**Constants & Variables**

```js
mapping(address => bool) public admins;
```

**Events**

```js
event AdminAdded(address indexed _address);
event AdminRemoved(address indexed _address);
```

## Modifiers

- [onlyAdmin](#onlyadmin)

### onlyAdmin

Validates if the sender is actually an administrator.

```js
modifier onlyAdmin() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [addAdmin](#addadmin)
- [addManyAdmins](#addmanyadmins)
- [removeAdmin](#removeadmin)
- [removeManyAdmins](#removemanyadmins)

### addAdmin

Adds the specified address to the list of administrators.

```js
function addAdmin(address _address) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _address | address | The address to add to the administrator list. | 

### addManyAdmins

Adds multiple addresses to the administrator list.

```js
function addManyAdmins(address[] _accounts) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _accounts | address[] | The wallet addresses to add to the administrator list. | 

### removeAdmin

Removes the specified address from the list of administrators.

```js
function removeAdmin(address _address) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _address | address | The address to remove from the administrator list. | 

### removeManyAdmins

Removes multiple addresses to the administrator list.

```js
function removeManyAdmins(address[] _accounts) external onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _accounts | address[] | The wallet addresses to remove from the administrator list. | 

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
