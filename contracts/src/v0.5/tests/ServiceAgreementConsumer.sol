pragma solidity 0.5.0;

import "../PluginClient.sol";

contract ServiceAgreementConsumer is PluginClient {
  uint256 constant private ORACLE_PAYMENT = 1 * PLI;

  bytes32 internal sAId;
  bytes32 public currentPrice;

  constructor(address _pli, address _coordinator, bytes32 _sAId) public {
    setPluginToken(_pli);
    setPluginOracle(_coordinator);
    sAId = _sAId;
  }

  function requestEthereumPrice(string memory _currency) public {
    Plugin.Request memory req = buildPluginRequest(sAId, address(this), this.fulfill.selector);
    req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,JPY");
    req.add("path", _currency);
    sendPluginRequest(req, ORACLE_PAYMENT);
  }

  function fulfill(bytes32 _requestId, bytes32 _price)
    public
    recordPluginFulfillment(_requestId)
  {
    currentPrice = _price;
  }
}
