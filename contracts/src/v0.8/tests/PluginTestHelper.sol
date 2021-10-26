// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Plugin.sol";
import "../vendor/CBORPlugin.sol";
import "../vendor/BufferPlugin.sol";

contract PluginTestHelper {
  using Plugin for Plugin.Request;
  using CBORPlugin for BufferPlugin.buffer;

  Plugin.Request private req;

  event RequestData(bytes payload);

  function closeEvent() public {
    emit RequestData(req.buf.buf);
  }

  function setBuffer(bytes memory data) public {
    Plugin.Request memory r2 = req;
    r2.setBuffer(data);
    req = r2;
  }

  function add(string memory _key, string memory _value) public {
    Plugin.Request memory r2 = req;
    r2.add(_key, _value);
    req = r2;
  }

  function addBytes(string memory _key, bytes memory _value) public {
    Plugin.Request memory r2 = req;
    r2.addBytes(_key, _value);
    req = r2;
  }

  function addInt(string memory _key, int256 _value) public {
    Plugin.Request memory r2 = req;
    r2.addInt(_key, _value);
    req = r2;
  }

  function addUint(string memory _key, uint256 _value) public {
    Plugin.Request memory r2 = req;
    r2.addUint(_key, _value);
    req = r2;
  }

  // Temporarily have method receive bytes32[] memory until experimental
  // string[] memory can be invoked from truffle tests.
  function addStringArray(string memory _key, string[] memory _values) public {
    Plugin.Request memory r2 = req;
    r2.addStringArray(_key, _values);
    req = r2;
  }
}
