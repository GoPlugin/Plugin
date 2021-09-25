pragma solidity 0.4.24;

import "./MaliciousPlugin.sol";
import "../Plugined.sol";
import "../vendor/SafeMathPlugin.sol";

contract MaliciousPlugined is Plugined {
  using MaliciousPlugin for MaliciousPlugin.Request;
  using MaliciousPlugin for MaliciousPlugin.WithdrawRequest;
  using Plugin for Plugin.Request;
  using SafeMathPlugin for uint256;

  uint256 private maliciousRequests = 1;
  mapping(bytes32 => address) private maliciousPendingRequests;

  function newWithdrawRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunction
  ) internal pure returns (MaliciousPlugin.WithdrawRequest memory) {
    MaliciousPlugin.WithdrawRequest memory req;
    return req.initializeWithdraw(_specId, _callbackAddress, _callbackFunction);
  }

  function pluginTargetRequest(address _target, Plugin.Request memory _req, uint256 _amount)
    internal
    returns(bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(_target, maliciousRequests));
    _req.nonce = maliciousRequests;
    maliciousPendingRequests[requestId] = oracleAddress();
    emit PluginRequested(requestId);
    PliTokenInterface pli = PliTokenInterface(pluginToken());
    require(pli.transferAndCall(oracleAddress(), _amount, encodeTargetRequest(_req)), "Unable to transferAndCall to oracle");
    maliciousRequests += 1;

    return requestId;
  }

  function pluginPriceRequest(Plugin.Request memory _req, uint256 _amount)
    internal
    returns(bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, maliciousRequests));
    _req.nonce = maliciousRequests;
    maliciousPendingRequests[requestId] = oracleAddress();
    emit PluginRequested(requestId);
    PliTokenInterface pli = PliTokenInterface(pluginToken());
    require(pli.transferAndCall(oracleAddress(), _amount, encodePriceRequest(_req)), "Unable to transferAndCall to oracle");
    maliciousRequests += 1;

    return requestId;
  }

  function pluginWithdrawRequest(MaliciousPlugin.WithdrawRequest memory _req, uint256 _wei)
    internal
    returns(bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, maliciousRequests));
    _req.nonce = maliciousRequests;
    maliciousPendingRequests[requestId] = oracleAddress();
    emit PluginRequested(requestId);
    PliTokenInterface pli = PliTokenInterface(pluginToken());
    require(pli.transferAndCall(oracleAddress(), _wei, encodeWithdrawRequest(_req)), "Unable to transferAndCall to oracle");
    maliciousRequests += 1;
    return requestId;
  }

  function encodeWithdrawRequest(MaliciousPlugin.WithdrawRequest memory _req)
    internal pure returns (bytes memory)
  {
    return abi.encodeWithSelector(
      bytes4(keccak256("withdraw(address,uint256)")),
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      _req.buf.buf);
  }

  function encodeTargetRequest(Plugin.Request memory _req)
    internal pure returns (bytes memory)
  {
    return abi.encodeWithSelector(
      bytes4(keccak256("oracleRequest(address,uint256,bytes32,address,bytes4,uint256,uint256,bytes)")),
      0, // overridden by onTokenTransfer
      0, // overridden by onTokenTransfer
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      1,
      _req.buf.buf);
  }

  function encodePriceRequest(Plugin.Request memory _req)
    internal pure returns (bytes memory)
  {
    return abi.encodeWithSelector(
      bytes4(keccak256("oracleRequest(address,uint256,bytes32,address,bytes4,uint256,uint256,bytes)")),
      0, // overridden by onTokenTransfer
      2000000000000000000, // overridden by onTokenTransfer
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      1,
      _req.buf.buf);
  }
}
