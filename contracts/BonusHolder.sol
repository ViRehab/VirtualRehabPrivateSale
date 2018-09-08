/*
Copyright 2018 Binod Nirvan, Subramanian Venkatesan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./CustomPausable.sol";

///@title This contract enables assigning bonus to crowdsale contributors.
contract BonusHolder is CustomPausable {
  using SafeMath for uint256;

  ///@notice The list of addresses and their respective bonuses.
  mapping(address => uint256) public bonusHolders;

  ///@notice The timestamp on which bonus will be available.
  uint256 public releaseDate;

  ///@notice The ERC20 token contract of the bonus coin.
  ERC20 public bonusCoin;

  ///@notice The total amount of bonus coins provided to the contributors.
  uint256 public bonusProvided;
  uint256 public bonusWithdrawn;

  event BonusReleaseDateSet(uint256 _releaseDate);
  event BonusAssigned(address indexed _address, uint _amount);
  event BonusWithdrawn(address indexed _address, uint _amount);

  ///@notice Constructs bonus holder.
  ///@param _bonusCoin The ERC20 token of the coin to hold bonus.
  constructor(ERC20 _bonusCoin){
    bonusCoin = _bonusCoin;
  }

  ///@notice Enables the administrators to set the bonus release date.
  ///Please note that the release date can only be set once.
  ///@param _releaseDate The timestamp after which the bonus will be available.
  function setReleaseDate(uint256 _releaseDate) external onlyAdmin whenNotPaused {
    require(releaseDate == 0);
    require(_releaseDate > now);

    releaseDate = _releaseDate;

    emit BonusReleaseDateSet(_releaseDate);
  }

  ///@notice Assigns bonus tokens to the specific contributor.
  ///@param _investor The wallet address of the investor/contributor.
  ///@param _bonus The amount of bonus in token value.
  function assignBonus(address _investor, uint256 _bonus) internal {
    if(_bonus == 0){
      return;
    }

    bonusProvided = bonusProvided.add(_bonus);
    bonusHolders[_investor] = bonusHolders[_investor].add(_bonus);

    emit BonusAssigned(_investor, _bonus);
  }

  ///@notice Enables contributors to withdraw their bonus.
  ///The bonus can only be withdrawn after the release date.
  function withdrawBonus() external whenNotPaused {
    require(releaseDate != 0);
    require(now > releaseDate);
    uint256 amount = bonusHolders[msg.sender];
    require(amount > 0);
    bonusWithdrawn = bonusWithdrawn.add(amount);
    bonusHolders[msg.sender] = 0;
    bonusCoin.transfer(msg.sender, amount);

    emit BonusWithdrawn(msg.sender, amount);
  }

  function bonusRemaining() public view returns(uint256) {
    return bonusProvided.sub(bonusWithdrawn);
  }
}
