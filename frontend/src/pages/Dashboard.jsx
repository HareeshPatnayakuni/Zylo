import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

export default function Dashboard() {
  const { user } = useAuth();
  const [myItems, setMyItems] = useState([]);
  const [stats, setStats] = useState({ total: 0, rent: 0, sale: 0 });

  useEffect(() => {
    axios.get('/api/items/my').then(r => {
      setMyItems(r.data);
      setStats({
        total: r.data.length,
        rent: r.data.filter(i => i.type === 'rent').length,
        sale: r.data.filter(i => i.type === 'sale').length
      });
    });
  }, []);

  const deleteItem = async (id) => {
    if (!window.confirm('Delete this item?')) return;
    await axios.delete(`/api/items/${id}`);
    setMyItems(myItems.filter(i => i._id !== id));
  };

  return (
    <div className="max-w-4xl mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Hey, {user?.name?.split(' ')[0]} 👋</h1>
          <p className="text-gray-400 text-sm">Manage your listings</p>
        </div>
        <Link to="/add-item" className="bg-indigo-600 hover:bg-indigo-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
          + Add Listing
        </Link>
      </div>

      <div className="grid grid-cols-3 gap-4 mb-8">
        {[['Total', stats.total, 'indigo'], ['For Rent', stats.rent, 'emerald'], ['For Sale', stats.sale, 'amber']].map(([label, val, color]) => (
          <div key={label} className="bg-[#1a1a24] border border-[#2a2a38] rounded-xl p-4 text-center">
            <div className={`text-3xl font-bold text-${color}-400`}>{val}</div>
            <div className="text-gray-400 text-sm mt-1">{label}</div>
          </div>
        ))}
      </div>

      <h2 className="text-lg font-semibold mb-3">Your Listings</h2>
      {myItems.length === 0 ? (
        <div className="text-center py-12 text-gray-500">
          <p className="text-4xl mb-2">📦</p>
          <p>No listings yet. <Link to="/add-item" className="text-indigo-400 hover:underline">Add one!</Link></p>
        </div>
      ) : (
        <div className="space-y-3">
          {myItems.map(item => (
            <div key={item._id} className="bg-[#1a1a24] border border-[#2a2a38] rounded-xl p-4 flex items-center justify-between">
              <div>
                <div className="font-semibold">{item.title}</div>
                <div className="text-sm text-gray-400">₹{item.price} · {item.type} · {item.category}</div>
              </div>
              <div className="flex gap-2">
                <Link to={`/add-item?edit=${item._id}`} className="text-xs bg-[#2a2a38] px-3 py-1.5 rounded-lg hover:bg-[#3a3a48]">Edit</Link>
                <button onClick={() => deleteItem(item._id)} className="text-xs bg-red-900/30 text-red-400 px-3 py-1.5 rounded-lg hover:bg-red-900/50">Delete</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
