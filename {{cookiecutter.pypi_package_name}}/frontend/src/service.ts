// Configuration
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? 'http://your-backend-url.com'  // Replace with your production backend URL
  : 'http://localhost:8000';  // Local development backend URL

// API client functions
export async function getHello(): Promise<{ message: string; method: string }> {
  const response = await fetch(`${API_BASE_URL}/api/hello`);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
}

export async function putHello(): Promise<{ message: string; method: string }> {
  const response = await fetch(`${API_BASE_URL}/api/hello`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
}

export async function getHelloWithName(name: string): Promise<{ message: string }> {
  const response = await fetch(`${API_BASE_URL}/api/hello/${encodeURIComponent(name)}`);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
}
