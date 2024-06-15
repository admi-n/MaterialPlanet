from web3 import Web3

def sercet(address):
    w3 = Web3()

    checksummed_address = w3.to_checksum_address(address)
    first_hash = Web3.solidity_keccak(['address'], [checksummed_address])
    second_hash = Web3.keccak(first_hash)
    return first_hash, second_hash

#模拟计算交易中的“密码”
#因为区块链中的数据都是公开透明的
#所以密码使用前端连接钱包后查询连接状态
#若连接成功，则在调用中进行_preimage和hashLock填充
address = '0x17F6AD8Ef982297579C203069C1DbfFE4348c372'
first_hash, second_hash = sercet(address)
print(f"Address: {address}")
print(f"_preimage: {first_hash.hex()}")
print(f"_hashLock: {second_hash.hex()}")
