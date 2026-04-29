import { cookies } from "next/headers";
import { getUser } from "@/lib/auth";
import App from "@/app/ui/app";

export default async function Page() {
  const cookieStore = await cookies();
  const user = await getUser(cookieStore.toString());
  return <App user={user!} />;
}
