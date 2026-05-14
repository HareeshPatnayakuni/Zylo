const mongoose = require('mongoose');
const ItemSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  type: { type: String, enum: ['rent', 'sale'], required: true },
  category: { type: String, default: 'Other' },
  image: { type: String, default: '' },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  available: { type: Boolean, default: true }
}, { timestamps: true });
module.exports = mongoose.model('Item', ItemSchema);
