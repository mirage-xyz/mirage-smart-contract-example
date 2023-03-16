# Smart contract compilation guide

The `scripts` folder contains `compile.js` script, which is designed to compile and deploy smart contracts to the Goerli Ethereum test network. The `contracts` folder contains the contracts that can be compiled using this script. To compile GameItem.sol and GameCharacter.sol, follow these steps:

1. Install the latest version of Node.js which includes npm package manager
2. Run the command `npm install` in the project root folder to install all of the dependencies specified in package.json file.
3. Run command `node scripts/compile.js GameItem.sol GameCharacter.sol` in the project root folder. This command executes the compilation script and saves the bytecode and ABI of the specified smart contract files to the compiled-abi and compiled-bytecode folders. These files will be used during deployment process later.

Note that GameItem and GameCharacter are base names of the contract files.

# Smart contract deployment guide

To deploy compiled contracts you need 

1. Specify a private key for an external Ethereum address by placing it in the `private_keys/deployment_private_key.txt` file. The `private_keys` folder should be located in the project root folder. This folder is ignored by git, so create it locally if needed.

2. Specify smart contract constructor arguments in the text files within the `deployment_arguments` folder. Each smart contract should have its own text file for constructor arguments. The file name should follow the format {base_name}.txt, where base_name is the base name of the contract file. For example, for GameCharacter.sol the contract constructor arguments should be placed in `deployment_arguments/GameCharacter.txt`. The `deloyment_arguments` folder is located in the project root folder and is also ignored by git, so create the files as needed.

Each constructor argument is represented by a new line within the arguments text file. This table describes how to represent different Solidity types in the text file:

| Solidity type | Text representation |
| --- | --- |
| `address` | a string | 
| `uint256` | a numeric string (e.g., '42') | 
| `byte` | a string representing a single byte in hex format (e.g., '0x1A') | 
| `bytes` | a string representing a byte array in hexadecimal format (e.g., '0x1A2B3C' | 
| `uint256[]` | a string representing of numeric strings "['42', '100']" | 

Warning: The `uint256[]` implementation is NOT FINISHED, might need a runtime conversion from a string to an array of strings.

3. Ensure that your private key corresponds to an address with enough ETH to deploy the contracts.

4. Run the command `node scripts/deploy.js GameItem GameCharacter` to deploy both contracts. In this specific example, you might need to deploy GameItem first and then deploy GameCharacter with a separate command, as GameCharacter requires a constructor argument with the GameItem contract address. This allows one contract to call another.