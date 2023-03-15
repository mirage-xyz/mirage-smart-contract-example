//Usage example: 
//1. go to project root folder
//2. use command `node scripts/deploy.js GameItem GameCharacter` if you want to deploy two previously compiled contracts
//GameItem.sol and GameCharacter.sol localted in the contracts folder
//3. compiled bytecode should be deployed and you can use saved ABI to use the contract

const fs = require('fs');
const path = require('path');
const ethers = require('ethers');

//IMPORTANT: put your private key into 
// private_keys/deployment_private_key.txt file to make sure
//the script will work
const keysDir = path.resolve(__dirname, '..', 'private_keys');
const privateKeyPath = path.join(keysDir, `deployment_private_key.txt`);

if(!fs.existsSync(privateKeyPath))
{
    console.error('private_keys/deployment_private_key.txt not found in the project,' +
        ' private_keys folder is ignored by git, so you should create this file yourself');
    process.exit();
}

// Replace with your own private key and provider URL
const privateKey = fs.readFileSync(privateKeyPath, 'utf8').trim();

const providerUrl = 'https://goerli.infura.io/v3/0185114844aa42ea88c17fe4d329dcf3';

const contractBaseNames = process.argv.slice(2);

const abiDir = path.resolve(__dirname, '..', 'compiled-abi');
const bytecodeDir = path.resolve(__dirname, '..', 'compiled-bytecode');

const deployContract = async (abi, bytecode) => {
    const provider = new ethers.JsonRpcProvider(providerUrl);
    
    const wallet = new ethers.Wallet(privateKey, provider);

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const contract = await factory.deploy();
    await contract.deployed();

    return contract;
};

const deploymentLogPath = path.resolve(__dirname, '..', 'deployment_log.txt');

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

            // Save deployment information to the deployment_log.txt
            const deploymentInfo = `Contract ${contractBaseName} | Address: ${contract.address} | Transaction Hash: ${contract.deployTransaction.hash} | Gas Used: ${contract.deployTransaction.gasUsed.toString()}\n`;
            fs.appendFileSync(deploymentLogPath, deploymentInfo);
        
        } catch (error) {
            console.error(`Error deploying contract ${contractBaseName}:`, error);
        }
    } else {
        console.log(`ABI or bytecode file not found for contract ${contractBaseName}. Deployment skipped.`);
    }
});