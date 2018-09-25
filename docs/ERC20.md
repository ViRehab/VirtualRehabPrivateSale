# ERC20 interface (ERC20.sol)

**contract ERC20 is [ERC20Basic](ERC20Basic.md)**

**ERC20**

see https://github.com/ethereum/EIPs/issues/20

**Events**

```js
event Approval(address indexed owner, address indexed spender, uint256 value);
```

## Functions

- [allowance](#allowance)
- [transferFrom](#transferfrom)
- [approve](#approve)

### allowance

```js
function allowance(address _owner, address _spender) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _owner | address |  | 
| _spender | address |  | 

### transferFrom

```js
function transferFrom(address _from, address _to, uint256 _value) public
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _from | address |  | 
| _to | address |  | 
| _value | uint256 |  | 

### approve

```js
function approve(address _spender, uint256 _value) public
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _spender | address |  | 
| _value | uint256 |  | 

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
