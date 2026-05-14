@echo off
echo Creating ZYLO project files...

:: ── backend/package.json ──
(
echo {
echo   "name": "zylo-backend",
echo   "version": "1.0.0",
echo   "main": "server.js",
echo   "scripts": { "start": "node server.js", "dev": "nodemon server.js" },
echo   "dependencies": {
echo     "bcryptjs": "^2.4.3",
echo     "cors": "^2.8.5",
echo     "dotenv": "^16.0.3",
echo     "express": "^4.18.2",
echo     "jsonwebtoken": "^9.0.0",
echo     "mongoose": "^7.3.1"
echo   },
echo   "devDependencies": { "nodemon": "^3.0.1" }
echo }
) > backend\package.json

:: ── backend/.env ──
(
echo PORT=5000
echo MONGO_URI=PASTE_YOUR_ATLAS_URL_HERE
echo JWT_SECRET=iitm_zylo_secret_2024
) > backend\.env

:: ── backend/server.js ──
(
echo const express = require('express'^);
echo const mongoose = require('mongoose'^);
echo const cors = require('cors'^);
echo require('dotenv'^).config(^);
echo const app = express(^);
echo app.use(cors(^)^);
echo app.use(express.json(^)^);
echo mongoose.connect(process.env.MONGO_URI^)
echo   .then(^(^) =^> console.log('MongoDB connected'^)^)
echo   .catch(err =^> console.log(err^)^);
echo app.use('/api/auth', require('./routes/auth'^)^);
echo app.use('/api/items', require('./routes/items'^)^);
echo app.use('/api/messages', require('./routes/messages'^)^);
echo app.use('/api/users', require('./routes/users'^)^);
echo const PORT = process.env.PORT ^|^| 5000;
echo app.listen(PORT, ^(^) =^> console.log(`Server running on port ${PORT}`^)^);
) > backend\server.js

:: ── backend/middleware/auth.js ──
(
echo const jwt = require('jsonwebtoken'^);
echo module.exports = (req, res, next^) =^> {
echo   const token = req.header('Authorization'^)?.replace('Bearer ', '''^);
echo   if (!token^) return res.status(401^).json({ msg: 'No token' }^);
echo   try {
echo     req.user = jwt.verify(token, process.env.JWT_SECRET^);
echo     next(^);
echo   } catch {
echo     res.status(401^).json({ msg: 'Invalid token' }^);
echo   }
echo };
) > backend\middleware\auth.js

:: ── backend/models/User.js ──
(
echo const mongoose = require('mongoose'^);
echo const UserSchema = new mongoose.Schema({
echo   name: { type: String, required: true },
echo   email: { type: String, required: true, unique: true },
echo   password: { type: String, required: true },
echo   rollNo: { type: String },
echo   hostel: { type: String }
echo }, { timestamps: true }^);
echo module.exports = mongoose.model('User', UserSchema^);
) > backend\models\User.js

:: ── backend/models/Item.js ──
(
echo const mongoose = require('mongoose'^);
echo const ItemSchema = new mongoose.Schema({
echo   title: { type: String, required: true },
echo   description: { type: String, required: true },
echo   price: { type: Number, required: true },
echo   type: { type: String, enum: ['rent', 'sale'], required: true },
echo   category: { type: String, default: 'Other' },
echo   image: { type: String, default: '' },
echo   owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
echo   available: { type: Boolean, default: true }
echo }, { timestamps: true }^);
echo module.exports = mongoose.model('Item', ItemSchema^);
) > backend\models\Item.js

:: ── backend/models/Message.js ──
(
echo const mongoose = require('mongoose'^);
echo const MessageSchema = new mongoose.Schema({
echo   sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
echo   receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
echo   item: { type: mongoose.Schema.Types.ObjectId, ref: 'Item' },
echo   text: { type: String, required: true }
echo }, { timestamps: true }^);
echo module.exports = mongoose.model('Message', MessageSchema^);
) > backend\models\Message.js

:: ── backend/routes/auth.js ──
(
echo const router = require('express'^).Router(^);
echo const bcrypt = require('bcryptjs'^);
echo const jwt = require('jsonwebtoken'^);
echo const User = require('../models/User'^);
echo router.post('/register', async (req, res^) =^> {
echo   try {
echo     const { name, email, password, rollNo, hostel } = req.body;
echo     if (await User.findOne({ email }^)^) return res.status(400^).json({ msg: 'Email already exists' }^);
echo     const hash = await bcrypt.hash(password, 10^);
echo     const user = await User.create({ name, email, password: hash, rollNo, hostel }^);
echo     const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' }^);
echo     res.json({ token, user: { id: user._id, name: user.name, email: user.email } }^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo router.post('/login', async (req, res^) =^> {
echo   try {
echo     const { email, password } = req.body;
echo     const user = await User.findOne({ email }^);
echo     if (!user ^|^| !(await bcrypt.compare(password, user.password^)^)^)
echo       return res.status(400^).json({ msg: 'Invalid credentials' }^);
echo     const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' }^);
echo     res.json({ token, user: { id: user._id, name: user.name, email: user.email } }^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo module.exports = router;
) > backend\routes\auth.js

:: ── backend/routes/items.js ──
(
echo const router = require('express'^).Router(^);
echo const Item = require('../models/Item'^);
echo const auth = require('../middleware/auth'^);
echo router.get('/', async (req, res^) =^> {
echo   try {
echo     const { search, category, type } = req.query;
echo     let query = { available: true };
echo     if (search^) query.title = { $regex: search, $options: 'i' };
echo     if (category^) query.category = category;
echo     if (type^) query.type = type;
echo     const items = await Item.find(query^).populate('owner', 'name email rollNo hostel'^).sort('-createdAt'^);
echo     res.json(items^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo router.get('/my', auth, async (req, res^) =^> {
echo   const items = await Item.find({ owner: req.user.id }^).sort('-createdAt'^);
echo   res.json(items^);
echo }^);
echo router.post('/', auth, async (req, res^) =^> {
echo   try {
echo     const item = await Item.create({ ...req.body, owner: req.user.id }^);
echo     res.json(item^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo router.put('/:id', auth, async (req, res^) =^> {
echo   try {
echo     const item = await Item.findOne({ _id: req.params.id, owner: req.user.id }^);
echo     if (!item^) return res.status(404^).json({ msg: 'Not found' }^);
echo     Object.assign(item, req.body^);
echo     await item.save(^);
echo     res.json(item^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo router.delete('/:id', auth, async (req, res^) =^> {
echo   try {
echo     await Item.findOneAndDelete({ _id: req.params.id, owner: req.user.id }^);
echo     res.json({ msg: 'Deleted' }^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo module.exports = router;
) > backend\routes\items.js

:: ── backend/routes/messages.js ──
(
echo const router = require('express'^).Router(^);
echo const Message = require('../models/Message'^);
echo const auth = require('../middleware/auth'^);
echo router.get('/conversations', auth, async (req, res^) =^> {
echo   try {
echo     const msgs = await Message.find({ $or: [{ sender: req.user.id }, { receiver: req.user.id }] }^)
echo       .populate('sender receiver', 'name email'^).sort('-createdAt'^);
echo     const seen = new Set(^); const convos = [];
echo     for (const m of msgs^) {
echo       const other = m.sender._id.toString(^) === req.user.id ? m.receiver : m.sender;
echo       if (!seen.has(other._id.toString(^)^)^) {
echo         seen.add(other._id.toString(^)^);
echo         convos.push({ user: other, lastMessage: m.text }^);
echo       }
echo     }
echo     res.json(convos^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo router.get('/:userId', auth, async (req, res^) =^> {
echo   const msgs = await Message.find({ $or: [
echo     { sender: req.user.id, receiver: req.params.userId },
echo     { sender: req.params.userId, receiver: req.user.id }
echo   ] }^).populate('sender', 'name'^).sort('createdAt'^);
echo   res.json(msgs^);
echo }^);
echo router.post('/', auth, async (req, res^) =^> {
echo   try {
echo     const { receiver, text, item } = req.body;
echo     const msg = await Message.create({ sender: req.user.id, receiver, text, item }^);
echo     await msg.populate('sender', 'name'^);
echo     res.json(msg^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo module.exports = router;
) > backend\routes\messages.js

:: ── backend/routes/users.js ──
(
echo const router = require('express'^).Router(^);
echo const User = require('../models/User'^);
echo const auth = require('../middleware/auth'^);
echo router.get('/me', auth, async (req, res^) =^> {
echo   const user = await User.findById(req.user.id^).select('-password'^);
echo   res.json(user^);
echo }^);
echo router.put('/me', auth, async (req, res^) =^> {
echo   try {
echo     const { name, rollNo, hostel } = req.body;
echo     const user = await User.findByIdAndUpdate(req.user.id, { name, rollNo, hostel }, { new: true }^).select('-password'^);
echo     res.json(user^);
echo   } catch (err^) { res.status(500^).json({ msg: err.message }^); }
echo }^);
echo module.exports = router;
) > backend\routes\users.js

:: ── frontend/package.json ──
(
echo {
echo   "name": "zylo-frontend",
echo   "version": "1.0.0",
echo   "private": true,
echo   "dependencies": {
echo     "axios": "^1.4.0",
echo     "react": "^18.2.0",
echo     "react-dom": "^18.2.0",
echo     "react-router-dom": "^6.14.1",
echo     "react-scripts": "5.0.1"
echo   },
echo   "scripts": {
echo     "start": "react-scripts start",
echo     "build": "react-scripts build"
echo   },
echo   "proxy": "http://localhost:5000"
echo }
) > frontend\package.json

:: ── frontend/tailwind.config.js ──
(
echo module.exports = {
echo   content: ["./src/**/*.{js,jsx}"],
echo   theme: { extend: {} },
echo   plugins: []
echo }
) > frontend\tailwind.config.js

:: ── frontend/public/index.html ──
(
echo ^<!DOCTYPE html^>
echo ^<html lang="en"^>
echo ^<head^>
echo   ^<meta charset="UTF-8" /^>
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0" /^>
echo   ^<title^>ZYLO^</title^>
echo ^</head^>
echo ^<body^>^<div id="root"^>^</div^>^</body^>
echo ^</html^>
) > frontend\public\index.html

:: ── frontend/src/index.css ──
(
echo @tailwind base;
echo @tailwind components;
echo @tailwind utilities;
echo body { font-family: sans-serif; background: #0f0f13; color: #f0f0f0; }
) > frontend\src\index.css

:: ── frontend/src/index.js ──
(
echo import React from 'react';
echo import ReactDOM from 'react-dom/client';
echo import App from './App';
echo import './index.css';
echo ReactDOM.createRoot(document.getElementById('root'^)^).render(^<App /^>^);
) > frontend\src\index.js

:: ── frontend/src/App.jsx ──
(
echo import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
echo import { AuthProvider, useAuth } from './context/AuthContext';
echo import Navbar from './components/Navbar';
echo import Login from './pages/Login';
echo import Dashboard from './pages/Dashboard';
echo import AddItem from './pages/AddItem';
echo import Listings from './pages/Listings';
echo import Chat from './pages/Chat';
echo import Profile from './pages/Profile';
echo function PrivateRoute({ children }^) {
echo   const { user, loading } = useAuth(^);
echo   if (loading^) return ^<div style={{color:'gray',padding:'2rem'}}^>Loading...^</div^>;
echo   return user ? children : ^<Navigate to="/login" /^>;
echo }
echo function App(^) {
echo   return (
echo     ^<AuthProvider^>
echo       ^<BrowserRouter^>
echo         ^<Navbar /^>
echo         ^<Routes^>
echo           ^<Route path="/login" element={^<Login /^>} /^>
echo           ^<Route path="/" element={^<PrivateRoute^>^<Dashboard /^>^</PrivateRoute^>} /^>
echo           ^<Route path="/listings" element={^<PrivateRoute^>^<Listings /^>^</PrivateRoute^>} /^>
echo           ^<Route path="/add-item" element={^<PrivateRoute^>^<AddItem /^>^</PrivateRoute^>} /^>
echo           ^<Route path="/chat" element={^<PrivateRoute^>^<Chat /^>^</PrivateRoute^>} /^>
echo           ^<Route path="/profile" element={^<PrivateRoute^>^<Profile /^>^</PrivateRoute^>} /^>
echo         ^</Routes^>
echo       ^</BrowserRouter^>
echo     ^</AuthProvider^>
echo   ^);
echo }
echo export default App;
) > frontend\src\App.jsx

:: ── frontend/src/context/AuthContext.jsx ──
(
echo import { createContext, useContext, useState, useEffect } from 'react';
echo import axios from 'axios';
echo const AuthContext = createContext(^);
echo export function AuthProvider({ children }^) {
echo   const [user, setUser] = useState(null^);
echo   const [token, setToken] = useState(localStorage.getItem('token'^)^);
echo   const [loading, setLoading] = useState(true^);
echo   useEffect(^(^) =^> {
echo     if (token^) {
echo       axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
echo       axios.get('/api/users/me'^).then(r =^> setUser(r.data^)^).catch(^(^) =^> logout(^)^).finally(^(^) =^> setLoading(false^)^);
echo     } else { setLoading(false^); }
echo   }, [token]^);
echo   const login = (token, userData^) =^> {
echo     localStorage.setItem('token', token^);
echo     axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
echo     setToken(token^); setUser(userData^);
echo   };
echo   const logout = ^(^) =^> {
echo     localStorage.removeItem('token'^);
echo     delete axios.defaults.headers.common['Authorization'];
echo     setToken(null^); setUser(null^);
echo   };
echo   return ^<AuthContext.Provider value={{ user, token, login, logout, loading }}^>{children}^</AuthContext.Provider^>;
echo }
echo export const useAuth = ^(^) =^> useContext(AuthContext^);
) > frontend\src\context\AuthContext.jsx

:: ── frontend/src/components/Navbar.jsx ──
(
echo import { Link, useNavigate } from 'react-router-dom';
echo import { useAuth } from '../context/AuthContext';
echo export default function Navbar(^) {
echo   const { user, logout } = useAuth(^);
echo   const nav = useNavigate(^);
echo   const handleLogout = ^(^) =^> { logout(^); nav('/login'^); };
echo   return (
echo     ^<nav style={{background:'#1a1a24',borderBottom:'1px solid #2a2a38',padding:'12px 16px',display:'flex',alignItems:'center',justifyContent:'space-between',position:'sticky',top:0,zIndex:50}}^>
echo       ^<Link to="/" style={{color:'#818cf8',fontWeight:'bold',fontSize:'20px',textDecoration:'none'}}^>ZYLO ⚡^</Link^>
echo       {user ? (
echo         ^<div style={{display:'flex',gap:'16px',fontSize:'14px'}}^>
echo           ^<Link to="/listings" style={{color:'#ccc',textDecoration:'none'}}^>Browse^</Link^>
echo           ^<Link to="/add-item" style={{color:'#ccc',textDecoration:'none'}}^>+ List^</Link^>
echo           ^<Link to="/chat" style={{color:'#ccc',textDecoration:'none'}}^>Chat^</Link^>
echo           ^<Link to="/profile" style={{color:'#ccc',textDecoration:'none'}}^>Profile^</Link^>
echo           ^<button onClick={handleLogout} style={{color:'#f87171',background:'none',border:'none',cursor:'pointer'}}^>Logout^</button^>
echo         ^</div^>
echo       ^) : ^<Link to="/login" style={{color:'#818cf8',textDecoration:'none'}}^>Login^</Link^>}
echo     ^</nav^>
echo   ^);
echo }
) > frontend\src\components\Navbar.jsx

:: ── frontend/src/pages/Login.jsx ──
(
echo import { useState } from 'react';
echo import { useNavigate } from 'react-router-dom';
echo import axios from 'axios';
echo import { useAuth } from '../context/AuthContext';
echo const S = { wrap:{minHeight:'100vh',display:'flex',alignItems:'center',justifyContent:'center',padding:'1rem'}, box:{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'16px',padding:'2rem',width:'100%%',maxWidth:'400px'}, inp:{width:'100%%',background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'10px 14px',color:'#f0f0f0',fontSize:'14px',boxSizing:'border-box',marginBottom:'10px'}, btn:{width:'100%%',background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'12px',fontWeight:'600',cursor:'pointer',fontSize:'14px'} };
echo export default function Login(^) {
echo   const [isReg, setIsReg] = useState(false^);
echo   const [form, setForm] = useState({name:'',email:'',password:'',rollNo:'',hostel:''}^);
echo   const [error, setError] = useState(''^);
echo   const { login } = useAuth(^); const nav = useNavigate(^);
echo   const set = k =^> e =^> setForm({...form,[k]:e.target.value}^);
echo   const submit = async e =^> {
echo     e.preventDefault(^); setError(''^);
echo     try {
echo       const { data } = await axios.post(isReg?'/api/auth/register':'/api/auth/login', form^);
echo       login(data.token, data.user^); nav('/'^);
echo     } catch(err^) { setError(err.response?.data?.msg^|^|'Error'^); }
echo   };
echo   return (
echo     ^<div style={S.wrap}^>^<div style={S.box}^>
echo       ^<h1 style={{color:'#818cf8',marginBottom:'4px'}}^>ZYLO ⚡^</h1^>
echo       ^<p style={{color:'#9ca3af',fontSize:'13px',marginBottom:'1.5rem'}}^>IITM Campus Marketplace^</p^>
echo       {error ^&^& ^<p style={{color:'#f87171',fontSize:'13px',marginBottom:'12px'}}^>{error}^</p^>}
echo       ^<form onSubmit={submit}^>
echo         {isReg ^&^& ^<^>^<input style={S.inp} placeholder="Full Name" value={form.name} onChange={set('name'^)} required /^>
echo           ^<input style={S.inp} placeholder="Roll No" value={form.rollNo} onChange={set('rollNo'^)} /^>
echo           ^<input style={S.inp} placeholder="Hostel" value={form.hostel} onChange={set('hostel'^)} /^>^</^>}
echo         ^<input style={S.inp} type="email" placeholder="Email" value={form.email} onChange={set('email'^)} required /^>
echo         ^<input style={S.inp} type="password" placeholder="Password" value={form.password} onChange={set('password'^)} required /^>
echo         ^<button type="submit" style={S.btn}^>{isReg?'Register':'Login'}^</button^>
echo       ^</form^>
echo       ^<p style={{textAlign:'center',fontSize:'13px',color:'#9ca3af',marginTop:'1rem'}}^>
echo         {isReg?'Have an account?':"No account?"} ^<button onClick={^(^)=^>setIsReg(!isReg^)} style={{color:'#818cf8',background:'none',border:'none',cursor:'pointer'}}^>{isReg?'Login':'Register'}^</button^>
echo       ^</p^>
echo     ^</div^>^</div^>
echo   ^);
echo }
) > frontend\src\pages\Login.jsx

:: ── frontend/src/pages/Dashboard.jsx ──
(
echo import { useEffect, useState } from 'react';
echo import { Link } from 'react-router-dom';
echo import axios from 'axios';
echo import { useAuth } from '../context/AuthContext';
echo const P = {padding:'1rem',maxWidth:'800px',margin:'0 auto'};
echo const card = {background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',padding:'1rem',marginBottom:'10px'};
echo export default function Dashboard(^) {
echo   const { user } = useAuth(^);
echo   const [items, setItems] = useState([]^);
echo   useEffect(^(^)=^>{axios.get('/api/items/my'^).then(r=^>setItems(r.data^)^);},[]);
echo   const del = async id =^> {
echo     if(!window.confirm('Delete?'^)^) return;
echo     await axios.delete(`/api/items/${id}`^);
echo     setItems(items.filter(i=^>i._id!==id^)^);
echo   };
echo   return (
echo     ^<div style={P}^>
echo       ^<div style={{display:'flex',justifyContent:'space-between',alignItems:'center',marginBottom:'1.5rem'}}^>
echo         ^<div^>^<h2 style={{margin:0}}^>Hey, {user?.name?.split(' '^)[0]} 👋^</h2^>^<p style={{color:'#9ca3af',fontSize:'13px',margin:0}}^>Your listings^</p^>^</div^>
echo         ^<Link to="/add-item" style={{background:'#4f46e5',color:'white',padding:'8px 16px',borderRadius:'8px',textDecoration:'none',fontSize:'14px'}}^>+ Add Listing^</Link^>
echo       ^</div^>
echo       ^<div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:'12px',marginBottom:'1.5rem'}}^>
echo         ^<div style={{...card,textAlign:'center'}}^>^<div style={{fontSize:'28px',color:'#818cf8'}}^>{items.length}^</div^>^<div style={{color:'#9ca3af',fontSize:'13px'}}^>Total^</div^>^</div^>
echo         ^<div style={{...card,textAlign:'center'}}^>^<div style={{fontSize:'28px',color:'#34d399'}}^>{items.filter(i=^>i.type==='rent'^).length}^</div^>^<div style={{color:'#9ca3af',fontSize:'13px'}}^>Rent^</div^>^</div^>
echo         ^<div style={{...card,textAlign:'center'}}^>^<div style={{fontSize:'28px',color:'#fbbf24'}}^>{items.filter(i=^>i.type==='sale'^).length}^</div^>^<div style={{color:'#9ca3af',fontSize:'13px'}}^>Sale^</div^>^</div^>
echo       ^</div^>
echo       {items.length===0?^<p style={{textAlign:'center',color:'#9ca3af'}}^>No listings yet. ^<Link to="/add-item" style={{color:'#818cf8'}}^>Add one!^</Link^>^</p^>:
echo       items.map(item=^>(
echo         ^<div key={item._id} style={{...card,display:'flex',justifyContent:'space-between',alignItems:'center'}}^>
echo           ^<div^>^<div style={{fontWeight:'500'}}^>{item.title}^</div^>^<div style={{color:'#9ca3af',fontSize:'13px'}}^>₹{item.price} · {item.type} · {item.category}^</div^>^</div^>
echo           ^<div style={{display:'flex',gap:'8px'}}^>
echo             ^<Link to={`/add-item?edit=${item._id}`} style={{fontSize:'12px',background:'#2a2a38',color:'#f0f0f0',padding:'6px 12px',borderRadius:'6px',textDecoration:'none'}}^>Edit^</Link^>
echo             ^<button onClick={^(^)=^>del(item._id^)} style={{fontSize:'12px',background:'rgba(239,68,68,0.2^)',color:'#f87171',border:'none',padding:'6px 12px',borderRadius:'6px',cursor:'pointer'}}^>Delete^</button^>
echo           ^</div^>
echo         ^</div^>
echo       ^)^)}
echo     ^</div^>
echo   ^);
echo }
) > frontend\src\pages\Dashboard.jsx

:: ── frontend/src/pages/AddItem.jsx ──
(
echo import { useState, useEffect } from 'react';
echo import { useNavigate, useSearchParams } from 'react-router-dom';
echo import axios from 'axios';
echo const inp = {width:'100%%',background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'8px',padding:'10px 14px',color:'#f0f0f0',fontSize:'14px',boxSizing:'border-box',marginBottom:'12px'};
echo const CATS = ['Books','Electronics','Furniture','Clothing','Sports','Stationery','Other'];
echo export default function AddItem(^) {
echo   const [form,setForm] = useState({title:'',description:'',price:'',type:'sale',category:'Other',image:''}^);
echo   const [error,setError] = useState(''^); const [loading,setLoading] = useState(false^);
echo   const [params] = useSearchParams(^); const editId = params.get('edit'^); const nav = useNavigate(^);
echo   useEffect(^(^)=^>{
echo     if(editId^) axios.get('/api/items/my'^).then(r=^>{const i=r.data.find(x=^>x._id===editId^);if(i^)setForm({title:i.title,description:i.description,price:i.price,type:i.type,category:i.category,image:i.image^|^|''}^);});
echo   },[editId]^);
echo   const set = k =^> e =^> setForm({...form,[k]:e.target.value}^);
echo   const submit = async e =^> {
echo     e.preventDefault(^);setLoading(true^);setError(''^);
echo     try { if(editId^) await axios.put(`/api/items/${editId}`,form^); else await axios.post('/api/items',form^); nav('/'^); }
echo     catch(err^){setError(err.response?.data?.msg^|^|'Failed'^);}
echo     setLoading(false^);
echo   };
echo   return (
echo     ^<div style={{maxWidth:'480px',margin:'0 auto',padding:'1rem'}}^>
echo       ^<h2^>{editId?'Edit':'New'} Listing^</h2^>
echo       {error^&^&^<p style={{color:'#f87171',fontSize:'13px'}}^>{error}^</p^>}
echo       ^<form onSubmit={submit}^>
echo         ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Title^</label^>
echo         ^<input style={inp} placeholder="e.g. Calculus Textbook" value={form.title} onChange={set('title'^)} required /^>
echo         ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Description^</label^>
echo         ^<textarea style={{...inp,height:'80px',resize:'none'}} placeholder="Describe your item..." value={form.description} onChange={set('description'^)} required /^>
echo         ^<div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:'12px'}}^>
echo           ^<div^>^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Price (₹^)^</label^>^<input type="number" style={inp} placeholder="0" value={form.price} onChange={set('price'^)} required /^>^</div^>
echo           ^<div^>^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Type^</label^>^<select style={inp} value={form.type} onChange={set('type'^)}^>^<option value="sale"^>Sale^</option^>^<option value="rent"^>Rent^</option^>^</select^>^</div^>
echo         ^</div^>
echo         ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Category^</label^>
echo         ^<select style={inp} value={form.category} onChange={set('category'^)}^>{CATS.map(c=^>^<option key={c}^>{c}^</option^>^)}^</select^>
echo         ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Image URL (optional^)^</label^>
echo         ^<input style={inp} placeholder="https://..." value={form.image} onChange={set('image'^)} /^>
echo         ^<button type="submit" disabled={loading} style={{width:'100%%',background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'12px',fontWeight:'600',cursor:'pointer'}}^>{loading?'Saving...':editId?'Update':'Post Listing'}^</button^>
echo       ^</form^>
echo     ^</div^>
echo   ^);
echo }
) > frontend\src\pages\AddItem.jsx

:: ── frontend/src/pages/Listings.jsx ──
(
echo import { useEffect, useState } from 'react';
echo import { useNavigate } from 'react-router-dom';
echo import axios from 'axios';
echo import { useAuth } from '../context/AuthContext';
echo const CATS = ['All','Books','Electronics','Furniture','Clothing','Sports','Stationery','Other'];
echo export default function Listings(^) {
echo   const [items,setItems] = useState([]^);const [search,setSearch] = useState(''^);
echo   const [cat,setCat] = useState('All'^);const [type,setType] = useState(''^);const [loading,setLoading] = useState(true^);
echo   const {user} = useAuth(^);const nav = useNavigate(^);
echo   const fetch = async ^(^) =^> {
echo     setLoading(true^);
echo     const p={};if(search^)p.search=search;if(cat!=='All'^)p.category=cat;if(type^)p.type=type;
echo     const {data} = await axios.get('/api/items',{params:p}^);setItems(data^);setLoading(false^);
echo   };
echo   useEffect(^(^)=^>{fetch(^);},[cat,type]^);
echo   return (
echo     ^<div style={{maxWidth:'900px',margin:'0 auto',padding:'1rem'}}^>
echo       ^<h2^>Browse Listings^</h2^>
echo       ^<div style={{display:'flex',gap:'8px',marginBottom:'12px',flexWrap:'wrap'}}^>
echo         ^<input style={{flex:1,minWidth:'200px',background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px 12px',color:'#f0f0f0',fontSize:'14px'}} placeholder="Search..." value={search} onChange={e=^>setSearch(e.target.value^)} onKeyDown={e=^>e.key==='Enter'^&^&fetch(^)} /^>
echo         ^<button onClick={fetch} style={{background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'8px 16px',cursor:'pointer'}}^>Search^</button^>
echo         ^<select style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px',color:'#f0f0f0'}} value={type} onChange={e=^>setType(e.target.value^)}^>^<option value=""^>All Types^</option^>^<option value="sale"^>Sale^</option^>^<option value="rent"^>Rent^</option^>^</select^>
echo       ^</div^>
echo       ^<div style={{display:'flex',gap:'8px',flexWrap:'wrap',marginBottom:'1rem'}}^>
echo         {CATS.map(c=^>^<button key={c} onClick={^(^)=^>setCat(c^)} style={{padding:'4px 12px',borderRadius:'20px',border:'1px solid #2a2a38',background:cat===c?'#4f46e5':'#1a1a24',color:cat===c?'white':'#9ca3af',cursor:'pointer',fontSize:'12px'}}^>{c}^</button^>^)}
echo       ^</div^>
echo       {loading?^<p style={{color:'#9ca3af',textAlign:'center'}}^>Loading...^</p^>:items.length===0?^<p style={{color:'#9ca3af',textAlign:'center'}}^>No items found^</p^>:
echo       ^<div style={{display:'grid',gridTemplateColumns:'repeat(auto-fill,minmax(260px,1fr^)^)',gap:'12px'}}^>
echo         {items.map(item=^>(
echo           ^<div key={item._id} style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',overflow:'hidden'}}^>
echo             {item.image?^<img src={item.image} alt={item.title} style={{width:'100%%',height:'150px',objectFit:'cover'}} onError={e=^>e.target.style.display='none'} /^>:^<div style={{height:'150px',background:'#2a2a38',display:'flex',alignItems:'center',justifyContent:'center',fontSize:'2rem'}}^>📦^</div^>}
echo             ^<div style={{padding:'12px'}}^>
echo               ^<div style={{display:'flex',justifyContent:'space-between',marginBottom:'4px'}}^>
echo                 ^<span style={{fontWeight:'500',fontSize:'14px'}}^>{item.title}^</span^>
echo                 ^<span style={{fontSize:'11px',padding:'2px 8px',borderRadius:'10px',background:item.type==='rent'?'rgba(52,211,153,0.2^)':'rgba(251,191,36,0.2^)',color:item.type==='rent'?'#34d399':'#fbbf24'}}^>{item.type}^</span^>
echo               ^</div^>
echo               ^<p style={{color:'#9ca3af',fontSize:'12px',margin:'0 0 8px'}}^>{item.description.slice(0,60^)}...^</p^>
echo               ^<div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}^>
echo                 ^<div^>^<div style={{color:'#818cf8',fontWeight:'bold'}}^>₹{item.price}{item.type==='rent'?'/day':''}^</div^>^<div style={{color:'#9ca3af',fontSize:'11px'}}^>{item.owner?.name} · {item.owner?.hostel^|^|'IITM'}^</div^>^</div^>
echo                 {item.owner?._id!==user?.id^&^&^<button onClick={^(^)=^>nav(`/chat?with=${item.owner?._id}`^)} style={{fontSize:'12px',background:'rgba(79,70,229,0.2^)',color:'#818cf8',border:'1px solid rgba(79,70,229,0.3^)',padding:'6px 10px',borderRadius:'6px',cursor:'pointer'}}^>Chat^</button^>}
echo               ^</div^>
echo             ^</div^>
echo           ^</div^>
echo         ^)^)}
echo       ^</div^>}
echo     ^</div^>
echo   ^);
echo }
) > frontend\src\pages\Listings.jsx

:: ── frontend/src/pages/Chat.jsx ──
(
echo import { useEffect, useState, useRef } from 'react';
echo import { useSearchParams } from 'react-router-dom';
echo import axios from 'axios';
echo import { useAuth } from '../context/AuthContext';
echo export default function Chat(^) {
echo   const [convos,setConvos] = useState([]^);const [msgs,setMsgs] = useState([]^);
echo   const [active,setActive] = useState(null^);const [text,setText] = useState(''^);
echo   const [params] = useSearchParams(^);const {user} = useAuth(^);const ref = useRef(^);
echo   useEffect(^(^)=^>{
echo     axios.get('/api/messages/conversations'^).then(r=^>setConvos(r.data^)^);
echo     const w=params.get('with'^);if(w^)loadChat(w^);
echo   },[^]^);
echo   useEffect(^(^)=^>{ref.current?.scrollIntoView({behavior:'smooth'}^);},[msgs]^);
echo   const loadChat = async (id,u^) =^> {
echo     setActive(u^|^|{_id:id}^);
echo     const {data} = await axios.get(`/api/messages/${id}`^);setMsgs(data^);
echo     clearInterval(window._poll^);
echo     window._poll = setInterval(async^(^)=^>{const r=await axios.get(`/api/messages/${id}`^);setMsgs(r.data^)},5000^);
echo   };
echo   const send = async e =^> {
echo     e.preventDefault(^);if(!text.trim(^)^|^|!active^)return;
echo     const {data} = await axios.post('/api/messages',{receiver:active._id,text}^);
echo     setMsgs(p=^>[...p,data]^);setText(''^);
echo   };
echo   const box = {background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',overflow:'hidden'};
echo   return (
echo     ^<div style={{maxWidth:'900px',margin:'0 auto',padding:'1rem',height:'calc(100vh - 64px^)',display:'flex',gap:'12px'}}^>
echo       ^<div style={{...box,width:'220px',flexShrink:0,display:'flex',flexDirection:'column'}}^>
echo         ^<div style={{padding:'12px',borderBottom:'1px solid #2a2a38',fontWeight:'500',fontSize:'14px'}}^>Messages^</div^>
echo         ^<div style={{overflowY:'auto',flex:1}}^>
echo           {convos.length===0^&^&^<p style={{color:'#9ca3af',fontSize:'12px',padding:'12px',textAlign:'center'}}^>No chats yet^</p^>}
echo           {convos.map(c=^>(
echo             ^<button key={c.user._id} onClick={^(^)=^>loadChat(c.user._id,c.user^)} style={{width:'100%%',textAlign:'left',padding:'10px 12px',background:active?._id===c.user._id?'#2a2a38':'transparent',border:'none',borderBottom:'1px solid #2a2a38',cursor:'pointer',color:'#f0f0f0'}}^>
echo               ^<div style={{fontSize:'13px',fontWeight:'500'}}^>{c.user.name}^</div^>
echo               ^<div style={{fontSize:'11px',color:'#9ca3af',overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}^>{c.lastMessage}^</div^>
echo             ^</button^>
echo           ^)^)}
echo         ^</div^>
echo       ^</div^>
echo       ^<div style={{...box,flex:1,display:'flex',flexDirection:'column'}}^>
echo         {active?(^<^>
echo           ^<div style={{padding:'12px',borderBottom:'1px solid #2a2a38',fontWeight:'500',fontSize:'14px'}}^>{active.name^|^|'Chat'}^</div^>
echo           ^<div style={{flex:1,overflowY:'auto',padding:'12px',display:'flex',flexDirection:'column',gap:'8px'}}^>
echo             {msgs.map(m=^>(
echo               ^<div key={m._id} style={{display:'flex',justifyContent:m.sender._id===user?.id^|^|m.sender===user?.id?'flex-end':'flex-start'}}^>
echo                 ^<div style={{maxWidth:'70%%',padding:'8px 12px',borderRadius:'12px',fontSize:'13px',background:m.sender._id===user?.id^|^|m.sender===user?.id?'#4f46e5':'#2a2a38'}}^>{m.text}^</div^>
echo               ^</div^>
echo             ^)^)}
echo             ^<div ref={ref} /^>
echo           ^</div^>
echo           ^<form onSubmit={send} style={{padding:'10px',borderTop:'1px solid #2a2a38',display:'flex',gap:'8px'}}^>
echo             ^<input style={{flex:1,background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'8px 12px',color:'#f0f0f0',fontSize:'13px'}} placeholder="Type a message..." value={text} onChange={e=^>setText(e.target.value^)} /^>
echo             ^<button type="submit" style={{background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'8px 16px',cursor:'pointer'}}^>Send^</button^>
echo           ^</form^>
echo         ^</^>^):^<div style={{flex:1,display:'flex',alignItems:'center',justifyContent:'center',color:'#9ca3af',fontSize:'14px'}}^>Select a conversation^</div^>}
echo       ^</div^>
echo     ^</div^>
echo   ^);
echo }
) > frontend\src\pages\Chat.jsx

:: ── frontend/src/pages/Profile.jsx ──
(
echo import { useState, useEffect } from 'react';
echo import axios from 'axios';
echo import { useAuth } from '../context/AuthContext';
echo const inp = {width:'100%%',background:'#0f0f13',border:'1px solid #2a2a38',borderRadius:'8px',padding:'10px 14px',color:'#f0f0f0',fontSize:'14px',boxSizing:'border-box',marginBottom:'12px'};
echo export default function Profile(^) {
echo   const {user,login,token} = useAuth(^);
echo   const [form,setForm] = useState({name:'',rollNo:'',hostel:''}^);
echo   const [msg,setMsg] = useState({text:'',ok:true}^);
echo   useEffect(^(^)=^>{axios.get('/api/users/me'^).then(r=^>setForm({name:r.data.name^|^|'',rollNo:r.data.rollNo^|^|'',hostel:r.data.hostel^|^|''}^)^);},[^]^);
echo   const set = k =^> e =^> setForm({...form,[k]:e.target.value}^);
echo   const submit = async e =^> {
echo     e.preventDefault(^);
echo     try{const {data}=await axios.put('/api/users/me',form^);login(token,{id:data._id,name:data.name,email:data.email}^);setMsg({text:'Saved!',ok:true}^);}
echo     catch(err^){setMsg({text:err.response?.data?.msg^|^|'Error',ok:false}^);}
echo     setTimeout(^(^)=^>setMsg({text:''}^),2000^);
echo   };
echo   return (
echo     ^<div style={{maxWidth:'440px',margin:'0 auto',padding:'1rem'}}^>
echo       ^<h2^>Profile^</h2^>
echo       ^<div style={{background:'#1a1a24',border:'1px solid #2a2a38',borderRadius:'12px',padding:'1.5rem'}}^>
echo         ^<div style={{display:'flex',alignItems:'center',gap:'12px',marginBottom:'1.5rem'}}^>
echo           ^<div style={{width:'48px',height:'48px',borderRadius:'50%%',background:'#4f46e5',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:'bold',fontSize:'18px'}}^>{user?.name?.[0]?.toUpperCase(^)}^</div^>
echo           ^<div^>^<div style={{fontWeight:'500'}}^>{user?.name}^</div^>^<div style={{color:'#9ca3af',fontSize:'13px'}}^>{user?.email}^</div^>^</div^>
echo         ^</div^>
echo         {msg.text^&^&^<p style={{fontSize:'13px',color:msg.ok?'#34d399':'#f87171',marginBottom:'12px'}}^>{msg.text}^</p^>}
echo         ^<form onSubmit={submit}^>
echo           ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Name^</label^>^<input style={inp} value={form.name} onChange={set('name'^)} /^>
echo           ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Roll Number^</label^>^<input style={inp} placeholder="21f1000123" value={form.rollNo} onChange={set('rollNo'^)} /^>
echo           ^<label style={{color:'#9ca3af',fontSize:'13px'}}^>Hostel^</label^>^<input style={inp} placeholder="Sabarmati" value={form.hostel} onChange={set('hostel'^)} /^>
echo           ^<button type="submit" style={{width:'100%%',background:'#4f46e5',color:'white',border:'none',borderRadius:'8px',padding:'12px',fontWeight:'600',cursor:'pointer'}}^>Save Changes^</button^>
echo         ^</form^>
echo       ^</div^>
echo     ^</div^>
echo   ^);
echo }
) > frontend\src\pages\Profile.jsx

echo.
echo ✅ All files created successfully!
echo.
echo Next steps:
echo 1. Open backend\.env and paste your MongoDB Atlas URL
echo 2. Run: cd backend ^& npm install ^& npm run dev
echo 3. Open new cmd: cd frontend ^& npm install ^& npm start
echo.
pause