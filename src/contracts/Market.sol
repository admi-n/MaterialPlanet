// SPDX-License-Identifier: S7iter
pragma solidity ^0.8.20;

contract C2CPlatform {
    // 定义买卖双方的状态
    enum TradeStatus { Pending, Locked, Complete }

    struct Trade {
        address payable seller;
        address payable buyer;
        uint amount;
        TradeStatus status;
    }

    // 交易ID到交易详情的映射
    mapping(uint => Trade) public trades;
    uint public tradeCounter;

    // 创建新交易
    function createTrade(address payable _seller) external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        trades[tradeCounter] = Trade({
            seller: _seller,
            buyer: payable(msg.sender),
            amount: msg.value,
            status: TradeStatus.Pending
        });

        tradeCounter++;
    }

    // 锁定资金
    function lockFunds(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can lock funds");
        require(trade.status == TradeStatus.Pending, "Trade is not in pending state");

        trade.status = TradeStatus.Locked;
    }

    // 卖家确认收款并发货
    function confirmShipment(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.seller, "Only seller can confirm shipment");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");

        trade.status = TradeStatus.Complete;
        trade.seller.transfer(trade.amount);
    }

    // 取消交易并退还资金
    function cancelTrade(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can cancel trade");
        require(trade.status == TradeStatus.Pending, "Cannot cancel non-pending trade");

        trade.status = TradeStatus.Complete;
        trade.buyer.transfer(trade.amount);
    }
}
