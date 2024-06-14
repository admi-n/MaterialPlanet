import React, { useState } from 'react';
import Web3 from 'web3';
import MarketplaceContract from './Marketplace.js';

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [tradeId, setTradeId] = useState('');
  const [status, setStatus] = useState('');

  // 初始化Web3和智能合约
  const initWeb3 = async () => {
    if (window.ethereum) {
      const web3Instance = new Web3(window.ethereum);
      await window.ethereum.enable(); // 请求用户授权连接到以太坊网络
      setWeb3(web3Instance);

      const networkId = await web3Instance.eth.net.getId();
      const deployedNetwork = C2CPlatform.networks[networkId];
      const contractInstance = new web3Instance.eth.Contract(
        MarketplaceContract.abi, // 使用MarketplaceContract导入的智能合约实例
        deployedNetwork && deployedNetwork.address,
      );
      setContract(contractInstance);

      const accs = await web3Instance.eth.getAccounts();
      setAccounts(accs);
    } else {
      console.log('请安装MetaMask插件或使用其他以太坊兼容浏览器');
    }
  };

  // 创建交易
  const createTrade = async () => {
    const result = await contract.methods.createTrade(accounts[0]).send({ from: accounts[0], value: 1 });
    console.log('交易创建成功：', result);
  };

  // 锁定资金
  const lockFunds = async () => {
    const result = await contract.methods.lockFunds(tradeId).send({ from: accounts[0] });
    console.log('资金已锁定：', result);
  };

  // 买家确认收货
  const confirmReceipt = async () => {
    const result = await contract.methods.confirmReceipt(tradeId).send({ from: accounts[0] });
    console.log('确认收货：', result);
  };

  // 取消交易
  const cancelTrade = async () => {
    const result = await contract.methods.cancelTrade(tradeId).send({ from: accounts[0] });
    console.log('交易已取消：', result);
  };

  return (
    <div>
      <button onClick={initWeb3}>连接到以太坊网络</button>
      <button onClick={createTrade}>创建交易</button>
      <input type="text" placeholder="输入交易ID" onChange={(e) => setTradeId(e.target.value)} />
      <button onClick={lockFunds}>锁定资金</button>
      <button onClick={confirmReceipt}>确认收货</button>
      <button onClick={cancelTrade}>取消交易</button>
      <div>交易状态：{status}</div>
    </div>
  );
};

export default App;
