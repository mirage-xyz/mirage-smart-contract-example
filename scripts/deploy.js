const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');

const contractBaseNames = process.argv.slice(2);

const abiDir = path.resolve(__dirname, '..', 'compiled-abi');
const bytecodeDir = path.resolve(__dirname, '..', 'compiled-bytecode');

// Replace with your own private key and provider URL
const privateKey = 'your_private_key_here';
const providerUrl = 'https://goerli.infura.io/v3/your_infura_project_id_here';

const deployContract = async (abi, bytecode) => {
    const provider = new ethers.providers.JsonRpcProvider(providerUrl);
    const wallet = new ethers.Wallet(privateKey, provider);

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const contract = await factory.deploy();
    await contract.deployed();

    return contract;
};

contractBaseNames.forEach(async (contractBaseName) => {
    const abiPath = path.join(abiDir, `${contractBaseName}_abi.txt`);
    const bytecodePath = path.join(bytecodeDir, `${contractBaseName}_bytecode.txt`);

    if (fs.existsSync(abiPath) && fs.existsSync(bytecodePath)) {
        const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8'));
        const bytecode = fs.readFileSync(bytecodePath, 'utf8');

        try {
            const contract = await deployContract(abi, bytecode);
            console.log(`Contract ${contractBaseName} successfully deployed:`);
            console.log(`- Address: ${contract.address}`);
            console.log(`- Transaction Hash: ${contract.deployTransaction.hash}`);
            console.log(`- Gas Used: ${contract.deployTransaction.gasUsed.toString()}`);
        } catch (error) {
            console.error(`Error deploying contract ${contractBaseName}:`, error);
        }
    } else {
        console.log(`ABI or bytecode file not found for contract ${contractBaseName}. Deployment skipped.`);
    }
});