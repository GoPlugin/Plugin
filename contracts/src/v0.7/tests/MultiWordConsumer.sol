pragma solidity ^0.7.0;

import "../PluginClient.sol";

contract MultiWordConsumer is PluginClient{
  bytes32 internal specId;
  bytes public currentPrice;

  bytes32 public usd;
  bytes32 public eur;
  bytes32 public jpy;

  event RequestFulfilled(
    bytes32 indexed requestId,  // User-defined ID
    bytes indexed price
  );

  event RequestMultipleFulfilled(
    bytes32 indexed requestId,
    bytes32 indexed usd,
    bytes32 indexed eur,
    bytes32 jpy
  );

  constructor(
    address _pli,
    address _oracle,
    bytes32 _specId
  )
    public
  {
    setPluginToken(_pli);
    setPluginOracle(_oracle);
    specId = _specId;
  }

  function setSpecID(
    bytes32 _specId
  )
    public
  {
    specId = _specId;
  }

  function requestEthereumPrice(
    string memory _currency,
    uint256 _payment
  )
    public
  {
    requestEthereumPriceByCallback(_currency, _payment, address(this));
  }

  function requestEthereumPriceByCallback(
    string memory _currency,
    uint256 _payment,
    address _callback
  )
    public
  {
    Plugin.Request memory req = buildPluginRequest(specId, _callback, this.fulfillBytes.selector);
    requestOracleData(req, _payment);
  }

  function requestMultipleParameters(
    string memory _currency,
    uint256 _payment
  )
    public
  {
    Plugin.Request memory req = buildPluginRequest(specId, address(this), this.fulfillMultipleParameters.selector);
    requestOracleData(req, _payment);
  }

  function cancelRequest(
    address _oracle,
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  ) 
    public
  {
    PluginRequestInterface requested = PluginRequestInterface(_oracle);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function withdrawPli()
    public
  {
    PliTokenInterface _pli = PliTokenInterface(pluginTokenAddress());
    require(_pli.transfer(msg.sender, _pli.balanceOf(address(this))), "Unable to transfer");
  }

  function addExternalRequest(
    address _oracle,
    bytes32 _requestId
  )
    external
  {
    addPluginExternalRequest(_oracle, _requestId);
  }

  function fulfillMultipleParameters(
    bytes32 _requestId,
    bytes32 _usd,
    bytes32 _eur,
    bytes32 _jpy
  )
    public
    recordPluginFulfillment(_requestId)
  {
    emit RequestMultipleFulfilled(_requestId, _usd, _eur, _jpy);
    usd = _usd;
    eur = _eur;
    jpy = _jpy;
  }

  function fulfillBytes(
    bytes32 _requestId,
    bytes memory _price
  )
    public
    recordPluginFulfillment(_requestId)
  {
    emit RequestFulfilled(_requestId, _price);
    currentPrice = _price;
  }
}
