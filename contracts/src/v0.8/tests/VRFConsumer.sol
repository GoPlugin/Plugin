// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/PliTokenInterface.sol";
import "../VRFConsumerBase.sol";

contract VRFConsumer is VRFConsumerBase {

  uint256 public randomnessOutput;
  bytes32 public requestId;

  constructor(address vrfCoordinator, address pli)
    // solhint-disable-next-line no-empty-blocks
    VRFConsumerBase(vrfCoordinator, pli) { /* empty */ }

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal override
  {
    randomnessOutput = randomness;
    requestId = requestId;
  }

  function testRequestRandomness(bytes32 keyHash, uint256 fee)
    external returns (bytes32)
  {
    return requestRandomness(keyHash, fee);
  }
}
