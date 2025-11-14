import React from 'react';
import './Home.css';

function Home({ onLogout }) {
  return (
    <div className="home-container">
      <div className="home-content">
        <h1>Hello World!</h1>
        <p>Welcome to your dashboard</p>
        <button className="logout-button" onClick={onLogout}>
          Logout
        </button>
      </div>
    </div>
  );
}

export default Home;
