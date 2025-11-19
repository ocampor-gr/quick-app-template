import {auth} from "@/auth";

export default async function HelloPage() {
  const session = await auth();
  console.log(session);
  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100vh',
      fontSize: '2rem',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <h1>Hello World!</h1>
      <p style={{ fontSize: '1rem' }}>
        Logged in as: {session?.user?.email}
      </p>
    </div>
  );
}
