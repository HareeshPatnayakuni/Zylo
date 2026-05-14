import { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
const inp = {width:'100%',background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'10px 14px',color:'#f0f0f0',fontSize:'14px',boxSizing:'border-box',marginBottom:'12px'};
export default function Profile() {
  const {user,login,token} = useAuth();
  const [form,setForm] = useState({name:'',rollNo:'',hostel:''});
  const [msg,setMsg] = useState({text:'',ok:true});
  useEffect(()=>{axios.get('/api/users/me').then(r=>setForm({name:r.data.name||'',rollNo:r.data.rollNo||'',hostel:r.data.hostel||''}));},[]);
  const set = k => e => setForm({...form,[k]:e.target.value});
  const submit = async e => {
    e.preventDefault();
    try{const {data}=await axios.put('/api/users/me',form);login(token,{id:data._id,name:data.name,email:data.email});setMsg({text:'Saved!',ok:true});}
    catch(err){setMsg({text:err.response?.data?.msg||'Error',ok:false});}
    setTimeout(()=>setMsg({text:''}),2000);
  };
  return (
    <div style={{maxWidth:'440px',margin:'0 auto',padding:'1rem'}}>
      <h2>Profile</h2>
      <div style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',padding:'1.5rem'}}>
        <div style={{display:'flex',alignItems:'center',gap:'12px',marginBottom:'1.5rem'}}>
          <div style={{width:'48px',height:'48px',borderRadius:'50%',background:'#4f46e5',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:'bold',fontSize:'18px'}}>{user?.name?.[0]?.toUpperCase()}</div>
          <div><div style={{fontWeight:'500'}}>{user?.name}</div><div style={{color:'#9ca3af',fontSize:'13px'}}>{user?.email}</div></div>
        </div>
        {msg.text&&<p style={{fontSize:'13px',color:msg.ok?'#34d399':'#f87171',marginBottom:'12px'}}>{msg.text}</p>}
        <form onSubmit={submit}>
          <label style={{color:'#9ca3af',fontSize:'13px'}}>Name</label><input style={inp} value={form.name} onChange={set('name')} />
          <label style={{color:'#9ca3af',fontSize:'13px'}}>Roll Number</label><input style={inp} placeholder="21f1000123" value={form.rollNo} onChange={set('rollNo')} />
          <label style={{color:'#9ca3af',fontSize:'13px'}}>Hostel</label><input style={inp} placeholder="Sabarmati" value={form.hostel} onChange={set('hostel')} />
          <button type="submit" style={{width:'100%',background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'12px',fontWeight:'600',cursor:'pointer'}}>Save Changes</button>
        </form>
      </div>
    </div>
  );
}
