# Stack Architect

**Stop picking your tech stack from Twitter threads. Let Claude choose it with you, layer by layer, with reasons.**

A Claude skill that asks the few questions that matter, then hands you a complete **Stack Decision Record**: frontend, backend, database, ORM, cache, auth, hosting, CI/CD, backups, monitoring, security, payments, email, storage, cost and scaling path, each with a reason and an alternative.

<p align="center">
  <img src="docs/demo.svg" alt="Stack Architect demo: Claude asks two questions, then produces a full stack decision record" width="820">
</p>

## See real outputs

| Project | What Claude produced |
|---|---|
| Booking SaaS with staff logins, payments and WhatsApp reminders | [Full decision record →](examples/01-saas-web-app.md) |
| Fast bilingual (Arabic/English) landing page | [Short record →](examples/02-landing-page.md) |
| RAG chatbot over 2,000 internal PDFs with data residency | [Full decision record →](examples/03-ai-rag-chatbot.md) |
| Offline-first mobile + web expense tracker | [Full decision record →](examples/04-mobile-app.md) |

## Why

The most expensive mistakes in software happen before coding starts: the wrong database, hand-rolled auth, a database in a different region from the app, no backups, Kubernetes for a single app. This skill encodes opinionated, current best practices so every project starts on the right foundation, and it tells you *why*, so you learn instead of copying.

## Install

**Claude Code (plugin, recommended):**
```
/plugin marketplace add MarwanAshraf22/stack-architect
/plugin install stack-architect@stack-architect
```

**Claude Code (manual):**
```bash
git clone https://github.com/MarwanAshraf22/stack-architect.git ~/.claude/skills/stack-architect
```

**Claude.ai / Claude apps:** download `stack-architect.skill` from the [latest release](https://github.com/MarwanAshraf22/stack-architect/releases/latest) (or zip this folder) and upload it in Claude's skills settings.

## Use

Just describe what you want to build. No special command needed:

> I want to build a booking system for a car wash with customer accounts, payments and WhatsApp reminders.

> What stack should I use for an internal dashboard that forecasts ridership?

> Landing page for my freelance services, fast and bilingual Arabic/English.

Claude asks only what it needs, then delivers the record. Say **"scaffold it"** to get init commands, Dockerfile, docker-compose, Caddyfile, CI workflow, `.env.example` and a backup script.

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
├── assets/stack-decision-record.md   # Output template
├── scripts/check_versions.sh         # Latest npm/PyPI versions for freshness checks
└── examples/                         # Real decision records
```

## Make it yours

Edit `references/00-house-defaults.md`. It holds the preferred stack for each project type (e.g., "web app with login → TanStack Start + Postgres + Drizzle + Better Auth + VPS + Cloudflare"). The skill applies your defaults first and explains whenever a project needs something different. Fork it and set your team's standards in one file.

## Keep it fresh

Each reference file has a "Last reviewed" date. The skill checks versions before recommending (`scripts/check_versions.sh @tanstack/react-start drizzle-orm pypi:fastapi`) and flags anything it couldn't verify.

## Contributing

Recommendations go stale fast, and your experience makes this better. See [CONTRIBUTING.md](CONTRIBUTING.md): propose a stack change with a reason and a source, add an example record, or improve a reference file. Issues labeled [good first issue](https://github.com/MarwanAshraf22/stack-architect/labels/good%20first%20issue) are a great place to start.

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

If this saved you from a bad stack decision, a ⭐ helps others find it.

## License

MIT
