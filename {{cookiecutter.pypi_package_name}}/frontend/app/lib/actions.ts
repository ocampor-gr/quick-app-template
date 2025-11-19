'use server';

import { signIn } from '@/auth';
import { AuthError } from 'next-auth';

export async function authenticate() {
  try {
    await signIn('google');
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'AccessDenied':
          return 'Your account is not authorized to access this application.';
        case 'Verification':
          return 'Unable to verify authentication request.';
        default:
          return 'An unexpected authentication error occurred.';
      }
    }
    throw error;
  }
}
