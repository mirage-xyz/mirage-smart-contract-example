
var _b = {
  isConnected: false,
  web3: null,
  account: null,
  chainId: null,
  networkType: null,
  onAccountsChanged: null,
  onChainChanged: null,
};


_b.initWeb3 = async () => {
    if (window.ethereum) {
      _b.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
      window.ethereum.on('accountsChanged', async (e) => {
        console.log('accountsChanged');
        _b.isConnected = e.length > 0;
        if (_b.onAccountsChanged) {
          _b.onAccountsChanged(e);
        }
      });
      window.ethereum.on('chainChanged', async (e) => {
        console.log('chainChanged');
        _b.networkType = await _b.web3.eth.net.getNetworkType(); // main || private
        _b.chainId = await _b.web3.eth.net.getId();
        if (_b.onChainChanged) {
          _b.onChainChanged(e);
        }
      });

      _b.networkType = await _b.web3.eth.net.getNetworkType();
      _b.chainId = await _b.web3.eth.net.getId();

      const accounts = await _b.web3.eth.getAccounts();
      let { selectedAddress } = window.ethereum;
  
      if (selectedAddress) {
        _b.account = selectedAddress;
        _b.isConnected = true;
      } else if (accounts && accounts.length > 0) {
        _b.account = accounts[0];
        _b.isConnected = true;
      }
    } else {
      console.error('NOT ANY WALLET PLUGIN ISTALLED (Metamask or Celo Wallet)');
    }
};

_b.getContract = async (abiName, contractAddr) => {
  if (_b.web3) {
    const abi = ABIs[abiName];
    return new _b.web3.eth.Contract(abi, contractAddr);
  }
  return null;
};

_b.getInstance = async function(privateKey) {
    return createWallet(privateKey);
}


window.blockchain = _b;