"use client";

import { Button } from "@/components/ui/button"
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

import {authenticate} from "@/app/lib/actions";

export default function LoginForm() {
  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>Login to your account</CardTitle>
        <CardDescription>
          Enter your email below to login to your account
        </CardDescription>
      </CardHeader>
      <CardFooter className="flex-col gap-2">
        <Button variant="outline" className="w-full" onClick={() => authenticate()}>
          Login with Google
        </Button>
      </CardFooter>
    </Card>
  )
}
