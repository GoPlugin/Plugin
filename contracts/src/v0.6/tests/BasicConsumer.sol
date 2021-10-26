// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Consumer.sol";

contract BasicConsumer is Consumer {

  constructor(address _pli, address _oracle, bytes32 _specId) public {
    setPluginToken(_pli);
    setPluginOracle(_oracle);
    specId = _specId;
  }

}
