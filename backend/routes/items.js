const router = require('express').Router();
const Item = require('../models/Item');
const auth = require('../middleware/auth');
router.get('/', async (req, res) => {
  try {
    const { search, category, type } = req.query;
    let query = { available: true };
    if (search) query.title = { $regex: search, $options: 'i' };
    if (category) query.category = category;
    if (type) query.type = type;
    const items = await Item.find(query).populate('owner', 'name email rollNo hostel').sort('-createdAt');
    res.json(items);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
router.get('/my', auth, async (req, res) => {
  const items = await Item.find({ owner: req.user.id }).sort('-createdAt');
  res.json(items);
});
router.post('/', auth, async (req, res) => {
  try {
    const item = await Item.create({ ...req.body, owner: req.user.id });
    res.json(item);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
router.put('/:id', auth, async (req, res) => {
  try {
    const item = await Item.findOne({ _id: req.params.id, owner: req.user.id });
    if (!item) return res.status(404).json({ msg: 'Not found' });
    Object.assign(item, req.body);
    await item.save();
    res.json(item);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
router.delete('/:id', auth, async (req, res) => {
  try {
    await Item.findOneAndDelete({ _id: req.params.id, owner: req.user.id });
    res.json({ msg: 'Deleted' });
  } catch (err) { res.status(500).json({ msg: err.message }); }
});
module.exports = router;
