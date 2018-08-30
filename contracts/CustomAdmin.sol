/*
Copyright 2018 Binod Nirvan

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

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CustomAdmin is Ownable {
  mapping(address => bool) public admins;
  uint256 public numberOfAdmins;

  event AdminAdded(address addr);
  event AdminRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not an administrator.
   */
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }

  constructor() public {
    admins[msg.sender] = true;
    numberOfAdmins = 1;
    emit AdminAdded(msg.sender);
  }
  /**
   * @dev Add an address to the adminstrator list.
   * @param addr address
   */
  function addAdmin(address addr) onlyAdmin  public {
    require(addr != address(0));
    require(!admins[addr]);

    admins[addr] = true;
    numberOfAdmins++;

    emit AdminAdded(addr);
  }

  /**
   * @dev Remove an address from the administrator list.
   * @param addr address
   */
  function removeAdmin(address addr) onlyAdmin  public {
    require(addr != address(0));
    require(admins[addr]);
    //the owner can not be unadminsed
    require(addr != owner);

    admins[addr] = false;
    numberOfAdmins--;

    emit AdminRemoved(addr);
  }
}
