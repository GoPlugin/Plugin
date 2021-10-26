pragma solidity 0.4.24;

import "../Plugined.sol";
import "../vendor/SafeMathPlugin.sol";

contract ConcretePlugined is Plugined {
  using SafeMathPlugin for uint256;

  constructor(address _pli, address _oracle) public {
    setPliToken(_pli);
    setOracle(_oracle);
  }

  event Request(
    bytes32 id,
    address callbackAddress,
    bytes4 callbackfunctionSelector,
    bytes data
  );

  function publicNewRequest(
    bytes32 _id,
    address _address,
    bytes _fulfillmentSignature
  )
    public
  {
    Plugin.Request memory req = newRequest(
      _id, _address, bytes4(keccak256(_fulfillmentSignature)));
    emit Request(
      req.id,
      req.callbackAddress,
      req.callbackFunctionId,
      req.buf.buf
    );
  }

  function publicRequest(
    bytes32 _id,
    address _address,
    bytes _fulfillmentSignature,
    uint256 _wei
  )
    public
  {
    Plugin.Request memory req = newRequest(
      _id, _address, bytes4(keccak256(_fulfillmentSignature)));
    pluginRequest(req, _wei);
  }

  function publicRequestRunTo(
    address _oracle,
    bytes32 _id,
    address _address,
    bytes _fulfillmentSignature,
    uint256 _wei
  )
    public
  {
    Plugin.Request memory run = newRequest(_id, _address, bytes4(keccak256(_fulfillmentSignature)));
    pluginRequestTo(_oracle, run, _wei);
  }

  function publicCancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  ) public {
    cancelPluginRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function publicPluginToken() public view returns (address) {
    return pluginToken();
  }

  function fulfillRequest(bytes32 _requestId, bytes32)
    public
    recordPluginFulfillment(_requestId)
  {} // solhint-disable-line no-empty-blocks

  function publicFulfillPluginRequest(bytes32 _requestId, bytes32) public {
    fulfillPluginRequest(_requestId);
  }

  event PliAmount(uint256 amount);

  function publicPLI(uint256 _amount) public {
    emit PliAmount(PLI.mul(_amount));
  }

  function publicOracleAddress() public view returns (address) {
    return oracleAddress();
  }

  function publicAddExternalRequest(address _oracle, bytes32 _requestId)
    public
  {
    addExternalRequest(_oracle, _requestId);
  }
}
