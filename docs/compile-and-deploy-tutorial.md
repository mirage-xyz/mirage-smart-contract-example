# Smart contract compilation guide

`scripts` folder contains `compile.js` scripts intended to compile and deploy smart contracts to the Goerli Ethereum test network. The `contracts` folder contains the contracts you can compile with this script. In order to compile GameItem.sol and GameCharacter.sol you should first:

1. Install latest version of Node.js that comes together with npm package manager.

2. Run command `npm install` in the project root folder to install all of the dependencies specified in package.json

3. Run command `node scripts/compile.js GameItem.sol GameCharacter.sol` in the root folder of the project. This command runs the compilation script and saves a bytecode and an ABI of the specified smart contract files to compiled-abi and compiled-bytecode folders. These files will be used during deployment process later.

Let GameItem and GameCharacter are base names of the contract files.

# Smart contract deployment guide

In order to deploy compiled contracts you need 

1. Specify a private key for an external Ethereum address, you do this by putting it into `private_keys/deployment_private_key.txt` file where folder private_keys located in the root folder of the project. This folder is in git ignore, so make sure to create it locally.

2. Specify smart contract constructor arguments in the text files in the `deployment_arguments` folder. Each smart contract takes constructor arguments from its own text file. Name of the file should be {base_name}.txt where base_name is the base name of a contract file. I.e. for GameCharacter.sol the contract constructor arguments should be placed in `deployment_arguments/GameCharacter.txt`. Folder `deloyment_arguments` is located in the root folder of the project and ignored by git, so make sure to create the files yourself.

Each constructor argument is represented by a new line within the arguments text file. This table describes how to represent different Solidity types in this text file:

| Solidity type | Text representation |
| --- | --- |
| `address` | just a string | 
| `uint256` | a numeric string (e.g., '42') | 
| `byte` | string representing a single byte in hex format (e.g., '0x1A') | 
| `bytes` | string representing a byte array in hexadecimal format (e.g., '0x1A2B3C' | 
| `uint256[]` | string representing of numeric strings "['42', '100']" | 

Warning: `uint256[]` implementation is NOT FINISHED, might need a runtime conversion from a string to array of strings.

3. Make sure your private key corresponds to an address that has enough ETH to deploy the contracts.

4. Run command `node scripts/deploy.js GameItem GameCharacter` to deploy both of the contracts. In this particular example you might need to first deploy GameItem and only then deploy GameCharacter with a separate command since GameCharacter needs a constructor argument with a GameItem contract address so that one contract could be called from another one.