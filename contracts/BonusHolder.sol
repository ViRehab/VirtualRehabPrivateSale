pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./CustomPausable.sol";

contract BonusHolder is CustomPausable {
  using SafeMath for uint256;

  mapping(address => uint256) public bonusHolders;
  uint256 public releaseDate;
  ERC20 private token;

  event BonusReleaseDateSet(uint256 _releaseDate);
  event BonusWithdrawn(address indexed _address, uint _amount);

  constructor(ERC20 _token){
    token = _token;
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
    require(bonusHolders[msg.sender] > 0);
    emit BonusWithdrawn(msg.sender, bonusHolders[msg.sender]);
    token.transfer(msg.sender, bonusHolders[msg.sender]);
    bonusHolders[msg.sender] = 0;
  }
}
