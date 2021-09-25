pragma solidity ^0.4.24;

import "./PluginClient.sol";

/**
 * @title The Plugined contract
 * @notice Contract writers can inherit this contract in order to create requests for the
 * Plugin network. PluginClient is an alias of the Plugined contract.
 */
contract Plugined is PluginClient {
  /**
   * @notice Creates a request that can hold additional parameters
   * @param _specId The Job Specification ID that the request will be created for
   * @param _callbackAddress The callback address that the response will be sent to
   * @param _callbackFunctionSignature The callback function signature to use for the callback address
   * @return A Plugin Request struct in memory
   */
  function newRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Plugin.Request memory) {
    return buildPluginRequest(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  /**
   * @notice Creates a Plugin request to the stored oracle address
   * @dev Calls `sendPluginRequestTo` with the stored oracle address
   * @param _req The initialized Plugin Request
   * @param _payment The amount of PLI to send for the request
   * @return The request ID
   */
  function pluginRequest(Plugin.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
  {
    return sendPluginRequest(_req, _payment);
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
  function pluginRequestTo(address _oracle, Plugin.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {
    return sendPluginRequestTo(_oracle, _req, _payment);
  }

  /**
   * @notice Sets the stored oracle address
   * @param _oracle The address of the oracle contract
   */
  function setOracle(address _oracle) internal {
    setPluginOracle(_oracle);
  }

  /**
   * @notice Sets the PLI token address
   * @param _pli The address of the PLI token contract
   */
  function setPliToken(address _pli) internal {
    setPluginToken(_pli);
  }

  /**
   * @notice Retrieves the stored address of the PLI token
   * @return The address of the PLI token
   */
  function pluginToken()
    internal
    view
    returns (address)
  {
    return pluginTokenAddress();
  }

  /**
   * @notice Retrieves the stored address of the oracle contract
   * @return The address of the oracle contract
   */
  function oracleAddress()
    internal
    view
    returns (address)
  {
    return pluginOracleAddress();
  }

  /**
   * @notice Ensures that the fulfillment is valid for this contract
   * @dev Use if the contract developer prefers methods instead of modifiers for validation
   * @param _requestId The request ID for fulfillment
   */
  function fulfillPluginRequest(bytes32 _requestId)
    internal
    recordPluginFulfillment(_requestId)
    // solhint-disable-next-line no-empty-blocks
  {}

  /**
   * @notice Sets the stored oracle and PLI token contracts with the addresses resolved by ENS
   * @dev Accounts for subnodes having different resolvers
   * @param _ens The address of the ENS contract
   * @param _node The ENS node hash
   */
  function setPluginWithENS(address _ens, bytes32 _node)
    internal
  {
    usePluginWithENS(_ens, _node);
  }

  /**
   * @notice Sets the stored oracle contract with the address resolved by ENS
   * @dev This may be called on its own as long as `setPluginWithENS` has been called previously
   */
  function setOracleWithENS()
    internal
  {
    updatePluginOracleWithENS();
  }

  /**
   * @notice Allows for a request which was created on another contract to be fulfilled
   * on this contract
   * @param _oracle The address of the oracle contract that will fulfill the request
   * @param _requestId The request ID used for the response
   */
  function addExternalRequest(address _oracle, bytes32 _requestId)
    internal
  {
    addPluginExternalRequest(_oracle, _requestId);
  }
}
