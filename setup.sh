#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# setup.sh — Interactive project bootstrapper
# Prompts for project metadata, updates configs, installs deps,
# sets up environment files, and initialises a fresh git repo.
# ─────────────────────────────────────────────────────────────

# ── Colours & helpers ────────────────────────────────────────
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

info()    { echo -e "${CYAN}ℹ ${RESET} $*"; }
success() { echo -e "${GREEN}✔ ${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠ ${RESET} $*"; }
error()   { echo -e "${RED}✖ ${RESET} $*"; exit 1; }

divider() { echo -e "\n${BOLD}──────────────────────────────────────────${RESET}\n"; }

# ── Prerequisite checks ─────────────────────────────────────
check_prerequisites() {
  local missing=0

  if ! command -v node &>/dev/null; then
    warn "Node.js is not installed (required >= 22)"
    missing=1
  else
    local node_major
    node_major=$(node -v | sed 's/v//' | cut -d. -f1)
    if (( node_major < 22 )); then
      warn "Node.js version $(node -v) detected — v22+ recommended"
    else
      success "Node.js $(node -v)"
    fi
  fi

  if ! command -v npm &>/dev/null; then
    warn "npm is not installed"
    missing=1
  else
    success "npm $(npm -v)"
  fi

  if ! command -v git &>/dev/null; then
    warn "git is not installed"
    missing=1
  else
    success "git $(git --version | awk '{print $3}')"
  fi

  if (( missing )); then
    error "Please install the missing prerequisites and re-run this script."
  fi
}

# ── Prompt helper (with default) ────────────────────────────
prompt() {
  local var_name="$1" prompt_text="$2" default="${3:-}"
  local input

  if [[ -n "$default" ]]; then
    echo -en "${BOLD}${prompt_text}${RESET} [${default}]: "
  else
    echo -en "${BOLD}${prompt_text}${RESET}: "
  fi
  read -r input
  eval "$var_name=\"${input:-$default}\""
}

# ── Confirm helper ──────────────────────────────────────────
confirm() {
  local prompt_text="$1"
  local answer
  echo -en "${BOLD}${prompt_text}${RESET} (y/N): "
  read -r answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

# ── JSON field updater (portable — no jq required) ──────────
# Uses node to update a field in a JSON file.
update_json_field() {
  local file="$1" field="$2" value="$3"
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('$file', 'utf8'));
    pkg['$field'] = '$value';
    fs.writeFileSync('$file', JSON.stringify(pkg, null, 2) + '\n');
  "
}

# ── Main ────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}${CYAN}  Postgres + Node + React — Project Setup${RESET}"
  echo -e "  ────────────────────────────────────────"
  echo ""

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$SCRIPT_DIR"

  # Step 1 — Prerequisites
  divider
  info "Checking prerequisites …"
  check_prerequisites

  # Step 2 — Collect project metadata
  divider
  info "Tell me about your project:"
  echo ""

  prompt PROJECT_NAME  "Project name"             "my-fullstack-app"
  prompt PROJECT_DESC  "Description"              "A full-stack app with React, Express, Prisma & PostgreSQL"
  prompt AUTHOR_NAME   "Author"                   ""
  prompt PROJECT_VER   "Version"                  "1.0.0"
  prompt LICENSE        "License"                 "ISC"

  # Database setup
  divider
  info "Database configuration (used for backend/.env):"
  echo ""

  prompt DB_USER     "PostgreSQL username"  "postgres"
  prompt DB_PASS     "PostgreSQL password"  "postgres"
  prompt DB_HOST     "PostgreSQL host"      "localhost"
  prompt DB_PORT     "PostgreSQL port"      "5432"
  prompt DB_NAME     "Database name"        "$PROJECT_NAME"

  DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public"

  # Summary
  divider
  echo -e "${BOLD}Summary${RESET}"
  echo ""
  echo "  Project name : $PROJECT_NAME"
  echo "  Description  : $PROJECT_DESC"
  echo "  Author       : ${AUTHOR_NAME:-<none>}"
  echo "  Version      : $PROJECT_VER"
  echo "  License      : $LICENSE"
  echo "  Database URL : postgresql://${DB_USER}:****@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public"
  echo ""

  if ! confirm "Proceed with setup?"; then
    warn "Setup cancelled."
    exit 0
  fi

  # ── Step 3 — Update package.json files ────────────────────
  divider
  info "Updating backend/package.json …"

  update_json_field "backend/package.json" "name"        "${PROJECT_NAME}-backend"
  update_json_field "backend/package.json" "version"     "$PROJECT_VER"
  update_json_field "backend/package.json" "description" "$PROJECT_DESC"
  update_json_field "backend/package.json" "license"     "$LICENSE"
  [[ -n "$AUTHOR_NAME" ]] && update_json_field "backend/package.json" "author" "$AUTHOR_NAME"
  success "backend/package.json updated"

  info "Updating frontend/package.json …"

  update_json_field "frontend/package.json" "name"        "${PROJECT_NAME}-frontend"
  update_json_field "frontend/package.json" "version"     "$PROJECT_VER"
  [[ -n "$AUTHOR_NAME" ]] && update_json_field "frontend/package.json" "author" "$AUTHOR_NAME"
  success "frontend/package.json updated"

  # ── Step 4 — Update VERSION file ──────────────────────────
  echo "$PROJECT_VER" > VERSION
  success "VERSION file updated to $PROJECT_VER"

  # ── Step 5 — Update App.tsx title ─────────────────────────
  if [[ -f "frontend/src/App.tsx" ]]; then
    sed -i '' "s|Prisma-node-typescript-react-tailwind-vite template|${PROJECT_NAME}|g" frontend/src/App.tsx 2>/dev/null \
      || sed -i "s|Prisma-node-typescript-react-tailwind-vite template|${PROJECT_NAME}|g" frontend/src/App.tsx 2>/dev/null \
      || true
    success "frontend/src/App.tsx title updated"
  fi

  # ── Step 6 — Create environment files ─────────────────────
  divider
  info "Setting up environment files …"

  cat > backend/.env <<EOF
# Auto-generated by setup.sh
# PostgreSQL connection string used by Prisma & pg
DATABASE_URL="${DATABASE_URL}"
EOF
  success "backend/.env created"

  # Create frontend .env if it doesn't exist
  cat > frontend/.env <<EOF
# Auto-generated by setup.sh
# Add frontend environment variables below (prefixed with VITE_)
VITE_API_URL=http://localhost:9000
EOF
  success "frontend/.env created"

  # ── Step 7 — Install dependencies ─────────────────────────
  divider
  info "Installing backend dependencies …"
  (cd backend && npm install)
  success "Backend dependencies installed"

  echo ""
  info "Installing frontend dependencies …"
  (cd frontend && npm install)
  success "Frontend dependencies installed"

  # ── Step 8 — Generate Prisma client ───────────────────────
  divider
  info "Generating Prisma client …"
  (cd backend && npx prisma generate)
  success "Prisma client generated"

  # ── Step 9 — Initialise git repository ────────────────────
  divider
  if [[ -d ".git" ]]; then
    if confirm "A .git directory already exists. Re-initialise git repo?"; then
      rm -rf .git
      git init
      git add -A
      git commit -m "chore: initial project setup — ${PROJECT_NAME}"
      success "Git repository re-initialised with initial commit"
    else
      info "Keeping existing git history"
    fi
  else
    git init
    git add -A
    git commit -m "chore: initial project setup — ${PROJECT_NAME}"
    success "Git repository initialised with initial commit"
  fi

  # ── Done! ─────────────────────────────────────────────────
  divider
  echo -e "${BOLD}${GREEN}  ✔  Setup complete!${RESET}"
  echo ""
  echo "  Next steps:"
  echo ""
  echo "    1. Make sure your PostgreSQL database '${DB_NAME}' exists:"
  echo "       ${CYAN}createdb ${DB_NAME}${RESET}"
  echo ""
  echo "    2. Run the first Prisma migration:"
  echo "       ${CYAN}cd backend && npx prisma migrate dev --name init${RESET}"
  echo ""
  echo "    3. Start the backend:"
  echo "       ${CYAN}cd backend && npx tsx src/server.ts${RESET}"
  echo ""
  echo "    4. Start the frontend (new terminal):"
  echo "       ${CYAN}cd frontend && npm run dev${RESET}"
  echo ""
  echo "    Backend  → http://localhost:9000"
  echo "    Frontend → http://localhost:5173"
  echo ""
}

main "$@"
