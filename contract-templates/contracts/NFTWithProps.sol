// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract NFTWithProps is ERC721, ERC721Enumerable, AccessControl, ERC721Burnable, EIP712 {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    string private constant SIGNING_DOMAIN = "NFT With Props";
    string private constant SIGNATURE_VERSION = "1";
    
    Counters.Counter private tokenIdCounter;
    
    struct Item {
        uint256 itemType; //should be non-zero
        uint256 strength;
        uint256 level;
    }
    
    mapping(uint256 => Item) private tokenDetails;

    constructor() 
    ERC721("NFT With Props", "NFTP")
    EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
    }

    // Mınter can mint any token
    function mintToken(address to, Item calldata item) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        tokenDetails[tokenId] = item;
    }

    function getTokenDetails(uint256 tokenId) public view returns(Item memory) {
        require(tokenDetails[tokenId].itemType > 0, "token does not exists");

        return tokenDetails[tokenId];
    }

    // this struct is for signed message 
    struct ItemInfo {
        uint256 tokenId; // this will be zero for minting
        uint256 itemType;
        uint256 strength;
        uint256 level;
        uint256 expireTime; // this is for extra security.
        bytes signature;
    }

    // mint with a signed message coming from a minter
    function mintTokenWithSignedMessage(address to, ItemInfo calldata itemInfo) public {
        address signer = _verifyItemInfo(itemInfo);
        require(hasRole(MINTER_ROLE, signer), "Signature invalid");
        require(itemInfo.expireTime > block.timestamp, "Voucher expired");

        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        tokenDetails[tokenId] = Item(itemInfo.itemType, itemInfo.strength, itemInfo.level);
    }

    // update token with a signed message coming from a updater
    function updateTokenWithSignedMessage(ItemInfo calldata itemInfo) public {
        address signer = _verifyItemInfo(itemInfo);
        require(hasRole(UPDATER_ROLE, signer), "Signature invalid");
        require(itemInfo.expireTime > block.timestamp, "Voucher expired");
        require(tokenDetails[itemInfo.tokenId].itemType > 0, "Token does not exist");

        tokenDetails[itemInfo.tokenId] = Item(itemInfo.itemType, itemInfo.strength, itemInfo.level);
    }


    ///// verification functions //////////
    function _hashItemInfo(ItemInfo calldata voucher) internal view returns (bytes32) {
        return _hashTypedDataV4(
                    keccak256(
                        abi.encode(
                            keccak256("ItemInfo(uint256 tokenId,uint256 itemType,uint256 strength,uint256 level,uint256 expireTime)"),
                            voucher.tokenId,
                            voucher.itemType,
                            voucher.strength,
                            voucher.level,
                            voucher.expireTime
                        )
                    )
                );
    }
    function _verifyItemInfo(ItemInfo calldata voucher) internal view returns (address) {
        bytes32 digest = _hashItemInfo(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }
    //------------------------------------------//

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}