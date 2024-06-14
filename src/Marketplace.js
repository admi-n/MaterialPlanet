// src/contracts/Marketplace.js
import Web3 from 'web3';
import contractABI from './contracts/C2CPlatform.json'; // 导入智能合约 ABI JSON 文件

const web3 = new Web3(Web3.givenProvider);
const abi = contractABI.abi; // 从 JSON 文件中获取 ABI
const contractAddress = '0x3bfccbcab52b0e78e1100ebfa2b357accc5ee53c'; // 智能合约的地址
//https://sepolia.etherscan.io/tx/0x61c3ac67ffa59fe82d7e5547ac2cb3797730c742ecdccd88df447f1752970324
const contract = new web3.eth.Contract(abi, contractAddress);

export default contract;
