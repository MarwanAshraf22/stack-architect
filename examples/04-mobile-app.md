# Example: Family Expense Tracker (Mobile + Web)

> **Prompt:** "A private expense tracker for couples: shared budgets, receipt photos, works offline on the phone, also a web dashboard. Just me building it."

---

# Stack Decision Record: Duo Budget

**Date:** 2026-10-31 · **Status:** Proposed

## 1. Summary
A mobile-first app where two people share budgets and expenses, snap receipts, and work offline; a web dashboard shows charts and exports.

**Archetypes:** Mobile app + web app with login + local-first sync.

**Assumptions:** small user base at first (friends and family), iOS + Android, data privacy matters, one developer who knows TypeScript.

## 2. The stack
| Layer | Choice | Why | Alternative (switch if...) |
|---|---|---|---|
| Mobile | Expo (React Native) + Expo Router + NativeWind | One TypeScript codebase for iOS and Android; EAS builds and OTA updates | Flutter if you prefer Dart |
| Web dashboard | TanStack Start + Tailwind + Recharts | Same language, shares types and validation with mobile | Next.js |
| Monorepo | pnpm workspaces + Turborepo (`apps/mobile`, `apps/web`, `packages/db`, `packages/validators`) | Shared Zod schemas and Drizzle types | Separate repos (more duplication) |
| Offline sync | PowerSync (Postgres ↔ SQLite on device) | Proven offline-first sync for mobile with Postgres as source of truth | ElectricSQL or Zero |
| Server database | PostgreSQL + Drizzle | Relational budgets, members, expenses | Supabase (Postgres + auth) for a faster prototype |
| Auth | Better Auth (email + Apple + Google; Expo plugin) | Users in our DB; Sign in with Apple required on iOS when offering Google | Clerk |
| Shared budgets | Household (organization) model with two members, invite by link | Simple, matches couples use case | — |
| Receipt photos | Upload to Cloudflare R2 via presigned URLs; thumbnails with Cloudflare Images | Cheap storage, no egress fees | S3 |
| Money | Integer minor units + currency code | No float rounding errors | — |
| Push | expo-notifications | Budget alerts | OneSignal |
| Hosting | VPS + Docker Compose + Caddy + Cloudflare | Low cost, DB colocated with API | Railway |
| Backups | pgBackRest to R2 + R2 bucket versioning for receipts | Financial data deserves PITR | WAL-G |
| Monitoring | Sentry (React Native + web) | Crash reports from phones | — |
| Store requirements | In-app account deletion, privacy labels, data safety form | App Store and Play rules | — |

## 3. Cost estimate (monthly)
VPS ~$10–20, R2 ~$1, Apple developer account $99/year, Google Play one-time $25, PowerSync free/dev tier to start (check current pricing).

## 4. Scaling path
- **10x:** bigger VPS, PgBouncer.
- **100x:** separate DB server, CDN-cached receipt thumbnails, consider managed Postgres.

## 5. Risks
Sync conflicts when both partners edit the same expense offline → last-write-wins per field plus an edit history table. App review delays → submit early TestFlight builds.

## 6. First-week plan
1. Monorepo scaffold, Drizzle schema, Better Auth on web and Expo.
2. Expenses CRUD online-only.
3. Add PowerSync offline sync.
4. Receipt upload to R2.
5. Web dashboard charts, backups, Sentry, TestFlight build.
