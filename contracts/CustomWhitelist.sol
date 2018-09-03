pragma solidity 0.4.24;
import "./CustomPausable.sol";

contract CustomWhitelist is CustomPausable {
  mapping(address => bool) public KYC;

  event addedKYCInvestor(address indexed _investor);
  event removedKYCInvestor(address indexed _investor);

  modifier isInvestorWhitelisted(address _investor) {
    if(!KYC[_investor]) {
      revert();
    }
    _;
  }
  
  function addAddressToKYC(address _investor) external whenNotPaused onlyAdmin {
    require(_investor!=address(0));
    if(!KYC[_investor]) {
      KYC[_investor] = true;
      emit addedKYCInvestor(_investor);
    }
  }

  function addAddressesToKYC(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && !KYC[_investors[i]]) {
        KYC[_investors[i]] = true;
        emit addedKYCInvestor(_investors[i]);
      }
    }
  }

  function removeAddressFromKYC(address _investor) external whenNotPaused onlyAdmin {
    require(_investor != address(0));
    if(KYC[_investor]) {
      KYC[_investor] = false;
      emit removedKYCInvestor(_investor);
    }
  }

  function removeAddressesFromKYC(address[] _investors) external whenNotPaused onlyAdmin {
    for(uint8 i=0;i<_investors.length;i++) {
      if(_investors[i] != address(0) && KYC[_investors[i]]) {
        KYC[_investors[i]] = false;
        emit removedKYCInvestor(_investors[i]);
      }
    }
  }
}
