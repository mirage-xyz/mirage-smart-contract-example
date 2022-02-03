# Composability Extension For ERC-1155 Standart

## Simple Summary

An extension of the ERC-1155 standard to enable ERC1155 tokens to own other ERC1155 tokens. 
This standart tries to make a gas efficient extension to the ERC115 tokens.

## Abstract

This standard outlines a smart contract interface that should be applied to ERC1155 contracts to add composability feature.
ERC1155 allows to implement fungible tokens (FT) and non-fungible tokens (NFT). These different types of tokens can be in the same contracts.
In this standart NFTs can own other NFTs or FTs. But FT tokens can not own others because this will make then non-fungible and that defeats the purpose.

In order for this standart to work, tokenId space for NFTs and FTs should be splitted.


## Specification

´´´
pragma solidity ^0.5.9;

/**
    @title ERC-1155 Composabile
 */
interface ERC1155 /* is ERC165 */ {
    /**
        @dev This
        The `_slotId` argument MUST be an id that defines parent and child id patterns
        The `_max` argument MUST be the maximum count for shild items.
        The `_min` argument MUST be the minimum count for shild items.
    */
    event SlotAdded(uint256 indexed _slotId, uint256 indexed _max, uint256 indexed _min);

    /**
        @dev MUST emit when a child token attached to a parent
    */
    event ChildAttached(uint256 indexed _slotId, address indexed _owner, uint256 indexed _parentId, uint256 indexed _childId, uint256 indexed _amount);

    /**
        @dev MUST emit when a child token removed from a parent
    */
    event ChildRemoved(uint256 indexed _slotId, address indexed _owner, uint256 indexed _parentId, uint256 indexed _childId, uint256 indexed _amount);


    /**
        @notice 
        @dev 
        @param slotId   
        @param max      
        @param min      
    */
    function addComposabilitySlot(uint256 slotId, uint256 max, uint256 min) external;

    /**
        @notice 
        @dev 
        @param slotId   
        @param parentId      
        @param childId
        @param amount
    */
    function attachChildToParent(uint256 slotId, uint256 parentId, uint256 childId, uint256 amount) external;

    /**
        @notice 
        @dev 
        @param slotId   
        @param parentId      
        @param childId
        @param amount     
    */
    function removeChildFromParent(uint256 slotId, uint256 parentId, uint256 childId, uint256 amount) external;

    /**
        @notice 
        @dev 
        @param slotId   
        @param parentId      
        @param oldChildId
        @param newChildId     
    */
    function swapChildForParent(uint256 slotId, uint256 parentId, uint256 oldChildId, uint256 newChildId) external;
}


´´´

### Token Id Space

The top 128 bits of the uint256 _id parameter in any ERC-1155 function MAY represent the base token ID, while the bottom 128 bits MAY represent the index of the non-fungible to make it unique.

Non-fungible tokens can be interacted with using an index based accessor into the contract/token data set. Therefore to access a particular token set within a mixed data contract and a particular non-fungible within that set, _id could be passed as <uint128: base token id><uint128: index of non-fungible>.


´´´
uint256 baseTokenNFT = 12345 << 128;
uint128 indexNFT = 50;

uint256 baseTokenFT = 54321 << 128;

balanceOf(baseTokenNFT, msg.sender); // Get balance of the base token for non-fungible set 12345 (this MAY be used to get balance of the user for all of this token set if the implementation wishes as a convenience).
balanceOf(baseTokenNFT + indexNFT, msg.sender); // Get balance of the token at index 50 for non-fungible set 12345 (should be 1 if user owns the individual non-fungible token or 0 if they do not).
balanceOf(baseTokenFT, msg.sender); // Get balance of the fungible base token 54321.
´´´