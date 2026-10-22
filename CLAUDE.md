# CLAUDE.md — forklift-battery-selector

Repo público con `web/` (HTML/CSS/JS plano), `database/` y `scraper/`. Sin datos de terceros ni de clientes en el repo (ver `.gitignore`).

- Playwright (solo `web/`): `npx playwright test` desde la raíz del repo. Sirve `web/` con `python -m http.server`. El error de consola "Invalid supabaseUrl" se filtra a propósito: el repo no trae `config.local.js`.
- Impeccable: por defecto en cambios de UI de `web/`.
- Arc: no aplica.
