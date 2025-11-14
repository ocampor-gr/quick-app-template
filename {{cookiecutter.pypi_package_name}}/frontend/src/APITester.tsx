{% raw %}
import {useState} from "react";
import { getHello, putHello, getHelloWithName} from "./service.ts";

const API_BASE_URL = "http://localhost:8000";

export function APITester() {
  const [response, setResponse] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();

  const makeRequest = async (endpoint: string, method: string = "GET", requiresAuth: boolean = false) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        method,
        credentials: 'include', // Include session cookies
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (response.status === 401 && requiresAuth) {
        setError("Authentication required. Please login first.");
        setResponse(null);
        return;
      }

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setResponse(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
      setResponse(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="api-tester">
      <h2>API Tester</h2>

      <div className="button-group">
        <button
          onClick={() => makeRequest("/api/hello")}
          disabled={loading}
        >
          GET Hello (Public)
        </button>

        <button
          onClick={() => makeRequest("/api/hello", "PUT")}
          disabled={loading}
        >
          PUT Hello (Public)
        </button>

        <button
          onClick={() => makeRequest("/api/protected", "GET", true)}
          disabled={loading}
          className={user ? "protected-btn" : "protected-btn disabled"}
          title={user ? "Click to access protected content" : "Login required"}
        >
          GET Protected {!user && "(Login Required)"}
        </button>
      </div>

      {loading && <div className="loading">Loading...</div>}

      {error && (
        <div className="error">
          <strong>Error:</strong> {error}
        </div>
      )}

      {response && (
        <div className={`response ${response.authenticated ? 'authenticated' : 'public'}`}>
          <h3>Response:</h3>
          <pre>{JSON.stringify(response, null, 2)}</pre>
        </div>
      )}
    </div>
  );
}
{% endraw %}