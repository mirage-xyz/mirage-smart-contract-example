# Composability Extension For ERC-1155 Standart

## Simple Summary

An extension of the ERC-1155 standard to enable ERC1155 tokens to own other ERC1155 tokens. 
This standart tries to make a gas efficient extension to the ERC1155 tokens.

## Abstract

This standard outlines a smart contract interface that should be applied to ERC1155 contracts to add composability feature.
ERC1155 allows to implement fungible tokens (FT) and non-fungible tokens (NFT). These different types of tokens can be in the same contract.
In this standart NFTs can own other NFTs or FTs. But FT tokens can not own others because this will make them non-fungible and that defeats the purpose.

In order for this standart to work, tokenId space for NFTs and FTs should be splitted.

## Motivation

NFT composability has been an important topic for especially games. But mostly it is not implemented on-chain. 
For example attaching wearable NFTs to avatar NFTs. These can be implemented in-game but in that case it won't be decentralised.
Making it on-chain as a generalized feature requires some standardization. 

## Specification

This specification defines parent chlid relationship between tokens in the same ERC1155 contract. 
Tokens from different contracts con not be used. This makes it gas efficient.

Every token can have multiple chlidren but only one parent. 
A parent token must be NFT but chlid tokens can be NFT or FT.

**Parent Token = NFT**

**Chlid Token = NFT or FT**

### Slots

Parent chlid relationships are defined as slots in the contract. 
Slots have an id that defines the parent category and child category.

And maximum number of childs in the slot. 

An extra name property can be given for convenience.

### Token Id Categorization

ERC1155 standart already metions a split id method for spliting NFTs and FT. 
This standart enforces this split id method for identifying NFTs. 
And an extra token categorization method added for combining multiple token ids in one group. 

For this first 64 bit of the token id will be used for defining the category.
For NFTs the first bit must be 1. For FTs that must be 0.

A slot id defines parent category and child category.
**Slot id** = <64 bit parent category> <64 bit 0> <64 bit child category> <64 bit 0>


### Interface

```solidity
pragma solidity ^0.8.0;

/**
    @title ERC-1155 Composabile
 */
interface ERC1155 /* is ERC165 */ {
    /**
        @dev This
        The _slotId argument MUST be an id that defines parent and child id patterns
        The _max argument MUST be the maximum count for shild items.
    */
    event SlotAdded(uint256 indexed _slotId, uint256 indexed _max);

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
    */
    function addComposabilitySlot(uint256 slotId, uint256 max) external;

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
        @notice only if childs are NFTs.
        @dev 
        @param slotId   
        @param parentId      
        @param oldChildId
        @param newChildId     
    */
    function swapChildForParent(uint256 slotId, uint256 parentId, uint256 oldChildId, uint256 newChildId) external;

    /**
        @notice 
        @dev 
        @param slotId   
        @param parentId      
        @param oldChildId
        @param newChildId     
    */
    function getChilds(uint256 slotId, uint256 parentId) external returns(uint256[]);
}


```
