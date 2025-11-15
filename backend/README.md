# Project Zoe - Backend

This is the backend for Project Zoe, a NestJS application. It uses Prisma for database management and PostgreSQL as the database.

## Note on Project Type
This is a **NestJS** project, a framework for building efficient, scalable Node.js server-side applications. It is not a Next.js project, which is a React framework for building user interfaces.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Node.js](https://nodejs.org/) version 20 or higher
- [npm](https://www.npmjs.com/) (comes with Node.js)
- [PostgreSQL](https://www.postgresql.org/download/)

## Getting Started

### 1. Clone the repository

If you haven't already, clone the project repository to your local machine.

### 2. Navigate to the backend directory

```bash
cd backend
```

### 3. Install dependencies

Install the project dependencies using npm:

```bash
npm install
```

## Environment Configuration

The application requires a `.env` file in the `backend` directory for environment variables.

1.  Create a new file named `.env` in the `d:\learn_develop\projectZoe_mobile\project-zoe-mobile-app\backend` directory.
2.  Add the following environment variable to the `.env` file, replacing the placeholder with your actual PostgreSQL connection string:

    ```
    DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE"
    ```

    **Example:**
    `DATABASE_URL="postgresql://postgres:mysecretpassword@localhost:5432/project_zoe"`

## Database Migration

Once you have configured your database connection, you need to run the Prisma migrations to set up the database schema.

```bash
npm run prisma:migrate
```

This command will apply all pending migrations from the `prisma/migrations` directory to your database.

## Running the Application

To run the application in development mode with hot-reloading, use the following command:

```bash
npm run start:dev
```

The application will start on the default NestJS port (usually `http://localhost:3000`).

## Available Scripts

Here are some of the most common scripts you will use:

-   `npm run start:dev`: Starts the application in development mode with file watching.
-   `npm run build`: Compiles the TypeScript code to JavaScript.
-   `npm run start:prod`: Starts the application in production mode (requires a prior build).
-   `npm run lint`: Lints the codebase using ESLint.
-   `npm run test`: Runs the unit tests using Jest.
-   `npm run prisma:migrate`: Applies database migrations.
-   `npm run prisma:studio`: Opens the Prisma Studio to view and manage your data.

## Running Tests

To execute the unit tests, run:

```bash
npm run test
```

For end-to-end tests, run:

```bash
npm run test:e2e
```
