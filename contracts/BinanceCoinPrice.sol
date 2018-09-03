pragma solidity 0.4.24;
import "./CustomPausable.sol";

contract BinanceCoinPrice is CustomPausable {
  uint256 public binanceCoinPriceInCents;

  event BinanceCoinPriceChanged(uint256 _newPrice, uint256 _oldPrice);

  constructor(uint256 _cents) {
    require(_cents > 0);

    binanceCoinPriceInCents = _cents;
    emit BinanceCoinPriceChanged(0, _cents);
  }

  function setBinanceCoinPrice(uint256 _cents) public whenNotPaused onlyAdmin {
    require(_cents > 0);

    emit BinanceCoinPriceChanged(_cents, binanceCoinPriceInCents);
    binanceCoinPriceInCents = _cents;
  }
}