# House Defaults

> **Edit this file to make the skill yours.** These are the owner's preferred stacks. The skill applies them first and only deviates when a project's requirements clearly demand it, and it must say why.
>
> Last reviewed: October 2026

## Global preferences

- **Primary language:** TypeScript (web, APIs, mobile). Python for data, ML, forecasting and automation.
- **Package managers:** pnpm (JS/TS), uv (Python).
- **Default database:** PostgreSQL, colocated with the app server for lowest latency.
- **Default cache:** Redis-compatible (Valkey or Redis) on the same server.
- **Default ORM:** Drizzle (TS), SQLAlchemy 2 + Alembic (Python).
- **Default auth:** Better Auth (TS), storing users in our own Postgres.
- **Default hosting:** VPS with Docker Compose, Caddy as reverse proxy (automatic HTTPS), Cloudflare in front for DNS, CDN, WAF and DDoS protection. Coolify or Dokploy if a dashboard is preferred.
- **Default object storage:** Cloudflare R2 (S3-compatible, no egress fees).
- **Default backups:** Nightly encrypted Postgres dumps to R2 + WAL archiving for point-in-time recovery; monthly restore test.
- **Default email:** Resend (transactional).
- **Default monitoring:** Sentry (errors), Uptime Kuma or Better Stack (uptime), structured logs.
- **Default CI/CD:** GitHub Actions → build Docker image → push to GHCR → deploy to VPS.
- **Default styling:** Tailwind CSS + shadcn/ui.
- **Region:** Closest available to users (owner is in the UAE/Gulf region); respect data-residency rules for government or regulated work.
- **Speed priority:** High. Prefer colocated DB, indexes, caching and SSR/edge-cached pages over anything that adds network hops.

## Per project type

| Project type | House stack |
|---|---|
| Landing page / marketing site | Astro + Tailwind on Cloudflare (Workers static assets/Pages). Use Next.js instead if the page will grow into an app. |
| Blog / docs | Astro (Starlight for docs) + MDX, on Cloudflare. |
| Web app with login (SaaS, portals, dashboards per user) | TanStack Start + Postgres (same VPS) + Drizzle + Better Auth + Redis/Valkey + Docker/Caddy on VPS + Cloudflare + R2 backups + Resend. |
| Multi-tenant B2B SaaS | Same as above + organizations plugin in Better Auth + Postgres row-level security or tenant_id scoping + Stripe. |
| Public API | Hono (TS) or FastAPI (Python) + Postgres + OpenAPI docs. |
| Internal data / analytics tool | Python: Streamlit or Flask/FastAPI. If the organization has a data platform (e.g., Dataiku, Databricks), deploy there to inherit its auth and data access. |
| Dashboards / BI for business users | Power BI if the org already uses Microsoft; otherwise Metabase or Superset on Postgres/ClickHouse. Custom: TanStack Start + Recharts/ECharts. |
| Forecasting / ML | Python, Polars/pandas, statsforecast/LightGBM, MLflow, FastAPI for serving. |
| LLM / chatbot / RAG app | TanStack Start or Next.js + Vercel AI SDK, or FastAPI + provider SDK; Postgres + pgvector; streaming responses. |
| Mobile app | Expo (React Native) + shared TypeScript API + Better Auth. |
| Desktop app | Tauri + React. |
| Browser extension | WXT + React. |
| CLI | Go (distributed binaries) or Python + Typer (internal). |
| Bot (Telegram/Discord/WhatsApp) | TypeScript (grammY / discord.js) or Python; Postgres; VPS. |
| Hackathon / prototype | Whatever ships fastest: Next.js or TanStack Start + Supabase (auth + DB in one), deploy to Vercel. Rebuild properly if it survives. |

## Things we avoid by default

- Kubernetes for anything a single VPS or PaaS can run.
- Microservices before the monolith hurts.
- MongoDB for relational data.
- Hand-rolled auth or password hashing.
- Storing secrets in the repo.
- A database in a different region from the app.
- Firebase/Supabase lock-in for long-lived products unless their features are central (fine for prototypes).
