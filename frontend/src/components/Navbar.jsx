import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
export default function Navbar() {
  const { user, logout } = useAuth();
  const nav = useNavigate();
  const handleLogout = () => { logout(); nav('/login'); };
  return (
    <nav style={{background:'#1a1a24',borderBottom:'1px solid #2a2a38',padding:'12px 16px',display:'flex',alignItems:'center',justifyContent:'space-between',position:'sticky',top:0,zIndex:50}}>
      <Link to="/" style={{color:'#818cf8',fontWeight:'bold',fontSize:'20px',textDecoration:'none'}}>ZYLO ⚡</Link>
      {user ? (
        <div style={{display:'flex',gap:'16px',fontSize:'14px'}}>
          <Link to="/listings" style={{color:'#ccc',textDecoration:'none'}}>Browse</Link>
          <Link to="/add-item" style={{color:'#ccc',textDecoration:'none'}}>+ List</Link>
          <Link to="/chat" style={{color:'#ccc',textDecoration:'none'}}>Chat</Link>
          <Link to="/profile" style={{color:'#ccc',textDecoration:'none'}}>Profile</Link>
          <button onClick={handleLogout} style={{color:'#f87171',background:'none',border:'none',cursor:'pointer'}}>Logout</button>
        </div>
      ) : <Link to="/login" style={{color:'#818cf8',textDecoration:'none'}}>Login</Link>}
    </nav>
  );
}
