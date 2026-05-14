import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
const S = { wrap:{minHeight:'100vh',display:'flex',alignItems:'center',justifyContent:'center',padding:'1rem'}, box:{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'16px',padding:'2rem',width:'100%',maxWidth:'400px'}, inp:{width:'100%',background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'10px 14px',color:'#f0f0f0',fontSize:'14px',boxSizing:'border-box',marginBottom:'10px'}, btn:{width:'100%',background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'12px',fontWeight:'600',cursor:'pointer',fontSize:'14px'} };
export default function Login() {
  const [isReg, setIsReg] = useState(false);
  const [form, setForm] = useState({name:'',email:'',password:'',rollNo:'',hostel:''});
  const [error, setError] = useState('');
  const { login } = useAuth(); const nav = useNavigate();
  const set = k => e => setForm({...form,[k]:e.target.value});
  const submit = async e => {
    e.preventDefault(); setError('');
    try {
      const { data } = await axios.post(isReg?'/api/auth/register':'/api/auth/login', form);
      login(data.token, data.user); nav('/');
    } catch(err) { setError(err.response?.data?.msg||'Error'); }
  };
  return (
    <div style={S.wrap}><div style={S.box}>
      <h1 style={{color:'#818cf8',marginBottom:'4px'}}>ZYLO ⚡</h1>
      <p style={{color:'#9ca3af',fontSize:'13px',marginBottom:'1.5rem'}}>IITM Campus Marketplace</p>
      {error && <p style={{color:'#f87171',fontSize:'13px',marginBottom:'12px'}}>{error}</p>}
      <form onSubmit={submit}>
        {isReg && <><input style={S.inp} placeholder="Full Name" value={form.name} onChange={set('name')} required />
          <input style={S.inp} placeholder="Roll No" value={form.rollNo} onChange={set('rollNo')} />
          <input style={S.inp} placeholder="Hostel" value={form.hostel} onChange={set('hostel')} /></>}
        <input style={S.inp} type="email" placeholder="Email" value={form.email} onChange={set('email')} required />
        <input style={S.inp} type="password" placeholder="Password" value={form.password} onChange={set('password')} required />
        <button type="submit" style={S.btn}>{isReg?'Register':'Login'}</button>
      </form>
      <p style={{textAlign:'center',fontSize:'13px',color:'#9ca3af',marginTop:'1rem'}}>
        {isReg?'Have an account?':"No account?"} <button onClick={()=>setIsReg(!isReg)} style={{color:'#818cf8',background:'none',border:'none',cursor:'pointer'}}>{isReg?'Login':'Register'}</button>
      </p>
    </div></div>
  );
}
