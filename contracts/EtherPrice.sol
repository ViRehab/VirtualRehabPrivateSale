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
import "./CustomPausable.sol";

///@title This contract keeps track of Ether price.
contract EtherPrice is CustomPausable {
  uint256 public etherPriceInCents; //price of 1 ETH in cents

  event EtherPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) internal {
    etherPriceInCents = _cents;
    emit EtherPriceChanged(0, etherPriceInCents);
  }

  function setEtherPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit EtherPriceChanged(_cents, etherPriceInCents);
    etherPriceInCents = _cents;
  }
}
