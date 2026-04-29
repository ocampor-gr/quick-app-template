import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { getUser } from "@/lib/auth";

export default async function ProtectedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const cookieStore = await cookies();
  const user = await getUser(cookieStore.toString());

  if (!user) {
    redirect("/api/v1/auth/logout");
  }

  return <>{children}</>;
}
