// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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
  function addStringArray(string memory _key, bytes32[] memory _values) public {
    string[] memory strings = new string[](_values.length);
    for (uint256 i = 0; i < _values.length; i++) {
      strings[i] = bytes32ToString(_values[i]);
    }
    Plugin.Request memory r2 = req;
    r2.addStringArray(_key, strings);
    req = r2;
  }

  function bytes32ToString(bytes32 x) private pure returns (string memory) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
      byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
      if (char != 0) {
        bytesString[charCount] = char;
        charCount++;
      }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (uint j = 0; j < charCount; j++) {
      bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
  }
}
