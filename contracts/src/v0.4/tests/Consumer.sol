pragma solidity 0.4.24;

import "../PluginClient.sol";

contract Consumer is PluginClient {
  bytes32 internal specId;
  bytes32 public currentPrice;

  uint256 constant private ORACLE_PAYMENT = 1 * PLI;

  event RequestFulfilled(
    bytes32 indexed requestId,  // User-defined ID
    bytes32 indexed price
  );

  function requestEthereumPrice(string _currency) public {
    Plugin.Request memory req = buildPluginRequest(specId, this, this.fulfill.selector);
    req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,JPY");
    string[] memory path = new string[](1);
    path[0] = _currency;
    req.addStringArray("path", path);
    sendPluginRequest(req, ORACLE_PAYMENT);
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  ) public {
    cancelPluginRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function withdrawPli() public {
    PliTokenInterface pli = PliTokenInterface(pluginTokenAddress());
    require(pli.transfer(msg.sender, pli.balanceOf(address(this))), "Unable to transfer");
  }

  function fulfill(bytes32 _requestId, bytes32 _price)
    public
    recordPluginFulfillment(_requestId)
  {
    emit RequestFulfilled(_requestId, _price);
    currentPrice = _price;
  }

}
