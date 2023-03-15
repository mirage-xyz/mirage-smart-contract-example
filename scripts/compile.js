//Usage example: 
//1. go to project root folder
//2. use command `node scripts/compile.js GameItem.sol GameCharacter.sol`
//3. compiled bytecode and abi should be saved in corresponding folders compiled-bytecode and compiled-abi

const path = require('path')
const fs = require('fs')
const solc = require('solc')

const nodeModulesUsedInContractsPrefixes = ['@openzeppelin', 'hardhat']

const contractNames = process.argv.slice(2);

const findImports = (importPath) => {
    try {
        if(nodeModulesUsedInContractsPrefixes.some(prefix => importPath.startsWith(prefix)))
        {
            var resolvedPath = path.resolve(__dirname, '..', 'node_modules', importPath);
        }
        else
        {
            var resolvedPath = importPath;
        }
        return {
            contents: fs.readFileSync(resolvedPath, 'utf8'),
        };
    } catch (error) {
        return { error: 'File not found' };
    }
};

const inputObj = {};

for(var i = 0; i < contractNames.length; i++)
{
    const contractName = contractNames[i];
    const contractPath = path.resolve(__dirname, '..', 'contracts', contractName);
    console.log('For contract ' + contractName + ' path is ' + contractPath);
    const source = fs.readFileSync(contractPath, 'utf8');
    inputObj[contractName] = {
        content: source
    };
    //console.log('For contract ' + contractName + ' source is \n ' + source);
}

const inputJSON = {
    language: 'Solidity',
    sources: inputObj,
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            },
        },
    },
};

const compilationOutputString = solc.compile(JSON.stringify(inputJSON), { import: findImports });
const compilationOutput = JSON.parse(compilationOutputString);

if(compilationOutput.errors)
{
    for(const error of compilationOutput.errors)
    {
        console.error(error.formattedMessage);
    }
}

const compiledContracts = compilationOutput.contracts;

const bytecodeDir = path.resolve(__dirname, '..', 'compiled-bytecode');
const abiDir = path.resolve(__dirname, '..', 'compiled-abi');

if (!fs.existsSync(bytecodeDir)) {
  fs.mkdirSync(bytecodeDir);
}

if (!fs.existsSync(abiDir)) {
  fs.mkdirSync(abiDir);
}

for(var contractName of contractNames)
{
    var compiledContractObj = compiledContracts[contractName][contractName.replace('.sol', '')];
    const bytecode = compiledContractObj.evm.bytecode.object;
    const abi = compiledContractObj.abi;
    stringyfiedAbi = JSON.stringify(abi, null, 2);
    console.log('for contract ' + contractName + ' bytecode length is ' + bytecode.length);
    console.log('for contract ' + contractName + ' abi length is ' + stringyfiedAbi.length);

    const baseName = path.basename(contractName, '.sol');
    const bytecodePath = path.join(bytecodeDir, `${baseName}_bytecode.txt`);
    const abiPath = path.join(abiDir, `${baseName}_abi.txt`);

    if(bytecode && bytecode.length > 0)
    {
        fs.writeFileSync(bytecodePath, bytecode);
        console.log('for contract ' + contractName + ' bytecode saved to ' + bytecodePath);
    }
    if(stringyfiedAbi && stringyfiedAbi.length > 0)
    {
        fs.writeFileSync(abiPath, stringyfiedAbi);
        console.log('for contract ' + contractName + ' abi saved to ' + stringyfiedAbi);
    }
}
