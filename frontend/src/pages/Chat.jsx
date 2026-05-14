import { useEffect, useState, useRef } from 'react';
import { useSearchParams } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
export default function Chat() {
  const [convos,setConvos] = useState([]);const [msgs,setMsgs] = useState([]);
  const [active,setActive] = useState(null);const [text,setText] = useState('');
  const [params] = useSearchParams();const {user} = useAuth();const ref = useRef();
  useEffect(()=>{
    axios.get('/api/messages/conversations').then(r=>setConvos(r.data));
    const w=params.get('with');if(w)loadChat(w);
  },[]);
  useEffect(()=>{ref.current?.scrollIntoView({behavior:'smooth'});},[msgs]);
  const loadChat = async (id,u) => {
    setActive(u||{_id:id});
    const {data} = await axios.get(`/api/messages/${id}`);setMsgs(data);
    clearInterval(window._poll);
    window._poll = setInterval(async()=>{const r=await axios.get(`/api/messages/${id}`);setMsgs(r.data)},5000);
  };
  const send = async e => {
    e.preventDefault();if(!text.trim()||!active)return;
    const {data} = await axios.post('/api/messages',{receiver:active._id,text});
    setMsgs(p=>[...p,data]);setText('');
  };
  const box = {background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',overflow:'hidden'};
  return (
    <div style={{maxWidth:'900px',margin:'0 auto',padding:'1rem',height:'calc(100vh - 64px)',display:'flex',gap:'12px'}}>
      <div style={{...box,width:'220px',flexShrink:0,display:'flex',flexDirection:'column'}}>
        <div style={{padding:'12px',borderBottom:'1px solid #2a2a38',fontWeight:'500',fontSize:'14px'}}>Messages</div>
        <div style={{overflowY:'auto',flex:1}}>
          {convos.length===0&&<p style={{color:'#9ca3af',fontSize:'12px',padding:'12px',textAlign:'center'}}>No chats yet</p>}
          {convos.map(c=>(
            <button key={c.user._id} onClick={()=>loadChat(c.user._id,c.user)} style={{width:'100%',textAlign:'left',padding:'10px 12px',background:active?._id===c.user._id?'#2a2a38':'transparent',border:'none',borderBottom:'1px solid #2a2a38',cursor:'pointer',color:'#f0f0f0'}}>
              <div style={{fontSize:'13px',fontWeight:'500'}}>{c.user.name}</div>
              <div style={{fontSize:'11px',color:'#9ca3af',overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{c.lastMessage}</div>
            </button>
          ))}
        </div>
      </div>
      <div style={{...box,flex:1,display:'flex',flexDirection:'column'}}>
        {active?(<>
          <div style={{padding:'12px',borderBottom:'1px solid #2a2a38',fontWeight:'500',fontSize:'14px'}}>{active.name||'Chat'}</div>
          <div style={{flex:1,overflowY:'auto',padding:'12px',display:'flex',flexDirection:'column',gap:'8px'}}>
            {msgs.map(m=>(
              <div key={m._id} style={{display:'flex',justifyContent:m.sender._id===user?.id||m.sender===user?.id?'flex-end':'flex-start'}}>
                <div style={{maxWidth:'70%',padding:'8px 12px',borderRadius:'12px',fontSize:'13px',background:m.sender._id===user?.id||m.sender===user?.id?'#4f46e5':'#2a2a38'}}>{m.text}</div>
              </div>
            ))}
            <div ref={ref} />
          </div>
          <form onSubmit={send} style={{padding:'10px',borderTop:'1px solid #2a2a38',display:'flex',gap:'8px'}}>
            <input style={{flex:1,background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px 12px',color:'#f0f0f0',fontSize:'13px'}} placeholder="Type a message..." value={text} onChange={e=>setText(e.target.value)} />
            <button type="submit" style={{background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'8px 16px',cursor:'pointer'}}>Send</button>
          </form>
        </>):<div style={{flex:1,display:'flex',alignItems:'center',justifyContent:'center',color:'#9ca3af',fontSize:'14px'}}>Select a conversation</div>}
      </div>
    </div>
  );
}
