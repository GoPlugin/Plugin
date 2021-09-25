pragma solidity 0.4.24;


import "../Plugined.sol";
import "../vendor/SafeMathPlugin.sol";


contract MaliciousConsumer is Plugined {
  using SafeMathPlugin for uint256;

  uint256 constant private ORACLE_PAYMENT = 1 * PLI;
  uint256 private expiration;

  constructor(address _pli, address _oracle) public payable {
    setPliToken(_pli);
    setOracle(_oracle);
  }

  function () public payable {} // solhint-disable-line no-empty-blocks

  function requestData(bytes32 _id, bytes _callbackFunc) public {
    Plugin.Request memory req = newRequest(_id, this, bytes4(keccak256(_callbackFunc)));
    expiration = now.add(5 minutes); // solhint-disable-line not-rely-on-time
    pluginRequest(req, ORACLE_PAYMENT);
  }

  function assertFail(bytes32, bytes32) public pure {
    assert(1 == 2);
  }

  function cancelRequestOnFulfill(bytes32 _requestId, bytes32) public {
    cancelPluginRequest(
      _requestId,
      ORACLE_PAYMENT,
      this.cancelRequestOnFulfill.selector,
      expiration);
  }

  function remove() public {
    selfdestruct(address(0));
  }

  function stealEthCall(bytes32 _requestId, bytes32) public recordPluginFulfillment(_requestId) {
    require(address(this).call.value(100)(), "Call failed"); // solhint-disable-line avoid-call-value
  }

  function stealEthSend(bytes32 _requestId, bytes32) public recordPluginFulfillment(_requestId) {
    // solhint-disable-next-line check-send-result
    require(address(this).send(100), "Send failed"); // solhint-disable-line multiple-sends
  }

  function stealEthTransfer(bytes32 _requestId, bytes32) public recordPluginFulfillment(_requestId) {
    address(this).transfer(100);
  }

  function doesNothing(bytes32, bytes32) public pure {} // solhint-disable-line no-empty-blocks
}
