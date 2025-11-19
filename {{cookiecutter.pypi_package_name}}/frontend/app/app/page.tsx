import {auth} from "@/auth";
import App from "@/app/ui/app";

export default async function Page() {
  const session = await auth()
  return (
      <App user={session?.user}/>
  );
}
