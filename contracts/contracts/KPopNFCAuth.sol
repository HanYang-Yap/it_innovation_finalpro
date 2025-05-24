// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;  // ← Make sure this matches your hardhat.config.js

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KPopNFCAuth is ReentrancyGuard, Ownable {
    
    struct NFCCard {
        string uid;
        address owner;
        uint256 bindTimestamp;
        bool isBound;
        string metadata; // JSON string with card info
    }
    
    // Mappings
    mapping(string => NFCCard) public cards;
    mapping(string => bool) public uidExists;
    mapping(address => string[]) public userCards;
    
    // Events
    event CardBound(string indexed uid, address indexed owner, uint256 timestamp);
    event CardTransferred(string indexed uid, address indexed from, address indexed to);
    
    // Register a new card (only owner can do this)
    function registerCard(string memory uid, string memory metadata) external onlyOwner {
        require(!uidExists[uid], "UID already exists");
        require(bytes(uid).length > 0, "Invalid UID");
        
        cards[uid] = NFCCard({
            uid: uid,
            owner: address(0),
            bindTimestamp: 0,
            isBound: false,
            metadata: metadata
        });
        
        uidExists[uid] = true;
    }
    
    // Bind card to user (one-time only)
    function bindCard(string memory uid) external nonReentrant {
        require(uidExists[uid], "Card does not exist");
        require(!cards[uid].isBound, "Card already bound");
        require(cards[uid].owner == address(0), "Card already has owner");
        
        // Bind the card
        cards[uid].owner = msg.sender;
        cards[uid].bindTimestamp = block.timestamp;
        cards[uid].isBound = true;
        
        // Add to user's card list
        userCards[msg.sender].push(uid);
        
        emit CardBound(uid, msg.sender, block.timestamp);
    }
    
    // Transfer card to another user
    function transferCard(string memory uid, address to) external {
        require(uidExists[uid], "Card does not exist");
        require(cards[uid].owner == msg.sender, "Not card owner");
        require(cards[uid].isBound, "Card not bound");
        require(to != address(0), "Invalid recipient");
        require(to != msg.sender, "Cannot transfer to self");
        
        address from = msg.sender;
        
        // Update card owner
        cards[uid].owner = to;
        
        // Remove from sender's list
        _removeCardFromUser(from, uid);
        
        // Add to recipient's list
        userCards[to].push(uid);
        
        emit CardTransferred(uid, from, to);
    }
    
    // View functions
    function getCard(string memory uid) external view returns (NFCCard memory) {
        require(uidExists[uid], "Card does not exist");
        return cards[uid];
    }
    
    function getUserCards(address user) external view returns (string[] memory) {
        return userCards[user];
    }
    
    function isCardBound(string memory uid) external view returns (bool) {
        return uidExists[uid] && cards[uid].isBound;
    }
    
    // Helper function to remove card from user's array
    function _removeCardFromUser(address user, string memory uid) internal {
        string[] storage userCardArray = userCards[user];
        for (uint256 i = 0; i < userCardArray.length; i++) {
            if (keccak256(bytes(userCardArray[i])) == keccak256(bytes(uid))) {
                userCardArray[i] = userCardArray[userCardArray.length - 1];
                userCardArray.pop();
                break;
            }
        }
    }
}