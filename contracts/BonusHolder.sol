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

contract BonusHolder is CustomPausable {
  using SafeMath for uint256;

  mapping(address => uint256) public bonusHolders;
  uint256 public releaseDate;
  ERC20 public bonusCoin;

  event BonusReleaseDateSet(uint256 _releaseDate);
  event BonusWithdrawn(address indexed _address, uint _amount);

  constructor(ERC20 _bonusCoin){
    bonusCoin = _bonusCoin;
  }

  function setReleaseDate(uint256 _releaseDate) public onlyAdmin whenNotPaused {
    require(releaseDate == 0);
    require(_releaseDate > now);

    releaseDate = _releaseDate;

    emit BonusReleaseDateSet(_releaseDate);
  }

  function assignBonus(address _investor, uint256 _tokenAmount) internal {
    bonusHolders[_investor] = bonusHolders[_investor].add(_tokenAmount);
  }

  function withdrawBonus() public whenNotPaused {
    require(releaseDate != 0);
    require(now > releaseDate);
    uint256 amount = bonusHolders[msg.sender];
    require(amount > 0);

    
    bonusHolders[msg.sender] = 0;
    bonusCoin.transfer(msg.sender, amount);

    emit BonusWithdrawn(msg.sender, amount);
  }
}
