import React from 'react';
import { useAuth } from './AuthContext';

export const LoginButton: React.FC = () => {
  const { user, isLoading, login, logout } = useAuth();

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (user) {
    return (
      <div className="user-info">
        <div className="user-profile">
          <img src={user.picture} alt="Profile" className="profile-img" />
          <div className="user-details">
            <h3>Welcome, {user.name}!</h3>
            <p>{user.email}</p>
          </div>
        </div>
        <button onClick={logout} className="logout-btn">
          Logout
        </button>
      </div>
    );
  }

  return (
    <div className="login-section">
      <p>Please login to access all features</p>
      <button onClick={login} className="login-btn">
        Login with Google
      </button>
    </div>
  );
};
