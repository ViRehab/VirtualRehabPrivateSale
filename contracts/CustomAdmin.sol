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

  event AdminAdded(address indexed _address);
  event AdminRemoved(address indexed _address);

  /**
   * @dev Throws if called by any account that's not an administrator.
   */
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }
  /**
   * @dev Add an address to the adminstrator list.
   * @param _address address
   */
  function addAdmin(address _address) onlyAdmin  public {
    require(_address != address(0));
    require(!admins[_address]);

    //The owner is already an admin and cannot be added.
    require(_address != owner);

    admins[_address] = true;

    emit AdminAdded(_address);
  }

  /**
   * @dev Remove an address from the administrator list.
   * @param _address address
   */
  function removeAdmin(address _address) onlyAdmin  public {
    require(_address != address(0));
    require(admins[_address]);

    //The owner cannot be removed as admin.
    require(_address != owner);

    admins[_address] = false;
    emit AdminRemoved(_address);
  }
}
