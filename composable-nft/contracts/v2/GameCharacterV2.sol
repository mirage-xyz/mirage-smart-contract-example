// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "hardhat/console.sol";



contract GameCharacterV2 is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl, ERC721Holder {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SLOT_ADDER_ROLE = keccak256("SLOT_ADDER_ROLE");
    Counters.Counter private _tokenIdCounter;


    constructor() ERC721("GameCharacter", "CHARACTER") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(SLOT_ADDER_ROLE, msg.sender);
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }


    ///////////////// Public Functions ////////////////////
    struct ChildSlotInfo {
        address childContract;
        uint256 max;
    }
    // slotId => slotInfo
    mapping (uint256 => ChildSlotInfo) childSlots;
    event ChildSlotAdded(
        uint256 slotId,
        address childContract,
        uint256 max,
        string name
    );

    // slotId => (parentId => childIds)
    mapping (uint256 => mapping(uint256 => uint256[])) childTokens;
    function addChildSlot(string memory name,  address childContract, uint256 max) public onlyRole(SLOT_ADDER_ROLE) returns(uint256) {
        //check child contract is a ERC721 
        require(max > 0, "ERC721Owner: max > 0");
        uint256 slotId = uint256(keccak256(bytes.concat(abi.encode(address(this)), abi.encode(childContract), abi.encode(max))));
        childSlots[slotId] = ChildSlotInfo(childContract, max);
        emit ChildSlotAdded(slotId, childContract, max, name);
        return slotId;
    }

    function attachChildToParent(uint256 slotId, uint256 parentId, uint256 childId) public {
        _attachChildToParent(slotId, parentId, childId);
        IERC721(childSlots[slotId].childContract).safeTransferFrom(msg.sender, address(this), childId);
    }

    function removeChildFromParent(uint256 slotId, uint256 parentId, uint256 childId) public {
        _removeChildFromParent(slotId, parentId, childId);
        IERC721(childSlots[slotId].childContract).safeTransferFrom(address(this), msg.sender, childId);
    }
    
    function swapChildForParent(uint256 slotId, uint256 parentId, uint256 oldChildId, uint256 newChildId) public {
        ChildSlotInfo storage info = childSlots[slotId];
        _removeChildFromParent(slotId, parentId, oldChildId);
        IERC721(info.childContract).safeTransferFrom(address(this), msg.sender, oldChildId);
        _attachChildToParent(slotId, parentId, newChildId);
        IERC721(info.childContract).safeTransferFrom(msg.sender, address(this), newChildId);
    }

    function transferChild(uint256 slotId, uint256 parentId, uint256 childId, uint256 newSlotId, uint256 newParentId) public {
        _removeChildFromParent(slotId, parentId, childId);
        _attachChildToParent(newSlotId, newParentId, childId);
    }

    function getChilds(uint256 slotId, uint256 parentId) public view returns(uint256[] memory) {
        ChildSlotInfo storage info = childSlots[slotId];
        require(info.max > 0, "ERC721Parent: slot not found");
        return childTokens[slotId][parentId];
    }
    ////////////////////////////////////////////////////////


    ///////////////// Private Functions ////////////////////
    function _attachChildToParent(uint256 slotId, uint256 parentId, uint256 childId) internal {
        ChildSlotInfo storage info = childSlots[slotId];
        require(info.max > 0, "ERC721Parent: slot not found");

        require(ownerOf(parentId) == msg.sender, "ERC721Parent: Owner of parent is not sender");

        uint256[] storage tokens = childTokens[slotId][parentId];
        require(tokens.length == info.max, "ERC721Parent: slot is full for this parent");

        tokens.push(childId);
    }
    function _removeChildFromParent(uint256 slotId, uint256 parentId, uint256 childId) internal {
        ChildSlotInfo storage info = childSlots[slotId];
        require(info.max > 0, "ERC721Parent: slot not found");

        require(ownerOf(parentId) == msg.sender, "ERC721Parent: Owner of parent is not sender");

        uint256[] storage tokens = childTokens[slotId][parentId];
        bool found = false;
        for (uint i=0; i<tokens.length; i++) {
            if (tokens[i] == childId) {
                found = true;
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                /*delete tokens[tokens.length - 1];
                tokens.length--;*/
                break;
            }
        }

        require(found, "ERC721Parent: child could not be found in the slot.");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
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
