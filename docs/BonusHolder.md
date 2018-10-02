# This contract enables assigning bonus to crowdsale contributors. (BonusHolder.sol)

**contract BonusHolder is [CustomPausable](CustomPausable.md)**

**BonusHolder**

## Contract Members
**Constants & Variables**

```js
mapping(address => uint256) public bonusHolders;
uint256 public releaseDate;
contract ERC20 public bonusCoin;
uint256 public bonusProvided;
uint256 public bonusWithdrawn;
```

**Events**

```js
event BonusReleaseDateSet(uint256 _releaseDate);
event BonusAssigned(address indexed _address, uint256 _amount);
event BonusWithdrawn(address indexed _address, uint256 _amount);
```

## Functions

- [setReleaseDate](#setreleasedate)
- [assignBonus](#assignbonus)
- [withdrawBonus](#withdrawbonus)
- [getRemainingBonus](#getremainingbonus)

### setReleaseDate

Enables the administrators to set the bonus release date.
Please note that the release date can only be set once.

```js
function setReleaseDate(uint256 _releaseDate) external onlyAdmin whenNotPaused
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _releaseDate | uint256 | The timestamp after which the bonus will be available. | 

### assignBonus

Assigns bonus tokens to the specific contributor.

```js
function assignBonus(address _investor, uint256 _bonus) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _investor | address | The wallet address of the investor/contributor. | 
| _bonus | uint256 | The amount of bonus in token value. | 

### withdrawBonus

Enables contributors to withdraw their bonus.
The bonus can only be withdrawn after the release date.

```js
function withdrawBonus() external whenNotPaused
```

### getRemainingBonus

Returns the remaining bonus held on behalf of the crowdsale contributors by this contract.

```js
function getRemainingBonus() public view
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
