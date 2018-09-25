# This contract enables to maintain a list of whitelisted wallets. (CustomWhitelist.sol)

**contract CustomWhitelist is [CustomPausable](CustomPausable.md)**

**CustomWhitelist**

## Contract Members
**Constants & Variables**

```js
mapping(address => bool) public whitelist;
```

**Events**

```js
event WhitelistAdded(address indexed _account);
event WhitelistRemoved(address indexed _account);
```

## Modifiers

- [ifWhitelisted](#ifwhitelisted)

### ifWhitelisted

Verifies if the account is whitelisted.

```js
modifier ifWhitelisted(address _account) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _account | address |  | 

## Functions

- [addWhitelist](#addwhitelist)
- [addManyWhitelist](#addmanywhitelist)
- [removeWhitelist](#removewhitelist)
- [removeManyWhitelist](#removemanywhitelist)

### addWhitelist

Adds an account to the whitelist.

```js
function addWhitelist(address _account) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _account | address | The wallet address to add to the whitelist. | 

### addManyWhitelist

Adds multiple accounts to the whitelist.

```js
function addManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _accounts | address[] | The wallet addresses to add to the whitelist. | 

### removeWhitelist

Removes an account from the whitelist.

```js
function removeWhitelist(address _account) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _account | address | The wallet address to remove from the whitelist. | 

### removeManyWhitelist

Removes multiple accounts from the whitelist.

```js
function removeManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _accounts | address[] | The wallet addresses to remove from the whitelist. | 

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
