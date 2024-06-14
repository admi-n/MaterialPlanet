// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./HashLock.sol";

contract C2CPlatform is HashLock {
    // 定义买卖双方的状态
    enum TradeStatus { Pending, Locked, Complete, Cancelled }

    struct Trade {
        address payable seller;
        address payable buyer;
        uint amount;
        TradeStatus status;
        bytes32 hashLock;
        uint256 timelock;
    }

    // 交易ID到交易详情的映射
    mapping(uint => Trade) public trades;
    uint public tradeCounter;

    // 事件
    event TradeCreated(uint tradeId, address seller, address buyer, uint amount, bytes32 hashLock, uint256 timelock);
    event TradeLocked(uint tradeId);
    event TradeConfirmed(uint tradeId);
    event TradeCancelled(uint tradeId);

    // 创建新交易
    function createTrade(address payable _seller, bytes32 _hashLock, uint256 _timelock) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_timelock > block.timestamp, "Timelock must be in the future");

        trades[tradeCounter] = Trade({
            seller: _seller,
            buyer: payable(msg.sender),
            amount: msg.value,
            status: TradeStatus.Pending,
            hashLock: _hashLock,
            timelock: _timelock
        });

        emit TradeCreated(tradeCounter, _seller, msg.sender, msg.value, _hashLock, _timelock);
        tradeCounter++;
    }

    // 锁定资金
    function lockFunds(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can lock funds");
        require(trade.status == TradeStatus.Pending, "Trade is not in pending state");

        trade.status = TradeStatus.Locked;
        emit TradeLocked(_tradeId);
    }

    // 买家确认收货
    function confirmReceipt(uint _tradeId, bytes32 _preimage) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can confirm receipt");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");
        require(keccak256(abi.encodePacked(_preimage)) == trade.hashLock, "Invalid preimage");

        trade.status = TradeStatus.Complete;
        trade.seller.transfer(trade.amount);
        emit TradeConfirmed(_tradeId);
    }

    // 卖家确认发货
    function confirmShipment(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.seller, "Only seller can confirm shipment");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");

        trade.status = TradeStatus.Complete;
        emit TradeConfirmed(_tradeId);
    }

    // 取消交易并退还资金
    function cancelTrade(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can cancel trade");
        require(trade.status == TradeStatus.Pending, "Cannot cancel non-pending trade");

        trade.status = TradeStatus.Cancelled;
        trade.buyer.transfer(trade.amount);
        emit TradeCancelled(_tradeId);
    }
}
