# Postgres + Node + React Setup Template

A full-stack starter template wiring together a **React** frontend and an **Express** backend with **Prisma ORM** and **PostgreSQL**. Designed to get you from zero to a working full-stack TypeScript app in minutes.

![Node.js](https://img.shields.io/badge/Node.js-22+-339933?logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5.9-3178C6?logo=typescript&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)
![Vite](https://img.shields.io/badge/Vite-7-646CFF?logo=vite&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss&logoColor=white)
![Express](https://img.shields.io/badge/Express-5-000000?logo=express&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-7-2D3748?logo=prisma&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-ISC-blue)

---

## Tech Stack

| Layer     | Technology                          |
| --------- | ----------------------------------- |
| Frontend  | React 19, Vite 7, Tailwind CSS 4   |
| Backend   | Express 5, Node.js, TypeScript 5.9  |
| ORM       | Prisma 7 (with `@prisma/adapter-pg`)|
| Database  | PostgreSQL                          |
| Tooling   | ESLint, tsx, ts-node                |

---

## Prerequisites

| Requirement  | Version  | Check              |
| ------------ | -------- | ------------------ |
| **Node.js**  | >= 22    | `node -v`          |
| **npm**      | >= 10    | `npm -v`           |
| **PostgreSQL** | >= 14  | `psql --version`   |

> **Tip:** You can also use **yarn** or **pnpm** as your package manager — just substitute the relevant commands below.

---

## Quick Start

### Automated (Recommended)

Run the interactive setup script — it handles everything for you:

```bash
git clone https://github.com/naikmubashir/setup-template.git
cd setup-template
./setup.sh
```

The script will:

1. Check prerequisites (Node.js, npm, git)
2. Prompt for project name, description, author, version, and license
3. Collect PostgreSQL connection details
4. Update `package.json` in both frontend and backend
5. Update the `VERSION` file and App title
6. Create `.env` files for backend and frontend
7. Install all dependencies
8. Generate the Prisma client
9. Initialise a fresh git repository with an initial commit

### Manual

```bash
# 1. Clone the repo
git clone https://github.com/naikmubashir/setup-template.git
cd setup-template

# 2. Install dependencies for both frontend and backend
cd backend && npm install && cd ..
cd frontend && npm install && cd ..

# 3. Configure environment variables (see section below)
cp backend/.env.example backend/.env   # then edit with your DB credentials

# 4. Generate Prisma client & run migrations
cd backend
npx prisma generate
npx prisma migrate dev --name init
cd ..

# 5. Start both servers
# Terminal 1 — Backend
cd backend && npx tsx src/server.ts

# Terminal 2 — Frontend
cd frontend && npm run dev
```

The frontend is served at **http://localhost:5173** and the backend API at **http://localhost:9000**.

---

## Environment Setup

Create a `.env` file inside the `backend/` directory:

```env
# backend/.env
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=public"
```

| Variable       | Description                                              |
| -------------- | -------------------------------------------------------- |
| `DATABASE_URL` | Full PostgreSQL connection string used by Prisma and pg. |

> Replace `USER`, `PASSWORD`, `HOST`, `PORT`, and `DATABASE` with your actual PostgreSQL credentials.

---

## Installation (Step by Step)

### Backend

```bash
cd backend
npm install          # install production + dev dependencies
```

Key dependencies installed:

- `express` — HTTP server
- `@prisma/client` & `@prisma/adapter-pg` — Prisma ORM with native pg driver
- `pg` — PostgreSQL client
- `dotenv` — environment variable management
- `typescript`, `tsx`, `ts-node` — TypeScript toolchain

#### Generate Prisma Client

```bash
npx prisma generate
```

#### Run Migrations

```bash
npx prisma migrate dev --name init
```

#### Start the Backend

```bash
npx tsx src/server.ts
# → Server running on port 9000
```

### Frontend

```bash
cd frontend
npm install          # install production + dev dependencies
```

Key dependencies installed:

- `react` & `react-dom` — UI library
- `tailwindcss` & `@tailwindcss/vite` — utility-first CSS
- `vite` — build tool & dev server
- `eslint` — code linting

#### Start the Frontend

```bash
npm run dev
# → http://localhost:5173
```

#### Build for Production

```bash
npm run build        # outputs to frontend/dist
npm run preview      # preview the production build locally
```

---

## Folder Structure

```
postgres-node-react-setup/
├── VERSION                        # Project version (1.0.0)
├── README.md
├── setup.sh                       # Interactive project bootstrapper
│
├── backend/
│   ├── package.json               # Backend dependencies & scripts
│   ├── tsconfig.json              # TypeScript config (ESNext, ES2024)
│   ├── prisma.config.ts           # Prisma configuration (datasource URL, migrations path)
│   ├── prisma/
│   │   └── schema.prisma          # Prisma schema — models & datasource
│   └── src/
│       ├── server.ts              # Express app entry point (port 9000)
│       ├── lib/
│       │   └── prisma.ts          # Prisma client singleton (pg adapter)
│       └── generated/
│           └── prisma/            # Auto-generated Prisma client code
│
└── frontend/
    ├── package.json               # Frontend dependencies & scripts
    ├── index.html                 # HTML entry point
    ├── vite.config.ts             # Vite config (React + Tailwind plugins)
    ├── tsconfig.json              # TypeScript project references
    ├── tsconfig.app.json          # App-specific TS config
    ├── tsconfig.node.json         # Node/Vite TS config
    ├── eslint.config.js           # ESLint configuration
    ├── public/                    # Static assets (served as-is)
    └── src/
        ├── main.tsx               # React DOM entry point
        ├── App.tsx                # Root component
        ├── App.css                # App styles
        ├── index.css              # Global styles
        └── assets/                # Images, fonts, etc.
```

---

## Available Scripts

### Backend

| Command                            | Description                           |
| ---------------------------------- | ------------------------------------- |
| `npx tsx src/server.ts`            | Start the Express server              |
| `npx prisma generate`             | Regenerate the Prisma client          |
| `npx prisma migrate dev`          | Create & apply a new migration        |
| `npx prisma studio`               | Open Prisma's visual DB browser       |

### Frontend

| Command            | Description                            |
| ------------------ | -------------------------------------- |
| `npm run dev`      | Start Vite dev server with HMR         |
| `npm run build`    | Type-check & build for production      |
| `npm run preview`  | Preview the production build locally   |
| `npm run lint`     | Run ESLint across the project          |

---

## Contributing

Contributions are welcome! To get started:

1. **Fork** the repository.
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Make your changes** and commit with clear, descriptive messages:
   ```bash
   git commit -m "feat: add user authentication endpoint"
   ```
4. **Push** your branch:
   ```bash
   git push origin feature/my-feature
   ```
5. **Open a Pull Request** against `main`.

### Guidelines

- Follow the existing code style and project structure.
- Write TypeScript — avoid `any` types where possible.
- Keep PRs focused on a single change or feature.
- Update documentation if your change affects setup or usage.
- Run linting before submitting: `npm run lint` (frontend).

---

## License

This project is licensed under the **ISC License**.
