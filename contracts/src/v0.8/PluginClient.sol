// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Plugin.sol";
import "./interfaces/ENSInterface.sol";
import "./interfaces/PliTokenInterface.sol";
import "./interfaces/OperatorInterface.sol";
import "./interfaces/PointerInterface.sol";
import { ENSResolver as ENSResolver_Plugin } from "./vendor/ENSResolver.sol";

/**
 * @title The PluginClient contract
 * @notice Contract writers can inherit this contract in order to create requests for the
 * Plugin network
 */
contract PluginClient {
  using Plugin for Plugin.Request;

  uint256 constant internal PLI_DIVISIBILITY = 10**18;
  uint256 constant private AMOUNT_OVERRIDE = 0;
  address constant private SENDER_OVERRIDE = address(0);
  uint256 constant private ORACLE_ARGS_VERSION = 1;
  uint256 constant private OPERATOR_ARGS_VERSION = 2;
  bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("pli");
  bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant private PLI_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private ens;
  bytes32 private ensNode;
  PliTokenInterface private pli;
  OperatorInterface private oracle;
  uint256 private requestCount = 1;
  mapping(bytes32 => address) private pendingRequests;

  event PluginRequested(
    bytes32 indexed id
  );
  event PluginFulfilled(
    bytes32 indexed id
  );
  event PluginCancelled(
    bytes32 indexed id
  );

  /**
   * @notice Creates a request that can hold additional parameters
   * @param specId The Job Specification ID that the request will be created for
   * @param callbackAddress The callback address that the response will be sent to
   * @param callbackFunctionSignature The callback function signature to use for the callback address
   * @return A Plugin Request struct in memory
   */
  function buildPluginRequest(
    bytes32 specId,
    address callbackAddress,
    bytes4 callbackFunctionSignature
  )
    internal
    pure
    returns (
      Plugin.Request memory
    )
  {
    Plugin.Request memory req;
    return req.initialize(specId, callbackAddress, callbackFunctionSignature);
  }

  /**
   * @notice Creates a Plugin request to the stored oracle address
   * @dev Calls `pluginRequestTo` with the stored oracle address
   * @param req The initialized Plugin Request
   * @param payment The amount of PLI to send for the request
   * @return requestId The request ID
   */
  function sendPluginRequest(
    Plugin.Request memory req,
    uint256 payment
  )
    internal
    returns (
      bytes32
    )
  {
    return sendPluginRequestTo(address(oracle), req, payment);
  }

  /**
   * @notice Creates a Plugin request to the specified oracle address
   * @dev Generates and stores a request ID, increments the local nonce, and uses `transferAndCall` to
   * send PLI which creates a request on the target oracle contract.
   * Emits PluginRequested event.
   * @param oracleAddress The address of the oracle for the request
   * @param req The initialized Plugin Request
   * @param payment The amount of PLI to send for the request
   * @return requestId The request ID
   */
  function sendPluginRequestTo(
    address oracleAddress,
    Plugin.Request memory req,
    uint256 payment
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    return rawRequest(oracleAddress, req, payment, ORACLE_ARGS_VERSION, oracle.oracleRequest.selector);
  }

  /**
   * @notice Creates a Plugin request to the stored oracle address
   * @dev This function supports multi-word response
   * @dev Calls `requestOracleDataFrom` with the stored oracle address
   * @param req The initialized Plugin Request
   * @param payment The amount of PLI to send for the request
   * @return requestId The request ID
   */
  function requestOracleData(
    Plugin.Request memory req,
    uint256 payment
  )
    internal
    returns (
      bytes32
    )
  {
    return requestOracleDataFrom(address(oracle), req, payment);
  }

  /**
   * @notice Creates a Plugin request to the specified oracle address
   * @dev This function supports multi-word response
   * @dev Generates and stores a request ID, increments the local nonce, and uses `transferAndCall` to
   * send PLI which creates a request on the target oracle contract.
   * Emits PluginRequested event.
   * @param oracleAddress The address of the oracle for the request
   * @param req The initialized Plugin Request
   * @param payment The amount of PLI to send for the request
   * @return requestId The request ID
   */
  function requestOracleDataFrom(
    address oracleAddress,
    Plugin.Request memory req,
    uint256 payment
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    return rawRequest(oracleAddress, req, payment, OPERATOR_ARGS_VERSION, oracle.requestOracleData.selector);
  }

  /**
   * @notice Make a request to an oracle
   * @param oracleAddress The address of the oracle for the request
   * @param req The initialized Plugin Request
   * @param payment The amount of PLI to send for the request
   * @param argsVersion The version of data support (single word, multi word)
   * @return requestId The request ID
   */
  function rawRequest(
    address oracleAddress,
    Plugin.Request memory req,
    uint256 payment,
    uint256 argsVersion,
    bytes4 funcSelector
  )
    private
    returns (
      bytes32 requestId
    )
  {
    requestId = keccak256(abi.encodePacked(this, requestCount));
    req.nonce = requestCount;
    pendingRequests[requestId] = oracleAddress;
    emit PluginRequested(requestId);
    bytes memory encodedData = abi.encodeWithSelector(
      funcSelector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of PLI sent
      req.id,
      req.callbackAddress,
      req.callbackFunctionId,
      req.nonce,
      argsVersion,
      req.buf.buf);
    require(pli.transferAndCall(oracleAddress, payment, encodedData), "unable to transferAndCall to oracle");
    requestCount += 1;
  }

  /**
   * @notice Allows a request to be cancelled if it has not been fulfilled
   * @dev Requires keeping track of the expiration value emitted from the oracle contract.
   * Deletes the request from the `pendingRequests` mapping.
   * Emits PluginCancelled event.
   * @param requestId The request ID
   * @param payment The amount of PLI sent for the request
   * @param callbackFunc The callback function specified for the request
   * @param expiration The time of the expiration for the request
   */
  function cancelPluginRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunc,
    uint256 expiration
  )
    internal
  {
    OperatorInterface requested = OperatorInterface(pendingRequests[requestId]);
    delete pendingRequests[requestId];
    emit PluginCancelled(requestId);
    requested.cancelOracleRequest(requestId, payment, callbackFunc, expiration);
  }

  /**
   * @notice Sets the stored oracle address
   * @param oracleAddress The address of the oracle contract
   */
  function setPluginOracle(
    address oracleAddress
  )
    internal
  {
    oracle = OperatorInterface(oracleAddress);
  }

  /**
   * @notice Sets the PLI token address
   * @param pliAddress The address of the PLI token contract
   */
  function setPluginToken(
    address pliAddress
  )
    internal
  {
    pli = PliTokenInterface(pliAddress);
  }

  /**
   * @notice Sets the Plugin token address for the public
   * network as given by the Pointer contract
   */
  function setPublicPluginToken() 
    internal
  {
    setPluginToken(PointerInterface(PLI_TOKEN_POINTER).getAddress());
  }

  /**
   * @notice Retrieves the stored address of the PLI token
   * @return The address of the PLI token
   */
  function pluginTokenAddress()
    internal
    view
    returns (
      address
    )
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
    returns (
      address
    )
  {
    return address(oracle);
  }

  /**
   * @notice Allows for a request which was created on another contract to be fulfilled
   * on this contract
   * @param oracleAddress The address of the oracle contract that will fulfill the request
   * @param requestId The request ID used for the response
   */
  function addPluginExternalRequest(
    address oracleAddress,
    bytes32 requestId
  )
    internal
    notPendingRequest(requestId)
  {
    pendingRequests[requestId] = oracleAddress;
  }

  /**
   * @notice Sets the stored oracle and PLI token contracts with the addresses resolved by ENS
   * @dev Accounts for subnodes having different resolvers
   * @param ensAddress The address of the ENS contract
   * @param node The ENS node hash
   */
  function usePluginWithENS(
    address ensAddress,
    bytes32 node
  )
    internal
  {
    ens = ENSInterface(ensAddress);
    ensNode = node;
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
   * @notice Ensures that the fulfillment is valid for this contract
   * @dev Use if the contract developer prefers methods instead of modifiers for validation
   * @param requestId The request ID for fulfillment
   */
  function validatePluginCallback(
    bytes32 requestId
  )
    internal
    recordPluginFulfillment(requestId)
    // solhint-disable-next-line no-empty-blocks
  {}

  /**
   * @dev Reverts if the sender is not the oracle of the request.
   * Emits PluginFulfilled event.
   * @param requestId The request ID for fulfillment
   */
  modifier recordPluginFulfillment(
    bytes32 requestId
  )
  {
    require(msg.sender == pendingRequests[requestId],
            "Source must be the oracle of the request");
    delete pendingRequests[requestId];
    emit PluginFulfilled(requestId);
    _;
  }

  /**
   * @dev Reverts if the request is already pending
   * @param requestId The request ID for fulfillment
   */
  modifier notPendingRequest(
    bytes32 requestId
  )
  {
    require(pendingRequests[requestId] == address(0), "Request is already pending");
    _;
  }
}
