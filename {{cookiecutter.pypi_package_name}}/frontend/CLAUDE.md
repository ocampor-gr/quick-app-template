# Frontend Context

When working with this frontend codebase, prioritize readability over cleverness. Ask clarifying questions before making architectural changes.

Do not modify any of the following files:
    - Any hidden folder or file. The hidden folders are the ones prefixed with a dot, for example 
        `.elasticbeanstalk`, `.github`, `.platform`.
    - Any infrastructure file like `docker-compose.yml`, `cookiecutter.json`, the files in the folder `scripts`,
        or the files in the folder `proxy`.

## About This Frontend

Next.js React application with TypeScript for user authentication and profiles. Uses modern React patterns and connects to the FastAPI backend.

## Key Files & Structure

- `app/` - Next.js App Router pages and layouts
- `components/` - Reusable React components
- `lib/` - Utility functions and configurations
- `public/` - Static assets
- `lib/auth.ts` - Auth utility (`getUser()` for server components)
- `proxy.ts` - Route protection middleware (cookie-based redirects)
- `package.json` - Node.js dependencies and scripts

## Standards

- TypeScript required for all components and functions
- Follow React/Next.js best practices
- Use proper TypeScript interfaces and types
- ESLint configuration enforced

## Workflow

- Be sure to run type checking when you're done making a series of code changes
- Use component-based development approach
- Test components individually before integration
- Follow Next.js App Router patterns

## Common Commands

### Install dependencies
`bun install`

### Development server
`bun dev`

## Development Guidelines

### Authentication
- Authentication is owned by the backend via `/api/v1/auth/*` endpoints (Google OAuth login, callback, logout)
- Sessions use HTTP-only `session_token` cookies containing JWTs
- `proxy.ts` middleware protects `/app` routes by checking for the session cookie
- Use `getUser()` from `lib/auth.ts` in server components to fetch the current user

### UI Components

This project uses **Radix UI** primitives for all interactive UI components. Each Radix primitive is wrapped with project-specific styling in `components/ui/`.

**Rules:**
- **Never build custom interactive UI components from scratch.** Always check if a Radix UI primitive exists first at https://www.radix-ui.com/primitives/docs/overview/getting-started. If one exists, install it with `bun add @radix-ui/react-<component>` and create a styled wrapper in `components/ui/`.
- **Never install alternative UI libraries** (e.g., MUI, Chakra, Ant Design, Headless UI, React Aria, shadcn/ui). Radix UI is the only UI primitive library for this project.
- **Use existing `components/ui/` wrappers** when a wrapper already exists. For example, use `import { Avatar } from "@/components/ui/avatar"` instead of importing `@radix-ui/react-avatar` directly in page or feature components.
- **When adding a new Radix component**, follow the existing pattern: create a wrapper in `components/ui/` that applies Tailwind styles, uses `data-slot` attributes, and re-exports the composed component.
- **Extend existing components with variants** using `class-variance-authority` (CVA) rather than creating new component files for minor style differences.
- **Icons must come from `lucide-react`**. Do not add other icon packages.

**Currently installed Radix UI packages:**
`react-avatar`, `react-dialog`, `react-dropdown-menu`, `react-label`, `react-separator`, `react-slot`, `react-tooltip`

**Adding a new Radix UI component:**
```bash
bun add @radix-ui/react-<component-name>
```
Then create a styled wrapper in `components/ui/<component-name>.tsx` following the patterns in existing wrappers.

### Styling
- Tailwind CSS with CSS variables for theming (defined in `app/globals.css`)
- Use the `cn()` utility from `@/lib/utils` for conditional class merging
- Follow the existing pattern of `data-slot` attributes on components
- Do not use CSS-in-JS libraries (styled-components, Emotion, etc.)

## Notes

- This is a Next.js application using the App Router
- Uses Bun as the package manager and runtime
- Authentication is delegated to the backend (no NextAuth)
- TypeScript is required throughout the codebase
