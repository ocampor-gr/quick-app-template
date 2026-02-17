"use client";

import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { useSearchParams } from "next/navigation";

const ERROR_MESSAGES: Record<string, string> = {
  domain_not_allowed: "Your email domain is not authorized to access this application.",
  no_user_info: "Could not retrieve your account information from Google.",
};

export default function LoginForm() {
  const searchParams = useSearchParams();
  const error = searchParams.get("error");

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>Login to your account</CardTitle>
        <CardDescription>
          Enter your email below to login to your account
        </CardDescription>
      </CardHeader>
      {error && (
        <div className="px-6 pb-2 text-sm text-red-600">
          {ERROR_MESSAGES[error] || "An unexpected authentication error occurred."}
        </div>
      )}
      <CardFooter className="flex-col gap-2">
        <a href="/api/v1/auth/login" className="w-full">
          <button className="inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 w-full cursor-pointer">
            Login with Google
          </button>
        </a>
      </CardFooter>
    </Card>
  )
}
