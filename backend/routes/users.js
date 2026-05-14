const router = require('express').Router();
const User = require('../models/User');
const auth = require('../middleware/auth');
router.get('/me', auth, async (req, res) => {
  const user = await User.findById(req.user.id).select('-password');
  res.json(user);
});
router.put('/me', auth, async (req, res) => {
  try {
    const { name, rollNo, hostel } = req.body;
    const user = await User.findByIdAndUpdate(req.user.id, { name, rollNo, hostel }, { new: true }).select('-password');
    res.json(user);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
module.exports = router;
