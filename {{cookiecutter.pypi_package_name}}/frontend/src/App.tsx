import { APITester } from "./APITester";
import { AuthProvider } from "./AuthContext";
import { LoginButton } from "./LoginButton";
import "./index.css";

import logo from "./logo.svg";
import reactLogo from "./react.svg";

export function App() {
  return (
    <AuthProvider>
      <div className="app">
        <div className="logo-container">
          <img src={logo} alt="Bun Logo" className="logo bun-logo" />
          <img src={reactLogo} alt="React Logo" className="logo react-logo" />
        </div>

        <h1>Bun + React</h1>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>

        <LoginButton />
        <APITester />
      </div>
    </AuthProvider>
  );
}

export default App;
