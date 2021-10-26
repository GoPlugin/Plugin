pragma solidity 0.5.0;


import "./MaliciousPluginClient.sol";


contract MaliciousRequester is MaliciousPluginClient {

  uint256 constant private ORACLE_PAYMENT = 1 * PLI;
  uint256 private expiration;

  constructor(address _pli, address _oracle) public {
    setPluginToken(_pli);
    setPluginOracle(_oracle);
  }

  function maliciousWithdraw()
    public
  {
    MaliciousPlugin.WithdrawRequest memory req = newWithdrawRequest(
      "specId", address(this), this.doesNothing.selector);
    pluginWithdrawRequest(req, ORACLE_PAYMENT);
  }

  function request(bytes32 _id, address _target, bytes memory _callbackFunc) public returns (bytes32 requestId) {
    Plugin.Request memory req = buildPluginRequest(_id, _target, bytes4(keccak256(_callbackFunc)));
    expiration = now.add(5 minutes); // solhint-disable-line not-rely-on-time
    requestId = sendPluginRequest(req, ORACLE_PAYMENT);
  }

  function maliciousPrice(bytes32 _id) public returns (bytes32 requestId) {
    Plugin.Request memory req = buildPluginRequest(_id, address(this), this.doesNothing.selector);
    requestId = pluginPriceRequest(req, ORACLE_PAYMENT);
  }

  function maliciousTargetConsumer(address _target) public returns (bytes32 requestId) {
    Plugin.Request memory req = buildPluginRequest("specId", _target, bytes4(keccak256("fulfill(bytes32,bytes32)")));
    requestId = pluginTargetRequest(_target, req, ORACLE_PAYMENT);
  }

  function maliciousRequestCancel(bytes32 _id, bytes memory _callbackFunc) public {
    PluginRequestInterface _oracle = PluginRequestInterface(pluginOracleAddress());
    _oracle.cancelOracleRequest(
      request(_id, address(this), _callbackFunc),
      ORACLE_PAYMENT,
      this.maliciousRequestCancel.selector,
      expiration
    );
  }

  function doesNothing(bytes32, bytes32) public pure {} // solhint-disable-line no-empty-blocks
}
