import React from 'react';
import './Login.css';

function Login({ onLogin }) {
  return (
    <div className="login-container">
      <div className="login-box">
        <h1>Welcome</h1>
        <p>Please sign in to continue</p>
        <button className="login-button" onClick={onLogin}>
          Sign in with Google
        </button>
      </div>
    </div>
  );
}

export default Login;
