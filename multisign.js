const Web3 = require('web3');

// Initialize Web3 with the provider of your choice
const web3 = new Web3('https://mainnet.infura.io/v3/your-project-id');

// Set the addresses of the signers
const signer1 = '0x1111111111111111111111111111111111111111';// address1
const signer2 = '0x2222222222222222222222222222222222222222';// address2
const signer3 = '0x3333333333333333333333333333333333333333';// address 3

// Set the number of required signatures
const requiredSignatures = 2; // value to confirm

// Set the token contract address and ABI
const tokenContractAddress = '0x0000000000000000000000000000000000000000'; // marketplace address
const tokenContractAbi = [...]; // marketplace abi 

// Set the recipient address and the amount to withdraw
const recipientAddress = '0x4444444444444444444444444444444444444444'; // recipient address
const amountToWithdraw = web3.utils.toWei('1', 'ether');

// Create the transaction data
const tokenContract = new web3.eth.Contract(tokenContractAbi, tokenContractAddress);
const transactionData = tokenContract.methods.transfer(recipientAddress, amountToWithdraw).encodeABI();

// Create the multisig transaction
const multisigTransaction = {
  to: tokenContractAddress,
  value: 0,
  data: transactionData,
  nonce: await web3.eth.getTransactionCount(signer1, 'pending'),
  gasPrice: await web3.eth.getGasPrice(),
  gasLimit: 100000,
  chainId: await web3.eth.getChainId(),
  v: [],
  r: [],
  s: []
};

// Sign the transaction with each signer
const signers = [signer1, signer2, signer3];
for (const signer of signers) {
  const signature = await web3.eth.signTransaction(multisigTransaction, signer);
  const { v, r, s } = web3.eth.accounts.decodeTransaction(signature);
  multisigTransaction.v.push(v);
  multisigTransaction.r.push(r);
  multisigTransaction.s.push(s);
}

// Submit the multisig transaction
const serializedTransaction = web3.eth.accounts.serializeTransaction(multisigTransaction);
const transactionHash = await web3.eth.sendSignedTransaction(serializedTransaction);
console.log(`Transaction hash: ${transactionHash}`);
