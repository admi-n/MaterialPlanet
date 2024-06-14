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

    function lock(bytes32 _hashLock, uint256 _timelock, address payable _receiver) external payable returns (bytes32 lockId) {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_timelock > block.timestamp, "Timelock must be in the future");

        lockId = keccak256(abi.encodePacked(msg.sender, _receiver, msg.value, _hashLock, _timelock));
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

    function withdraw(bytes32 _lockId, bytes32 _preimage) external {
        Lock storage lock = locks[_lockId];

        require(lock.amount > 0, "Lock does not exist");
        require(lock.receiver == msg.sender, "Not the receiver");
        require(lock.withdrawn == false, "Already withdrawn");
        require(lock.refunded == false, "Already refunded");
        require(keccak256(abi.encodePacked(_preimage)) == lock.hashLock, "Invalid preimage");

        lock.withdrawn = true;
        lock.preimage = _preimage;
        lock.receiver.transfer(lock.amount);

        emit Withdrawn(_lockId, _preimage);
    }

    function refund(bytes32 _lockId) external {
        Lock storage lock = locks[_lockId];

        require(lock.amount > 0, "Lock does not exist");
        require(lock.sender == msg.sender, "Not the sender");
        require(lock.withdrawn == false, "Already withdrawn");
        require(lock.refunded == false, "Already refunded");
        require(block.timestamp >= lock.timelock, "Timelock not yet passed");

        lock.refunded = true;
        lock.sender.transfer(lock.amount);

        emit Refunded(_lockId);
    }
}
