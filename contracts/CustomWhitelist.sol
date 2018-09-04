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
import "./CustomPausable.sol";

contract CustomWhitelist is CustomPausable {
  mapping(address => bool) public whitelist;

  event WhitelistAdded(address indexed _investor);
  event WhitelistRemoved(address indexed _investor);

  modifier ifWhitelisted(address _investor) {
    require(_investor!=address(0));
    require(whitelist[_investor]);

    _;
  }
  
  function addWhitelist(address _investor) external whenNotPaused onlyAdmin {
    require(_investor!=address(0));

    if(!whitelist[_investor]) {
      whitelist[_investor] = true;

      emit WhitelistAdded(_investor);
    }
  }

  function addManyWhitelist(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && !whitelist[_investors[i]]) {
        whitelist[_investors[i]] = true;

        emit WhitelistAdded(_investors[i]);
      }
    }
  }

  function removeWhitelist(address _investor) external whenNotPaused onlyAdmin {
    require(_investor != address(0));
    if(whitelist[_investor]) {
      whitelist[_investor] = false;

      emit WhitelistRemoved(_investor);
    }
  }

  function removeManyWhitelist(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && whitelist[_investors[i]]) {
        whitelist[_investors[i]] = false;
        
        emit WhitelistRemoved(_investors[i]);
      }
    }
  }
}