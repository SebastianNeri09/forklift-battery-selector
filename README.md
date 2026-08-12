# Forklift Battery Selector

A full‑stack tool that matches the correct battery to a forklift using four cascading
criteria — **manufacturer → model → voltage → compartment size** — and returns the full
technical sheet of the compatible battery.

Built end to end:

- a **Python scraping + ETL pipeline** that ingests a public, form‑driven manufacturer
  battery catalog into a relational database, and
- a **lightweight web frontend** (vanilla JS + Supabase) that queries it with dependent
  dropdowns.

> **Context.** This was originally built to solve a real need in the material‑handling /
> forklift‑battery industry. This public version is **genericized**: company, client and
> source‑catalog names have been removed, credentials stripped, and the real dataset
> replaced with **simulated sample data** — so the app runs fully without redistributing
> any third party's catalog.

---

## What it demonstrates

- **Web scraping** of a dynamic, form‑driven catalog with `requests` + `BeautifulSoup` +
  `Selenium`, including rate limiting, exponential‑backoff retries and a hybrid
  browser/HTTP‑endpoint strategy.
- **ETL**: normalizing scraped rows (unit stripping, NULL handling, SQL escaping) and
  generating **idempotent** `INSERT` statements.
- **Relational schema design** (PostgreSQL / Supabase): a normalized 5‑table model with
  foreign keys and indexes.
- **Frontend**: cascading dependent dropdowns querying a REST API — no framework, no build
  step, one HTML + one CSS + one JS file.

## Architecture

```
 Public catalog (web)
        │   scraper/scraper.py   (requests + BeautifulSoup + Selenium)
        ▼
   CSV per manufacturer
        │   scraper/build_sql.py  (clean + normalize → SQL)
        ▼
  PostgreSQL / Supabase  ── database/schema.sql + sample_data.sql
        │   REST (@supabase/supabase-js)
        ▼
   Vanilla‑JS frontend   (web/index.html + styles.css + app.js)
```

## Repository layout

```
forklift-battery-selector/
├── scraper/
│   ├── scraper.py               # catalog scraper (OOP, rate‑limited, retried)
│   ├── build_sql.py             # ETL: scraped CSVs → INSERT SQL
│   └── requirements.txt
├── database/
│   ├── schema.sql               # 5‑table relational schema
│   ├── generate_sample_data.py  # generates the simulated dataset
│   └── sample_data.sql          # simulated data (safe to run)
├── web/
│   ├── index.html
│   ├── styles.css
│   └── app.js                   # Supabase creds via placeholders (see .env.example)
├── .env.example
├── .gitignore
└── LICENSE
```

## Run it locally (with the simulated data)

1. **Create a Supabase project** (free tier is enough) — or any PostgreSQL instance.
2. **Schema:** run `database/schema.sql` in the SQL editor.
3. **Data:** run `database/sample_data.sql` (or regenerate it with
   `python database/generate_sample_data.py`).
4. **Row Level Security:** enable RLS on the 5 tables and add a `SELECT` policy for the
   `anon` role (`USING (true)`), so the frontend can read but not write.
5. **Frontend:** copy `.env.example` and set your `SUPABASE_URL` / `SUPABASE_ANON_KEY` in
   `web/app.js`, then open `web/index.html` in a browser.

## Security notes

- **No credentials in the repo** — `web/app.js` ships with placeholders; real keys go in a
  local, git‑ignored config.
- The Supabase **anon key is public by design**, but only safe when RLS is configured for
  read‑only `anon` access. Never expose the `service_role` key or the database password to
  the frontend.

## Tech

Python · pandas · requests · BeautifulSoup · Selenium · PostgreSQL · Supabase ·
HTML / CSS / vanilla JavaScript.

## License

[MIT](LICENSE)
