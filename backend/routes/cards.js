const express = require('express');
const router = express.Router();
const NFCCard = require('../models/NFCCard');
const { ethers } = require('ethers');

// Verify UID exists and return card info
router.get('/verify/:uid', async (req, res) => {
  try {
    const { uid } = req.params;
    
    const card = await NFCCard.findOne({ uid });
    
    if (!card) {
      return res.status(404).json({ 
        success: false, 
        message: 'Card not found' 
      });
    }
    
    res.json({
      success: true,
      card: {
        uid: card.uid,
        idolName: card.idolName,
        groupName: card.groupName,
        image: card.image,
        rarity: card.rarity,
        isRegistered: card.isRegistered
      }
    });
    
  } catch (error) {
    console.error('Verify error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// Register new card (admin only)
router.post('/register', async (req, res) => {
  try {
    const { uid, idolName, groupName, image, rarity } = req.body;
    
    // Check if card already exists
    const existingCard = await NFCCard.findOne({ uid });
    if (existingCard) {
      return res.status(400).json({
        success: false,
        message: 'Card already registered'
      });
    }
    
    // Create new card
    const newCard = new NFCCard({
      uid,
      idolName,
      groupName,
      image,
      rarity
    });
    
    await newCard.save();
    
    res.json({
      success: true,
      message: 'Card registered successfully',
      card: newCard
    });
    
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get all registered cards
router.get('/', async (req, res) => {
  try {
    const cards = await NFCCard.find({ isRegistered: true });
    res.json({ success: true, cards });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;