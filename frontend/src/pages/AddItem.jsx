import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import axios from 'axios';

const CATEGORIES = ['Books', 'Electronics', 'Furniture', 'Clothing', 'Sports', 'Stationery', 'Other'];

export default function AddItem() {
  const [form, setForm] = useState({ title: '', description: '', price: '', type: 'sale', category: 'Other', image: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [params] = useSearchParams();
  const editId = params.get('edit');
  const nav = useNavigate();

  useEffect(() => {
    if (editId) {
      axios.get('/api/items/my').then(r => {
        const item = r.data.find(i => i._id === editId);
        if (item) setForm({ title: item.title, description: item.description, price: item.price, type: item.type, category: item.category, image: item.image || '' });
      });
    }
  }, [editId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (editId) await axios.put(`/api/items/${editId}`, form);
      else await axios.post('/api/items', form);
      nav('/');
    } catch (err) {
      setError(err.response?.data?.msg || 'Failed to save');
    }
    setLoading(false);
  };

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="text-2xl font-bold mb-6">{editId ? 'Edit Listing' : 'New Listing'}</h1>
      {error && <p className="text-red-400 text-sm mb-4 bg-red-900/20 px-3 py-2 rounded">{error}</p>}

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="text-sm text-gray-400 block mb-1">Title</label>
          <input className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500"
            placeholder="e.g. Calculus Textbook" value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} required />
        </div>

        <div>
          <label className="text-sm text-gray-400 block mb-1">Description</label>
          <textarea className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500 h-24 resize-none"
            placeholder="Describe your item..." value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} required />
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="text-sm text-gray-400 block mb-1">Price (₹)</label>
            <input type="number" className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500"
              placeholder="0" value={form.price} onChange={e => setForm({ ...form, price: e.target.value })} required />
          </div>
          <div>
            <label className="text-sm text-gray-400 block mb-1">Type</label>
            <select className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500"
              value={form.type} onChange={e => setForm({ ...form, type: e.target.value })}>
              <option value="sale">For Sale</option>
              <option value="rent">For Rent</option>
            </select>
          </div>
        </div>

        <div>
          <label className="text-sm text-gray-400 block mb-1">Category</label>
          <select className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500"
            value={form.category} onChange={e => setForm({ ...form, category: e.target.value })}>
            {CATEGORIES.map(c => <option key={c}>{c}</option>)}
          </select>
        </div>

        <div>
          <label className="text-sm text-gray-400 block mb-1">Image URL (optional)</label>
          <input className="w-full bg-[#1a1a24] border border-[#2a2a38] rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500"
            placeholder="https://..." value={form.image} onChange={e => setForm({ ...form, image: e.target.value })} />
        </div>

        <button type="submit" disabled={loading} className="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white rounded-lg py-2.5 font-semibold transition">
          {loading ? 'Saving...' : editId ? 'Update Listing' : 'Post Listing'}
        </button>
      </form>
    </div>
  );
}
