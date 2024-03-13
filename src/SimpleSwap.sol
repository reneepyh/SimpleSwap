// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestERC20.sol";

contract SimpleSwap {
  // phase 1
  TestERC20 public token0;
  TestERC20 public token1;

  // phase 2
  uint256 public totalSupply = 0;
  mapping(address => uint256) public share;

  // MySwap：用於追蹤swap次數
  uint256 public transactionCount;

  constructor(address _token0, address _token1) {
    token0 = TestERC20(_token0);
    token1 = TestERC20(_token1);
  }

  function swap(address _tokenIn, uint256 _amountIn) public {
    if (_tokenIn == address(token0)) {
      token0.transferFrom(msg.sender, address(this), _amountIn);
      token1.transfer(msg.sender, _amountIn);
    } else if (_tokenIn == address(token1)){
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, _amountIn);
    }
  }

  function mySwap(address _tokenIn, uint256 _amountIn) public {
    uint256 priceAdjustmentFactor = 1 + transactionCount / 100; //隨著swap次數增加，計算價格調整參數，使幣價越來越貴

    if (_tokenIn == address(token0)) {
      uint256 amountOut = _amountIn / priceAdjustmentFactor;
    
      token0.transferFrom(msg.sender, address(this), _amountIn);
      token1.transfer(msg.sender, amountOut);
    } else if (_tokenIn == address(token1)) {
      uint256 amountOut = _amountIn / priceAdjustmentFactor;
    
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, amountOut);
    }

    transactionCount++;
  }

  // phase 1
  function addLiquidity1(uint256 _amount) public {
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
  }

  function removeLiquidity1() public {
    token0.transfer(msg.sender, token0.balanceOf(address(this)));
    token1.transfer(msg.sender, token1.balanceOf(address(this)));
  }

  // phase 2
  function addLiquidity2(uint256 _amount) public {
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
    share[msg.sender] += _amount;
    totalSupply += _amount;
  }

  function removeLiquidity2() public {
    uint256 userShare = share[msg.sender];
   
    uint256 token0Amount = userShare * token0.balanceOf(address(this)) / totalSupply;
    uint256 token1Amount = userShare * token1.balanceOf(address(this)) / totalSupply;

    totalSupply -= userShare;
    share[msg.sender] = 0;

    token0.transfer(msg.sender, token0Amount);
    token1.transfer(msg.sender, token1Amount);
  }
}