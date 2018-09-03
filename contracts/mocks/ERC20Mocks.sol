pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";


// mock class using ERC20
contract ERC20Mock is StandardToken {
  constructor(address _initialAccount, uint256 _initialBalance) public {
    balances[_initialAccount] = _initialBalance;
  }
}
