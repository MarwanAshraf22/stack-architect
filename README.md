# Stack Architect

**A Claude skill that chooses the right tech stack before you write a single line of code.**

Tell Claude what you want to build — a landing page, a SaaS, a mobile app, an AI chatbot, a data pipeline, an IoT system — and Stack Architect asks the few questions that matter, then produces a complete **Stack Decision Record**: frontend, backend, database, ORM, cache, auth, hosting, CI/CD, backups, monitoring, security, payments, email, storage, cost and scaling path, each with a reason and an alternative.

## Why

The most expensive mistakes in software happen before coding starts: the wrong database, hand-rolled auth, a database in a different region from the app, no backups, Kubernetes for a single app. This skill encodes opinionated, current best practices so every project starts on the right foundation.

## What's inside

```
stack-architect/
├── SKILL.md                          # Workflow Claude follows
├── references/
│   ├── 00-house-defaults.md          # ← YOUR preferred stacks (edit this!)
│   ├── 01-project-types.md           # 33 archetypes → recommended stacks
│   ├── 02-frontend.md                # Rendering, frameworks, UI, state, a11y, RTL
│   ├── 03-backend.md                 # Languages, frameworks, API styles, jobs
│   ├── 04-data-layer.md              # Databases, ORMs, speed, cache, search, vectors
│   ├── 05-auth.md                    # Authentication, authorization, SSO
│   ├── 06-deployment.md              # Hosting tiers, VPS, Cloudflare, CI/CD, IaC
│   ├── 07-backups-dr.md              # RPO/RTO, 3-2-1, PITR, restore tests
│   ├── 08-observability-security.md  # Monitoring, OWASP, hardening, compliance
│   ├── 09-mobile-desktop-other.md    # Expo, Flutter, Tauri, extensions, CLIs
│   ├── 10-data-ai.md                 # Data eng, BI, ML, forecasting, LLM, RAG, agents
│   ├── 11-realtime.md                # SSE, WebSockets, CRDTs, sync engines, notifications
│   ├── 12-supporting-services.md     # Payments, email, media, CMS, maps, i18n, PDFs
│   ├── 13-scaling-cost.md            # Scaling stages, performance, cost traps
│   └── 14-anti-patterns.md           # Mistakes to catch early
├── assets/
│   └── stack-decision-record.md      # Output template
└── scripts/
    └── check_versions.sh             # Latest npm/PyPI versions for freshness checks
```

## Install

**Claude.ai / Claude apps:** download the packaged `.skill` (or zip the `stack-architect` folder) and upload it in Claude's skills settings.

**Claude Code (all projects):**
```bash
git clone https://github.com/MarwanAshraf22/stack-architect.git ~/.claude/skills/stack-architect
```

**Claude Code (one project):** copy the folder to `.claude/skills/stack-architect/` in the repo.

## Use

Just describe the project:

> I want to build a booking system for a car wash with customer accounts, payments and WhatsApp reminders.

> What stack should I use for an internal dashboard that forecasts ridership?

> Landing page for my freelance services, fast and bilingual Arabic/English.

Claude will ask only what it needs, then deliver the Stack Decision Record. Say "scaffold it" to get init commands, Dockerfile, docker-compose, Caddyfile, CI workflow, `.env.example` and a backup script.

## Make it yours

Edit `references/00-house-defaults.md`. That file holds the preferred stack for each project type (e.g., "web app with login → TanStack Start + Postgres + Drizzle + Better Auth + VPS + Cloudflare"). The skill applies your defaults first and explains whenever a project needs something different.

## Keep it fresh

Each reference file has a "Last reviewed" date. The skill checks versions before recommending (`scripts/check_versions.sh @tanstack/react-start drizzle-orm pypi:fastapi`) and flags anything it couldn't verify. PRs updating recommendations are welcome — please include the reason and a source.

## Principles

1. Boring by default, novel on purpose
2. Fit the project, not the hype
3. One language where possible
4. Postgres unless proven otherwise
5. Speed comes from locality
6. Match operations to the team
7. No premature scale
8. Data safety is non-negotiable
9. Prefer reversible choices
10. Verify freshness

## License

MIT
