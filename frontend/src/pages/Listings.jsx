import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
const CATS = ['All','Books','Electronics','Furniture','Clothing','Sports','Stationery','Other'];
export default function Listings() {
  const [items,setItems] = useState([]);const [search,setSearch] = useState('');
  const [cat,setCat] = useState('All');const [type,setType] = useState('');const [loading,setLoading] = useState(true);
  const {user} = useAuth();const nav = useNavigate();
  const fetch = async () => {
    setLoading(true);
    const p={};if(search)p.search=search;if(cat!=='All')p.category=cat;if(type)p.type=type;
    const {data} = await axios.get('/api/items',{params:p});setItems(data);setLoading(false);
  };
  useEffect(()=>{fetch();},[cat,type]);
  return (
    <div style={{maxWidth:'900px',margin:'0 auto',padding:'1rem'}}>
      <h2>Browse Listings</h2>
      <div style={{display:'flex',gap:'8px',marginBottom:'12px',flexWrap:'wrap'}}>
        <input style={{flex:1,minWidth:'200px',background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px 12px',color:'#f0f0f0',fontSize:'14px'}} placeholder="Search..." value={search} onChange={e=>setSearch(e.target.value)} onKeyDown={e=>e.key==='Enter'&&fetch()} />
        <button onClick={fetch} style={{background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'8px 16px',cursor:'pointer'}}>Search</button>
        <select style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px',color:'#f0f0f0'}} value={type} onChange={e=>setType(e.target.value)}><option value="">All Types</option><option value="sale">Sale</option><option value="rent">Rent</option></select>
      </div>
      <div style={{display:'flex',gap:'8px',flexWrap:'wrap',marginBottom:'1rem'}}>
        {CATS.map(c=><button key={c} onClick={()=>setCat(c)} style={{padding:'4px 12px',borderRadius:'20px',border:'1px solid #2a2a38',background:cat===c?'#4f46e5':'#1a1a24',color:cat===c?'white':'#9ca3af',cursor:'pointer',fontSize:'12px'}}>{c}</button>)}
      </div>
      {loading?<p style={{color:'#9ca3af',textAlign:'center'}}>Loading...</p>:items.length===0?<p style={{color:'#9ca3af',textAlign:'center'}}>No items found</p>:
      <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fill,minmax(260px,1fr))',gap:'12px'}}>
        {items.map(item=>(
          <div key={item._id} style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',overflow:'hidden'}}>
            {item.image?<img src={item.image} alt={item.title} style={{width:'100%',height:'150px',objectFit:'cover'}} onError={e=>e.target.style.display='none'} />:<div style={{height:'150px',background:'#2a2a38',display:'flex',alignItems:'center',justifyContent:'center',fontSize:'2rem'}}>📦</div>}
            <div style={{padding:'12px'}}>
              <div style={{display:'flex',justifyContent:'space-between',marginBottom:'4px'}}>
                <span style={{fontWeight:'500',fontSize:'14px'}}>{item.title}</span>
                <span style={{fontSize:'11px',padding:'2px 8px',borderRadius:'10px',background:item.type==='rent'?'rgba(52,211,153,0.2)':'rgba(251,191,36,0.2)',color:item.type==='rent'?'#34d399':'#fbbf24'}}>{item.type}</span>
              </div>
              <p style={{color:'#9ca3af',fontSize:'12px',margin:'0 0 8px'}}>{item.description.slice(0,60)}...</p>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
                <div><div style={{color:'#818cf8',fontWeight:'bold'}}>₹{item.price}{item.type==='rent'?'/day':''}</div><div style={{color:'#9ca3af',fontSize:'11px'}}>{item.owner?.name} · {item.owner?.hostel||'IITM'}</div></div>
                {item.owner?._id!==user?.id&&<button onClick={()=>nav(`/chat?with=${item.owner?._id}`)} style={{fontSize:'12px',background:'rgba(79,70,229,0.2)',color:'#818cf8',border:'1px solid rgba(79,70,229,0.3)',padding:'6px 10px',borderRadius:'6px',cursor:'pointer'}}>Chat</button>}
              </div>
            </div>
          </div>
        ))}
      </div>}
    </div>
  );
}
