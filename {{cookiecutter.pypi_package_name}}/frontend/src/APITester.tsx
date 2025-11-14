{% raw %}
import {useState} from "react";
import { getHello, putHello, getHelloWithName} from "./service.ts";


export function APITester() {
  const [result, setResult] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [name, setName] = useState<string>('');


  const handleGetHello = async () => {
    setLoading(true);
    try {
      const data = await getHello();
      setResult(JSON.stringify(data, null, 2));
    } catch (error) {
      setResult(`Error :${error}`);
    } finally {
      setLoading(false);
    }
  }

  const handlePutHello = async () => {
    setLoading(true);
    try {
      const data = await putHello();
      setResult(JSON.stringify(data, null, 2));
    } catch (error) {
      setResult(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  const handleGetHelloWithName = async () => {
    if (!name.trim()) {
      setResult('Please enter a name');
      return;
    }

    setLoading(true);
    try {
      const data = await getHelloWithName(name);
      setResult(JSON.stringify(data, null, 2));
    } catch (error) {
      setResult(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  return (
      <div style={{ padding: '20px' }}>
        <h2>API Tester</h2>

        <div style={{ marginBottom: '10px' }}>
          <button onClick={handleGetHello} disabled={loading}>
            GET /api/hello
          </button>
        </div>

        <div style={{ marginBottom: '10px' }}>
          <button onClick={handlePutHello} disabled={loading}>
            PUT /api/hello
          </button>
        </div>

        <div style={{ marginBottom: '10px' }}>
          <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter name"
              style={{ marginRight: '10px' }}
          />
          <button onClick={handleGetHelloWithName} disabled={loading}>
            GET /api/hello/:name
          </button>
        </div>

        <div style={{ marginTop: '20px' }}>
          <h3>Result:</h3>
          <pre style={{
            backgroundColor: '#f5f5f5',
            padding: '10px',
            border: '1px solid #ccc',
            whiteSpace: 'pre-wrap',
            color: '#000',
            textAlign: 'left',
            fontFamily: 'monospace',
            overflow: 'auto',
          }}>
  {loading ? 'Loading...' : result}
</pre>
        </div>
      </div>
  );
}
{% endraw %}