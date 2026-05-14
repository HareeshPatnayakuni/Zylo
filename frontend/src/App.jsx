import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Navbar from './components/Navbar';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import AddItem from './pages/AddItem';
import Listings from './pages/Listings';
import Chat from './pages/Chat';
import Profile from './pages/Profile';
function PrivateRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <div style={{color:'gray',padding:'2rem'}}>Loading...</div>;
  return user ? children : <Navigate to="/login" />;
}
function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<PrivateRoute><Dashboard /></PrivateRoute>} />
          <Route path="/listings" element={<PrivateRoute><Listings /></PrivateRoute>} />
          <Route path="/add-item" element={<PrivateRoute><AddItem /></PrivateRoute>} />
          <Route path="/chat" element={<PrivateRoute><Chat /></PrivateRoute>} />
          <Route path="/profile" element={<PrivateRoute><Profile /></PrivateRoute>} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
export default App;
