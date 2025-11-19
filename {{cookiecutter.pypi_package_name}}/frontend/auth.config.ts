import type { NextAuthConfig } from 'next-auth';
import GoogleProvider from "next-auth/providers/google";

export const authConfig = {
  pages: {
    signIn: '/login',
  },
  callbacks: {
    async signIn({ account, profile }) {
        if (account?.provider === "google") {
            return profile?.email?.endsWith("@graphitehq.com") ?? false;
        }
        return true;
    },
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user;
      const isOnDashboard = nextUrl.pathname.startsWith('/app');
      if (isOnDashboard) {
        return isLoggedIn;
      } else if (isLoggedIn) {
        return Response.redirect(new URL('/app', nextUrl));
      }
      return true;
    },
  },
  providers: [
      GoogleProvider({
        clientId: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET
      })
  ],
} satisfies NextAuthConfig;
