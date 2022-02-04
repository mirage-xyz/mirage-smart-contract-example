// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "hardhat/console.sol";



contract GameCharacter is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl, ERC1155Holder {
    using Counters for Counters.Counter;

    IERC1155 gameItemContract;

    mapping(uint256 => uint256) _hats;
    mapping(uint256 => uint256) _shoes;
    mapping(uint256 => uint256) _glasses;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;


    struct Rental {
        bool isActive;
        address lord;
        address renter;
        uint256 expiresAt;
    }

    mapping(uint256 => Rental) public rental;

    event Rented(
        uint256 indexed tokenId,
        address indexed lord,
        address indexed renter,
        uint256 expiresAt
    );

    event FinishedRent(
        uint256 indexed tokenId,
        address indexed lord,
        address indexed renter,
        uint256 expiresAt
    );


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
    event HatChanged(uint256 characterId, uint256 oldHatId, uint256 newHatId);
    function changeHat(uint256 characterId, uint256 newHatId) public {
        require(_isHat(newHatId), "Item should be a hat");
        require(ownerOf(characterId) == msg.sender, "Should be owner of character");

        uint256 oldHatId = _hats[characterId];
        if (oldHatId > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, oldHatId, 1, "");
        }
        if (newHatId > 0) {
            gameItemContract.safeTransferFrom(msg.sender, address(this), newHatId, 1, "");
        }
        _hats[characterId] = newHatId;

        emit HatChanged(characterId, oldHatId, newHatId);
    }
    function getHat(uint256 characterId) public view returns(uint256) {
        return _hats[characterId];
    }
    function _isHat(uint256 tokenId) internal pure returns(bool) {
        if (tokenId <= 0x0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00010000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }

    event ShoesChanged(uint256 characterId, uint256 oldShoesId, uint256 newShoesId);
    function changeShoes(uint256 characterId, uint256 newShoesId) public {
        require(_isShoe(newShoesId), "Item should be shoes");
        require(ownerOf(characterId) == msg.sender, "Should be owner of character");

        uint256 oldShoesId = _shoes[characterId];
        if (oldShoesId > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, oldShoesId, 1, "");
        }
        if (newShoesId > 0) {
            gameItemContract.safeTransferFrom(msg.sender, address(this), newShoesId, 1, "");
        }
        _shoes[characterId] = newShoesId;

        emit ShoesChanged(characterId, oldShoesId, newShoesId);
    }
    function getShoes(uint256 characterId) public view returns(uint256) {
        return _shoes[characterId];
    }
    function _isShoe(uint256 tokenId) internal pure returns(bool) {
        if (tokenId <= 0x0002ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00020000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }

    
    event GlassesChanged(uint256 characterId, uint256 oldGlassesId, uint256 newGlassesId);
    function changeGlasses(uint256 characterId, uint256 newGlassesId) public {
        require(_isGlasses(newGlassesId), "Item should be glasses");
        require(ownerOf(characterId) == msg.sender, "Should be owner of character");

        uint256 oldGlassesId = _glasses[characterId];
        if (oldGlassesId > 0) {
            gameItemContract.safeTransferFrom(address(this), msg.sender, oldGlassesId, 1, "");
        }
        if (newGlassesId > 0) {
            gameItemContract.safeTransferFrom(msg.sender, address(this), newGlassesId, 1, "");
        }
        _glasses[characterId] = newGlassesId;

        emit GlassesChanged(characterId, oldGlassesId, newGlassesId);
    }
    function getGlasses(uint256 characterId) public view returns(uint256) {
        return _glasses[characterId];
    }
    function _isGlasses(uint256 tokenId) internal pure returns(bool) {
        if (tokenId <= 0x0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
           && tokenId >= 0x00030000000000000000000000000000000000000000000000000000000000
        ) {
               return true;
        }
        return false;
    }


    ////////////////////////////////////////////////////////




    function rentOut(
        address renter,
        uint256 tokenId,
        uint256 expiresAt
    ) external {
        _transfer(msg.sender, renter, tokenId);

        rental[tokenId] = Rental({
            isActive: true,
            lord: msg.sender,
            renter: renter,
            expiresAt: expiresAt
        });

        emit Rented(tokenId, msg.sender, renter, expiresAt);
    }

    function finishRenting(uint256 tokenId) external {
        Rental storage _rental = rental[tokenId];

        require(
            msg.sender == _rental.renter ||
                block.timestamp >= _rental.expiresAt,
            "RentableNFT: this token is rented"
        );

        _rental.isActive = false;

        _transfer(_rental.renter, _rental.lord, tokenId);

        emit FinishedRent(
            tokenId,
            _rental.lord,
            _rental.renter,
            _rental.expiresAt
        );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        require(!rental[tokenId].isActive, "RentableNFT: this token is rented");

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl, ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
