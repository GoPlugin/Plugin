pragma solidity 0.4.24;

import "./Consumer.sol";

contract UpdatableConsumer is Consumer {

  constructor(bytes32 _specId, address _ens, bytes32 _node) public {
    specId = _specId;
    usePluginWithENS(_ens, _node);
  }

  function updateOracle() public {
    updatePluginOracleWithENS();
  }

  function getPluginToken() public view returns (address) {
    return pluginTokenAddress();
  }

  function getOracle() public view returns (address) {
    return pluginOracleAddress();
  }

}
