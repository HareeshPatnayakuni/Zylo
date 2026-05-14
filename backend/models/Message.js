const mongoose = require('mongoose');
const MessageSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  item: { type: mongoose.Schema.Types.ObjectId, ref: 'Item' },
  text: { type: String, required: true }
}, { timestamps: true });
module.exports = mongoose.model('Message', MessageSchema);
