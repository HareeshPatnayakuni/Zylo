const router = require('express').Router();
const Message = require('../models/Message');
const auth = require('../middleware/auth');
router.get('/conversations', auth, async (req, res) => {
  try {
    const msgs = await Message.find({ $or: [{ sender: req.user.id }, { receiver: req.user.id }] })
      .populate('sender receiver', 'name email').sort('-createdAt');
    const seen = new Set(); const convos = [];
    for (const m of msgs) {
      const other = m.sender._id.toString() === req.user.id ? m.receiver : m.sender;
      if (!seen.has(other._id.toString())) {
        seen.add(other._id.toString());
        convos.push({ user: other, lastMessage: m.text });
      }
    }
    res.json(convos);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
router.get('/:userId', auth, async (req, res) => {
  const msgs = await Message.find({ $or: [
    { sender: req.user.id, receiver: req.params.userId },
    { sender: req.params.userId, receiver: req.user.id }
  ] }).populate('sender', 'name').sort('createdAt');
  res.json(msgs);
});
router.post('/', auth, async (req, res) => {
  try {
    const { receiver, text, item } = req.body;
    const msg = await Message.create({ sender: req.user.id, receiver, text, item });
    await msg.populate('sender', 'name');
    res.json(msg);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
module.exports = router;
