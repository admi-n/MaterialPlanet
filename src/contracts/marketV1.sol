// SPDX-License-Identifier: S7iter
pragma solidity ^0.8.20;

contract C2CPlatform {
    // 定义买卖双方的状态
    enum TradeStatus { Pending, Locked, Shipped, Complete, Cancelled }

    struct Trade {
        address payable seller;
        address payable buyer;
        uint amount;
        TradeStatus status;
    }

    // 交易ID到交易详情的映射
    mapping(uint => Trade) public trades;
    uint public tradeCounter;

    // 事件
    event TradeCreated(uint tradeId, address seller, address buyer, uint amount);
    event TradeLocked(uint tradeId);
    event TradeShipped(uint tradeId);
    event TradeConfirmed(uint tradeId);
    event TradeCancelled(uint tradeId);

    // 创建新交易
    function createTrade(address payable _seller) external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        trades[tradeCounter] = Trade({
            seller: _seller,
            buyer: payable(msg.sender),
            amount: msg.value,
            status: TradeStatus.Pending
        });

        emit TradeCreated(tradeCounter, _seller, msg.sender, msg.value);
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

    // 卖家确认发货
    function confirmShipment(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.seller, "Only seller can confirm shipment");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");

        trade.status = TradeStatus.Shipped;
        emit TradeShipped(_tradeId);
    }

    // 买家确认收货
    function confirmReceipt(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can confirm receipt");
        require(trade.status == TradeStatus.Shipped, "Goods are not shipped yet");

        trade.status = TradeStatus.Complete;
        trade.seller.transfer(trade.amount);
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
