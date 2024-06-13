// src/contracts/Marketplace.js
import Web3 from 'web3';
import contractABI from './C2CPlatform.json'; // 导入智能合约 ABI JSON 文件

const web3 = new Web3(Web3.givenProvider);
const abi = contractABI.abi; // 从 JSON 文件中获取 ABI
const contractAddress = '0xYourContractAddress'; // 智能合约的地址
const contract = new web3.eth.Contract(abi, contractAddress);

export default contract;
