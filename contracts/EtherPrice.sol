pragma solidity 0.4.24;
import "./CustomPausable.sol";

contract EtherPrice is CustomPausable {
  uint256 public etherPriceInCents; //price of 1 ETH in cents

  event EtherPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) {
    require(_cents > 0);

    etherPriceInCents = _cents;

    emit EtherPriceChanged(0, etherPriceInCents);
  }

  function setEtherPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);
    
    emit EtherPriceChanged(_cents, etherPriceInCents);
    etherPriceInCents = _cents;
  }
}
