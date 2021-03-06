# Example NFT Contracts For Games

All of these contracts are ERC-721 tokens. 

### Simple NFT
**File = SimpleNFT.sol**

This is a simple NFT contract that is mintable by authorized accounts. And it is burnable. And it holds URI information for every token.

### Simple NFT + Mint with signature
**File = SimpleNFT_SignatureMintable.sol**

This is similar to the Simple NFT contract but it is mintable by anyone if it is autorized with a signature generated by a known backend. This way backend will not pay the transaction fee, but the user does. 

### NFT + On Chain Properties
**File = NFTWithProps.sol**

This NFT has extra properties like type, strength etc. stored in the contract itself. And these propertes can be updated with a signature that is generated by a known account. Mining with a signature is possible too.

EIP-712 is used for signature generating and validation

### NFT + On Chain Properties
**File = RentableNFT.sol**

This is a simple NFT contract that has renting feature. This enables NFT owners to rent their assets to someone else for some period of time.

### Composable NFT v1
**File = composable-v1/GameCharacterV1.sol**

This contract is a parent NFT contract. It means tokens of this contract can have other NFTs from a sepicified ERC1155 contract. This is the version that is in the demos. ERC721 and ERC1155 combined. 


### Composable NFT v2 (new ERC-4911 interface)
**File = composable-v2/GameCharacterV2.sol**

This contract is a parent NFT contract. It means tokens of this contractcan have other NFTs as childs. Childs can be any other ERC721 contract. Multiple different child contracts can be used. 

