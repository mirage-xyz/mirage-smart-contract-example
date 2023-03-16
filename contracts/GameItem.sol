// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract GameItem is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    event URISet(string indexed uri);
    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        require(bytes(newuri).length > 0, "GameItem: URI cannot be an empty string");
        
        _setURI(newuri);
        
        emit URISet(newuri);
    }

    event SingleMinted(address indexed account, uint256 indexed id, uint256 amount, bytes data);
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        //onlyRole(MINTER_ROLE)
    {
        require(id != 0, "Invalid token ID: 0");
        require(amount != 0, "Invalid token amount: 0");
        
        _mint(account, id, amount, data);
        
        emit SingleMinted(account, id, amount, data);
    }

    event BatchMinted(address indexed to, uint256[] ids, uint256[] amounts, bytes data);
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        //onlyRole(MINTER_ROLE)
    {
        require(ids.length == amounts.length, "Mismatch between ids and amounts lengths");

        for (uint256 i = 0; i < ids.length; i++) {
            require(ids[i] != 0, "Invalid token ID: 0");
            require(amounts[i] != 0, "Invalid token amount: 0");
        }
        
        _mintBatch(to, ids, amounts, data);

        emit BatchMinted(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}