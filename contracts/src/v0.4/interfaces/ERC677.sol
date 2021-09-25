pragma solidity ^0.4.8;

import { ERC20 as pliERC20 } from "./ERC20.sol";

contract ERC677 is pliERC20 {
  function transferAndCall(address to, uint value, bytes data) returns (bool success);

  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
