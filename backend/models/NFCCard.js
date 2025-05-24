const mongoose = require('mongoose');

const nfcCardSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true
  },
  idolName: String,
  groupName: String,
  image: String,
  rarity: String,
  signature: String,
  isRegistered: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('NFCCard', nfcCardSchema);