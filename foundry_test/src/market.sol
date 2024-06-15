// SPDX-License-Identifier: S7iter
pragma solidity 0.8.20;

contract HashLock {
    struct Lock {
        uint256 amount;
        bytes32 hashLock;
        uint256 timelock;
        address payable sender;
        address payable receiver;
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    mapping(bytes32 => Lock) public locks;

    event Locked(bytes32 indexed lockId, address indexed sender, address indexed receiver, uint256 amount, bytes32 hashLock, uint256 timelock);
    event Withdrawn(bytes32 indexed lockId, bytes32 preimage);
    event Refunded(bytes32 indexed lockId);

    function createLock(bytes32 _hashLock, uint256 _timelock, address payable _receiver) internal returns (bytes32 lockId) {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_timelock > block.timestamp, "Timelock must be in the future");

        lockId = keccak256(abi.encodePacked(msg.sender, _receiver, msg.value, _hashLock, _timelock));   //创建密码
        require(locks[lockId].sender == address(0), "Lock already exists");

        locks[lockId] = Lock({
            amount: msg.value,
            hashLock: _hashLock,
            timelock: _timelock,
            sender: payable(msg.sender),
            receiver: _receiver,
            withdrawn: false,
            refunded: false,
            preimage: bytes32(0)
        });

        emit Locked(lockId, msg.sender, _receiver, msg.value, _hashLock, _timelock);
    }

    function withdrawLock(bytes32 _lockId, bytes32 _preimage) internal {
        Lock storage lock = locks[_lockId];

        require(lock.amount > 0, "Lock does not exist");
        require(lock.withdrawn == false, "Already withdrawn");
        require(lock.refunded == false, "Already refunded");
        require(keccak256(abi.encodePacked(_preimage)) == lock.hashLock, "Invalid preimage");

        lock.withdrawn = true;
        lock.preimage = _preimage;
        lock.receiver.transfer(lock.amount);

        emit Withdrawn(_lockId, _preimage);
    }

    function refundLock(bytes32 _lockId) internal {
        Lock storage lock = locks[_lockId];

        require(lock.amount > 0, "Lock does not exist");
        require(lock.withdrawn == false, "Already withdrawn");
        require(lock.refunded == false, "Already refunded");
        require(block.timestamp >= lock.timelock, "Timelock not yet passed");

        lock.refunded = true;
        lock.sender.transfer(lock.amount);

        emit Refunded(_lockId);
    }
}


//-------main-------
contract C2CPlatform is HashLock {
    enum TradeStatus { Pending, Locked, Complete, Cancelled }

    struct Trade {
        address payable seller;
        address payable buyer;
        uint amount;
        TradeStatus status;
        bytes32 hashLock;
        uint256 timelock;
        bytes32 lockId;
    }

    mapping(uint => Trade) public trades;
    uint public tradeCounter;

    event TradeCreated(uint tradeId, address seller, address buyer, uint amount, bytes32 hashLock, uint256 timelock);
    event TradeLocked(uint tradeId);
    event TradeConfirmed(uint tradeId, address confirmer);
    event TradeCancelled(uint tradeId);


    //创建交易 !!!!!需要测试，存在安全问题
    function createTrade(address payable _seller, bytes32 _hashLock, uint256 _timelock) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_timelock > block.timestamp, "Timelock must be in the future");

        bytes32 lockId = createLock(_hashLock, _timelock, _seller);

        trades[tradeCounter] = Trade({
            seller: _seller,
            buyer: payable(msg.sender),
            amount: msg.value,
            status: TradeStatus.Pending,
            hashLock: _hashLock,
            timelock: _timelock,
            lockId: lockId
        });

        emit TradeCreated(tradeCounter, _seller, msg.sender, msg.value, _hashLock, _timelock);
        tradeCounter++;
    }

    function lockFunds(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can lock funds");
        require(trade.status == TradeStatus.Pending, "Trade is not in pending state");

        trade.status = TradeStatus.Locked;
        emit TradeLocked(_tradeId);
    }

    //确认收货 !!!需要测试
    function confirmReceipt(uint _tradeId, bytes32 _preimage) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can confirm receipt");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");    //
        require(keccak256(abi.encodePacked(_preimage)) == trade.hashLock, "Invalid preimage");

        withdrawLock(trade.lockId, _preimage);
        trade.status = TradeStatus.Complete;

        emit TradeConfirmed(_tradeId, msg.sender);
    }

    function confirmShipment(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.seller, "Only seller can confirm shipment");
        require(trade.status == TradeStatus.Locked, "Funds are not locked");

        trade.status = TradeStatus.Complete;
        emit TradeConfirmed(_tradeId, msg.sender);
    }

    function cancelTrade(uint _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(msg.sender == trade.buyer, "Only buyer can cancel trade");
        require(trade.status == TradeStatus.Pending, "Cannot cancel non-pending trade");

        refundLock(trade.lockId);
        trade.status = TradeStatus.Cancelled;

        emit TradeCancelled(_tradeId);
    }
}
