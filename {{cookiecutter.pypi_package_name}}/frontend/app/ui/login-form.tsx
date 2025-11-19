    // Example component
    "use client"; // For App Router

    import {useSession} from "next-auth/react";
    import {authenticate} from "@/app/lib/actions";

    export default function LoginForm() {
      const { data: session } = useSession();
      return (
        <div>
          {session ? (
          <div>
              <p>Signed in</p>
            </div>
          ) : (
            <button onClick={() => authenticate()}>Sign in with Google</button>
          )}
        </div>
      );
    }
