// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.4.2/access/AccessControl.sol";
import "@openzeppelin/contracts@4.4.2/utils/Counters.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC1155/IERC1155.sol";



contract GameCharacter is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl, ERC1155Holder {
    using Counters for Counters.Counter;

    IERC1155 gameItemContract;

    mapping(address => uint256) _hats;
    mapping(address => uint256) _shoes;
    mapping(address => uint256) _glasses;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor(address gameItemContractAddress) ERC721("GameCharacter", "CHARACTER") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        gameItemContract = IERC1155(gameItemContractAddress);
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }


    ///////////////// Wearing Function ////////////////////
    function changeHat(tokenId) public {
        require(_isHat(tokenId), "Item should be a hat");
        if (_hats[msg.sender] > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, _hats[msg.sender], 1);
        }
        gameItemContract.safeTransferFrom(msg.sender, address(this), tokenId, 1);
        _hats[msg.sender] = tokenId;
    }
    function getHat(address owner) public view returns(uint256) {
        return _hats[owner];
    }
    function _isHat(tokenId) internal returns(bool) {
        if (tokenId <= 0x0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00010000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }


    function changeShoes(tokenId) public {
        require(_isShoe(tokenId), "Item should be shoes");
        if (_shoes[msg.sender] > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, _shoes[msg.sender], 1);
        }
        gameItemContract.safeTransferFrom(msg.sender, address(this), tokenId, 1);
        _shoes[msg.sender] = tokenId;
    }
    function getShoes(address owner) public view returns(uint256) {
        return _shoes[owner];
    }
    function _isShoe(tokenId) internal returns(bool) {
        if (tokenId <= 0x0002ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00020000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }


    function changeGkasses(tokenId) public {
        require(_isGlasses(tokenId), "Item should be glasses");
        if (_glasses[msg.sender] > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, _glasses[msg.sender], 1);
        }
        gameItemContract.safeTransferFrom(msg.sender, address(this), tokenId, 1);
        _glasses[msg.sender] = tokenId;
    }
    function getGlasses(address owner) public view returns(uint256) {
        return _glasses[owner];
    }
    function _isGlasses(tokenId) internal returns(bool) {
        if (tokenId <= 0x0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00030000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }


    ////////////////////////////////////////////////////////



    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
