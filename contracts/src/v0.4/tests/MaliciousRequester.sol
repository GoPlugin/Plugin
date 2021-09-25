pragma solidity 0.4.24;


import "./MaliciousPlugined.sol";


contract MaliciousRequester is MaliciousPlugined {

  uint256 constant private ORACLE_PAYMENT = 1 * PLI;
  uint256 private expiration;

  constructor(address _pli, address _oracle) public {
    setPliToken(_pli);
    setOracle(_oracle);
  }

  function maliciousWithdraw()
    public
  {
    MaliciousPlugin.WithdrawRequest memory req = newWithdrawRequest(
      "specId", this, this.doesNothing.selector);
    pluginWithdrawRequest(req, ORACLE_PAYMENT);
  }

  function request(bytes32 _id, address _target, bytes _callbackFunc) public returns (bytes32 requestId) {
    Plugin.Request memory req = newRequest(_id, _target, bytes4(keccak256(_callbackFunc)));
    expiration = now.add(5 minutes); // solhint-disable-line not-rely-on-time
    requestId = pluginRequest(req, ORACLE_PAYMENT);
  }

  function maliciousPrice(bytes32 _id) public returns (bytes32 requestId) {
    Plugin.Request memory req = newRequest(_id, this, this.doesNothing.selector);
    requestId = pluginPriceRequest(req, ORACLE_PAYMENT);
  }

  function maliciousTargetConsumer(address _target) public returns (bytes32 requestId) {
    Plugin.Request memory req = newRequest("specId", _target, bytes4(keccak256("fulfill(bytes32,bytes32)")));
    requestId = pluginTargetRequest(_target, req, ORACLE_PAYMENT);
  }

  function maliciousRequestCancel(bytes32 _id, bytes _callbackFunc) public {
    PluginRequestInterface oracle = PluginRequestInterface(oracleAddress());
    oracle.cancelOracleRequest(
      request(_id, this, _callbackFunc),
      ORACLE_PAYMENT,
      this.maliciousRequestCancel.selector,
      expiration
    );
  }

  function doesNothing(bytes32, bytes32) public pure {} // solhint-disable-line no-empty-blocks
}
