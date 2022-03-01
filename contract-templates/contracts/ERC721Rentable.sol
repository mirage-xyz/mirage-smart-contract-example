// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721Rentable is ERC721 {
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

    function rentOut(
        address renter,
        uint256 tokenId,
        uint256 expiresAt
    ) external {
        //  check for renting tokenId
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
    ) internal virtual override {
        require(!rental[tokenId].isActive, "ERC721Rentable: this token is rented");

        super._beforeTokenTransfer(from, to, tokenId);
    }

    /*function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Rentable).interfaceId || super.supportsInterface(interfaceId);
    }*/
}