export interface User {
  name: string;
  email: string;
  image: string;
}

export async function getUser(cookieHeader: string): Promise<User | null> {
  try {
    const response = await fetch("http://backend:8000/auth/me", {
      headers: { cookie: cookieHeader },
    });
    if (!response.ok) {
      return null;
    }
    return (await response.json()) as User;
  } catch {
    return null;
  }
}
