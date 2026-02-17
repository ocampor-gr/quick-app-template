import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { getUser } from "@/lib/auth";
import App from "@/app/ui/app";

export default async function Page() {
  const cookieStore = await cookies();
  const cookieHeader = cookieStore.toString();
  const user = await getUser(cookieHeader);

  if (!user) {
    redirect("/login");
  }

  return <App user={user} />;
}
