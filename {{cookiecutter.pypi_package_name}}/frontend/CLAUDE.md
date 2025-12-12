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
- `auth.ts` & `auth.config.ts` - Authentication configuration
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
- Authentication is handled via `auth.ts` configuration

### Styling
- Follow consistent CSS/styling patterns
- Use component-scoped styles when appropriate

## Notes

- This is a Next.js application using the App Router
- Uses Bun as the package manager and runtime
- Authentication system is configured
- TypeScript is required throughout the codebase
