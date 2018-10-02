pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

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





///@title This contract enables to create multiple contract administrators.
contract CustomAdmin is Ownable {
  ///@notice List of administrators.
  mapping(address => bool) public admins;

  event AdminAdded(address indexed _address);
  event AdminRemoved(address indexed _address);

  ///@notice Validates if the sender is actually an administrator.
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }

  ///@notice Adds the specified address to the list of administrators.
  ///@param _address The address to add to the administrator list.
  function addAdmin(address _address) external onlyAdmin {
    require(_address != address(0));
    require(!admins[_address]);

    //The owner is already an admin and cannot be added.
    require(_address != owner);

    admins[_address] = true;

    emit AdminAdded(_address);
  }

  ///@notice Adds multiple addresses to the administrator list.
  ///@param _accounts The wallet addresses to add to the administrator list.
  function addManyAdmins(address[] _accounts) external onlyAdmin {
    for(uint8 i=0; i<_accounts.length; i++) {
      address account = _accounts[i];

      ///Zero address cannot be an admin.
      ///The owner is already an admin and cannot be assigned.
      ///The address cannot be an existing admin.
      if(account != address(0) && !admins[account] && account != owner){
        admins[account] = true;

        emit AdminAdded(_accounts[i]);
      }
    }
  }
  
  ///@notice Removes the specified address from the list of administrators.
  ///@param _address The address to remove from the administrator list.
  function removeAdmin(address _address) external onlyAdmin {
    require(_address != address(0));
    require(admins[_address]);

    //The owner cannot be removed as admin.
    require(_address != owner);

    admins[_address] = false;
    emit AdminRemoved(_address);
  }


  ///@notice Removes multiple addresses to the administrator list.
  ///@param _accounts The wallet addresses to remove from the administrator list.
  function removeManyAdmins(address[] _accounts) external onlyAdmin {
    for(uint8 i=0; i<_accounts.length; i++) {
      address account = _accounts[i];

      ///Zero address can neither be added or removed from this list.
      ///The owner is the super admin and cannot be removed.
      ///The address must be an existing admin in order for it to be removed.
      if(account != address(0) && admins[account] && account != owner){
        admins[account] = false;

        emit AdminRemoved(_accounts[i]);
      }
    }
  }
}

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


 





///@title This contract enables you to create pausable mechanism to stop in case of emergency.
contract CustomPausable is CustomAdmin {
  event Paused();
  event Unpaused();

  bool public paused = false;

  ///@notice Verifies whether the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  ///@notice Verifies whether the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }

  ///@notice Pauses the contract.
  function pause() external onlyAdmin whenNotPaused {
    paused = true;
    emit Paused();
  }

  ///@notice Unpauses the contract and returns to normal state.
  function unpause() external onlyAdmin whenPaused {
    paused = false;
    emit Unpaused();
  }
}

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

 


///@title This contract keeps track of Credits Token price.
contract CreditsTokenPrice is CustomPausable {
  uint256 public creditsTokenPriceInCents;

  event CreditsTokenPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  function setCreditsTokenPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit CreditsTokenPriceChanged(_cents, creditsTokenPriceInCents);
    creditsTokenPriceInCents = _cents;
  }
}