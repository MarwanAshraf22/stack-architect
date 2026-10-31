# Anti-Patterns: Mistakes to Catch Before They Happen

> Last reviewed: October 2026. When a plan matches one of these, warn the user and explain the better path.

## Architecture
- **Microservices on day one.** Network failures, distributed transactions, and 5x ops cost for no benefit. → Modular monolith.
- **Kubernetes for one app.** → Docker Compose on a VPS, or a PaaS.
- **Choosing tech by hype or a viral tweet.** → Proven tools unless the new one solves a specific problem.
- **Different language per service "because it's best for that job"** in a tiny team. → One primary language.
- **Building what you can rent cheaply** (auth crypto, payments, email delivery, video encoding, search engine). → Use the library/service.
- **Renting what's core to your product** and creates lock-in you can't escape. → Own the core.

## Data
- **Database in a different region from the app** (e.g., Vercel functions in one region, DB in another). Every query adds latency. → Same region, or same server.
- **MongoDB for relational data** "for flexibility". → Postgres with JSONB where flexibility is needed.
- **Floats for money.** → Integer minor units or `numeric`.
- **Timestamps without time zones.** → `timestamptz`, store UTC.
- **No foreign keys/constraints** "for speed". → Let the DB guarantee integrity.
- **Schema changes by hand in production.** → Versioned migrations in CI/CD.
- **BI/analytics queries on the production primary.** → Replica, materialized views, or OLAP store.
- **Storing files in the database or on the app server's disk** in multi-server setups. → Object storage.
- **Random UUIDv4 primary keys on huge write-heavy tables.** → UUIDv7 or bigint.
- **Redis as the only copy of important data** without persistence/backups.

## Auth and security
- **Hand-rolled auth/password hashing/JWT handling.** → Better Auth, framework auth, or hosted provider.
- **JWT in localStorage.** → HTTP-only cookies for web.
- **Authorization only in the UI** (hidden buttons). → Server-side checks on every action.
- **Trusting client-sent user IDs, roles or tenant IDs.** → Derive from the session.
- **Secrets committed to git or exposed in frontend env vars.**
- **Database/Redis port open to the internet.**
- **No rate limiting on login/OTP/AI endpoints.**
- **Admins without MFA.**

## Operations
- **No backups, or backups never restored.** → Automated, offsite, encrypted, tested monthly.
- **VPS snapshots as the only backup.**
- **Backups on the same server/provider/account as production only.**
- **Deploying by SSH-ing and editing files on the server.** → CI/CD with Docker images.
- **No monitoring until users complain.** → Sentry + uptime + disk alerts from day one.
- **Logging secrets/PII.**
- **`latest` tags everywhere** (images, actions) leading to surprise breakage. → Pin versions; update deliberately with Renovate.
- **Single person holds all access** (bus factor 1). → Shared password manager/secret manager, documented runbooks.

## Frontend
- **SPA for a marketing site** (slow, poor SEO). → Astro/static or SSR.
- **Global state library for everything.** → Server state in TanStack Query, local state locally.
- **Giant UI kits + custom CSS fighting each other.** → One styling system.
- **Ignoring mobile, accessibility, RTL** until late. → Bake in from the start if needed.
- **Shipping huge bundles** (moment.js, full lodash, unoptimized images).

## Process and cost
- **Premature optimization for millions of users** with zero users. → Ship, measure, then scale.
- **No cost tracking** for AI, SMS, bandwidth, logs. → Budgets and alerts.
- **Vendor free tiers as production foundations** without checking limits and pricing at 10x.
- **No README/RESTORE.md/CLAUDE.md** — future you (or the AI assistant) can't reconstruct decisions. → Keep the Stack Decision Record in the repo (`docs/adr/` or `STACK.md`).
- **Choosing a stack the team can't maintain** after the original developer leaves.
