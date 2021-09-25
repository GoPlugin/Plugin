pragma solidity ^0.4.24;

import "./Plugin.sol";
import "./interfaces/ENSInterface.sol";
import "./interfaces/PliTokenInterface.sol";
import "./interfaces/PluginRequestInterface.sol";
import "./interfaces/PointerInterface.sol";
import { ENSResolver as ENSResolver_Plugin } from "./vendor/ENSResolver.sol";

/**
 * @title The PluginClient contract
 * @notice Contract writers can inherit this contract in order to create requests for the
 * Plugin network
 */
contract PluginClient {
  using Plugin for Plugin.Request;

  uint256 constant internal PLI = 10**18;
  uint256 constant private AMOUNT_OVERRIDE = 0;
  address constant private SENDER_OVERRIDE = 0x0;
  uint256 constant private ARGS_VERSION = 1;
  bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("pli");
  bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant private PLI_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private ens;
  bytes32 private ensNode;
  PliTokenInterface private pli;
  PluginRequestInterface private oracle;
  uint256 private requests = 1;
  mapping(bytes32 => address) private pendingRequests;

  event PluginRequested(bytes32 indexed id);
  event PluginFulfilled(bytes32 indexed id);
  event PluginCancelled(bytes32 indexed id);

  /**
   * @notice Creates a request that can hold additional parameters
   * @param _specId The Job Specification ID that the request will be created for
   * @param _callbackAddress The callback address that the response will be sent to
   * @param _callbackFunctionSignature The callback function signature to use for the callback address
   * @return A Plugin Request struct in memory
   */
  function buildPluginRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Plugin.Request memory) {
    Plugin.Request memory req;
    return req.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  /**
   * @notice Creates a Plugin request to the stored oracle address
   * @dev Calls `pluginRequestTo` with the stored oracle address
   * @param _req The initialized Plugin Request
   * @param _payment The amount of PLI to send for the request
   * @return The request ID
   */
  function sendPluginRequest(Plugin.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
  {
    return sendPluginRequestTo(oracle, _req, _payment);
  }

  /**
   * @notice Creates a Plugin request to the specified oracle address
   * @dev Generates and stores a request ID, increments the local nonce, and uses `transferAndCall` to
   * send PLI which creates a request on the target oracle contract.
   * Emits PluginRequested event.
   * @param _oracle The address of the oracle for the request
   * @param _req The initialized Plugin Request
   * @param _payment The amount of PLI to send for the request
   * @return The request ID
   */
  function sendPluginRequestTo(address _oracle, Plugin.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, requests));
    _req.nonce = requests;
    pendingRequests[requestId] = _oracle;
    emit PluginRequested(requestId);
    require(pli.transferAndCall(_oracle, _payment, encodeRequest(_req)), "unable to transferAndCall to oracle");
    requests += 1;

    return requestId;
  }

  /**
   * @notice Allows a request to be cancelled if it has not been fulfilled
   * @dev Requires keeping track of the expiration value emitted from the oracle contract.
   * Deletes the request from the `pendingRequests` mapping.
   * Emits PluginCancelled event.
   * @param _requestId The request ID
   * @param _payment The amount of PLI sent for the request
   * @param _callbackFunc The callback function specified for the request
   * @param _expiration The time of the expiration for the request
   */
  function cancelPluginRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    internal
  {
    PluginRequestInterface requested = PluginRequestInterface(pendingRequests[_requestId]);
    delete pendingRequests[_requestId];
    emit PluginCancelled(_requestId);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunc, _expiration);
  }

  /**
   * @notice Sets the stored oracle address
   * @param _oracle The address of the oracle contract
   */
  function setPluginOracle(address _oracle) internal {
    oracle = PluginRequestInterface(_oracle);
  }

  /**
   * @notice Sets the PLI token address
   * @param _pli The address of the PLI token contract
   */
  function setPluginToken(address _pli) internal {
    pli = PliTokenInterface(_pli);
  }

  /**
   * @notice Sets the Plugin token address for the public
   * network as given by the Pointer contract
   */
  function setPublicPluginToken() internal {
    setPluginToken(PointerInterface(PLI_TOKEN_POINTER).getAddress());
  }

  /**
   * @notice Retrieves the stored address of the PLI token
   * @return The address of the PLI token
   */
  function pluginTokenAddress()
    internal
    view
    returns (address)
  {
    return address(pli);
  }

  /**
   * @notice Retrieves the stored address of the oracle contract
   * @return The address of the oracle contract
   */
  function pluginOracleAddress()
    internal
    view
    returns (address)
  {
    return address(oracle);
  }

  /**
   * @notice Allows for a request which was created on another contract to be fulfilled
   * on this contract
   * @param _oracle The address of the oracle contract that will fulfill the request
   * @param _requestId The request ID used for the response
   */
  function addPluginExternalRequest(address _oracle, bytes32 _requestId)
    internal
    notPendingRequest(_requestId)
  {
    pendingRequests[_requestId] = _oracle;
  }

  /**
   * @notice Sets the stored oracle and PLI token contracts with the addresses resolved by ENS
   * @dev Accounts for subnodes having different resolvers
   * @param _ens The address of the ENS contract
   * @param _node The ENS node hash
   */
  function usePluginWithENS(address _ens, bytes32 _node)
    internal
  {
    ens = ENSInterface(_ens);
    ensNode = _node;
    bytes32 pliSubnode = keccak256(abi.encodePacked(ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver_Plugin resolver = ENSResolver_Plugin(ens.resolver(pliSubnode));
    setPluginToken(resolver.addr(pliSubnode));
    updatePluginOracleWithENS();
  }

  /**
   * @notice Sets the stored oracle contract with the address resolved by ENS
   * @dev This may be called on its own as long as `usePluginWithENS` has been called previously
   */
  function updatePluginOracleWithENS()
    internal
  {
    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver_Plugin resolver = ENSResolver_Plugin(ens.resolver(oracleSubnode));
    setPluginOracle(resolver.addr(oracleSubnode));
  }

  /**
   * @notice Encodes the request to be sent to the oracle contract
   * @dev The Plugin node expects values to be in order for the request to be picked up. Order of types
   * will be validated in the oracle contract.
   * @param _req The initialized Plugin Request
   * @return The bytes payload for the `transferAndCall` method
   */
  function encodeRequest(Plugin.Request memory _req)
    private
    view
    returns (bytes memory)
  {
    return abi.encodeWithSelector(
      oracle.oracleRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of PLI sent
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      ARGS_VERSION,
      _req.buf.buf);
  }

  /**
   * @notice Ensures that the fulfillment is valid for this contract
   * @dev Use if the contract developer prefers methods instead of modifiers for validation
   * @param _requestId The request ID for fulfillment
   */
  function validatePluginCallback(bytes32 _requestId)
    internal
    recordPluginFulfillment(_requestId)
    // solhint-disable-next-line no-empty-blocks
  {}

  /**
   * @dev Reverts if the sender is not the oracle of the request.
   * Emits PluginFulfilled event.
   * @param _requestId The request ID for fulfillment
   */
  modifier recordPluginFulfillment(bytes32 _requestId) {
    require(msg.sender == pendingRequests[_requestId], "Source must be the oracle of the request");
    delete pendingRequests[_requestId];
    emit PluginFulfilled(_requestId);
    _;
  }

  /**
   * @dev Reverts if the request is already pending
   * @param _requestId The request ID for fulfillment
   */
  modifier notPendingRequest(bytes32 _requestId) {
    require(pendingRequests[_requestId] == address(0), "Request is already pending");
    _;
  }
}
