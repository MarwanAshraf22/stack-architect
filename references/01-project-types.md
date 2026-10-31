# Project Types Catalog

> Last reviewed: October 2026. Each archetype lists signals, the recommended stack, alternatives and gotchas. Combine archetypes for hybrid projects.

## Table of contents
1. Landing page / marketing site
2. Blog, docs, content site
3. Portfolio / personal site
4. Web app with login (B2C SaaS, portals)
5. Multi-tenant B2B SaaS
6. Internal admin / back-office tool
7. Dashboards and BI
8. E-commerce store
9. Marketplace (two-sided)
10. Booking / scheduling system
11. LMS / education platform
12. Social network / community
13. Realtime chat / messaging
14. Collaborative editor / whiteboard
15. Public API / developer platform
16. Mobile app
17. Desktop app
18. Browser extension
19. CLI tool
20. Chat bots (Telegram, Discord, WhatsApp, Slack)
21. LLM / AI assistant / RAG app
22. AI agents and automation
23. Data pipeline / ETL / warehouse
24. ML model training and serving
25. Forecasting / time series system
26. IoT / telemetry platform
27. Embedded / firmware
28. Games
29. Fintech / payments / regulated apps
30. Government / enterprise / on-prem
31. High-scale consumer platform
32. Workflow automation / integrations
33. Hackathon / MVP / prototype

---

## 1. Landing page / marketing site
**Signals:** one or a few pages, no login, SEO and speed matter, content changes occasionally.
**Stack:** Astro + Tailwind, deployed as static files on Cloudflare (Pages or Workers static assets). Forms via a serverless function or a form service. Analytics: Plausible, Umami or Cloudflare Web Analytics.
**Alternatives:** Next.js (static export) if it will grow into an app or the team only knows Next; Framer/Webflow if non-developers edit it.
**Gotchas:** Don't ship a heavy SPA for a static page. Optimize images (AVIF/WebP), fonts (self-host, subset), and keep JS minimal. Lighthouse 95+ should be the norm.

## 2. Blog, docs, content site
**Signals:** many pages of text, MDX, search, versioning (docs).
**Stack:** Astro (+ Starlight for docs) with MDX; Pagefind for static search; Cloudflare hosting. Headless CMS if non-devs write: Payload, Sanity, Keystatic (git-based), or Decap.
**Alternatives:** Docusaurus (React docs), VitePress (Vue docs), Mintlify (hosted docs), Ghost (newsletter-centric blog).
**Gotchas:** RSS, sitemap, OG images, canonical URLs. Plan i18n early if bilingual (Arabic RTL needs `dir="rtl"` and logical CSS properties).

## 3. Portfolio / personal site
**Stack:** Astro or Next.js, static, Cloudflare/Vercel. Content in MDX.
**Gotchas:** Keep it fast and simple; showcase projects with real links and screenshots.

## 4. Web app with login (B2C SaaS, customer portals, personal dashboards)
**Signals:** users sign in and see their own pages/data; forms, CRUD, settings, maybe payments.
**Stack:** TanStack Start (or Next.js App Router) + Tailwind + shadcn/ui + TanStack Query/Form + Zod; Postgres + Drizzle; Better Auth (email/password, OAuth, passkeys, 2FA); Redis/Valkey for sessions cache and rate limits; background jobs with pg-boss or BullMQ; Resend for email; R2 for uploads; Stripe for billing. Self-host: VPS + Docker Compose + Caddy + Cloudflare. Managed: Vercel/Netlify + Neon/Supabase Postgres (same region!).
**Alternatives:** React Router 7 (framework mode), SvelteKit, Nuxt, Laravel (+ Inertia), Rails 8, Django + HTMX — all excellent if the team knows them.
**Gotchas:** Protect every server function/route with an auth check, not just the UI. Validate input server-side. Add rate limiting on auth endpoints. Plan email verification and password reset on day one.

## 5. Multi-tenant B2B SaaS
**Signals:** companies sign up, invite teammates, roles, per-org billing, SSO requests from big customers.
**Stack:** As #4, plus: organizations/teams model (Better Auth organization plugin, or WorkOS/Clerk orgs), RBAC, tenant isolation via `tenant_id` on every row + Postgres row-level security as defense in depth, audit log table, Stripe subscriptions with per-seat or usage pricing, SAML/OIDC SSO (WorkOS, Better Auth SSO plugin, or Keycloak/Zitadel).
**Tenancy models:** shared DB + tenant_id (default, cheapest), schema-per-tenant (medium), DB-per-tenant (strong isolation, regulated customers; Neon/Turso make this cheaper).
**Gotchas:** Every query must be tenant-scoped; enforce in a data-access layer, not by memory. Build an admin "impersonate user" tool with audit logging. Export/delete account data (GDPR/PDPL).

## 6. Internal admin / back-office tool
**Signals:** staff only, CRUD over business data, tables, filters, approvals.
**Stack:** If speed matters most: Refine or React Admin on top of your API; or Retool/Appsmith/Budibase/ToolJet (low-code). Python teams: Django admin, or Streamlit for data-heavy tools. Auth via company SSO (Microsoft Entra ID / Google Workspace) using OIDC.
**Gotchas:** Internal tools still need auth, audit logs and least-privilege DB credentials. Put them behind SSO or a zero-trust tunnel (Cloudflare Access/Tailscale).

## 7. Dashboards and BI
**Signals:** charts, KPIs, filters, scheduled reports.
**Stack:** For business users in a Microsoft org: Power BI. Open source: Metabase (easiest), Apache Superset (powerful), Evidence (BI as code), Grafana (operational/time series). Custom embedded dashboards: React + ECharts/Recharts/visx, data served from Postgres materialized views or ClickHouse.
**Gotchas:** Pre-aggregate; never run heavy analytics queries on the production OLTP database at peak — use a read replica, materialized views or a separate analytics store.

## 8. E-commerce store
**Signals:** catalog, cart, checkout, inventory, shipping, taxes.
**Stack:** Most cases: Shopify (hosted, fastest) with optional headless frontend (Hydrogen or Next.js). Custom/open source: Medusa (TS) or Saleor (Python/GraphQL) + Postgres + Stripe (or regional gateways). Small catalogs: Astro + Stripe Checkout / Lemon Squeezy.
**Gotchas:** PCI scope — never touch raw card data; use hosted checkout or Elements. Taxes/VAT (UAE VAT 5%), multi-currency, regional payment methods. Search (Meilisearch/Typesense/Algolia) matters for conversion.

## 9. Marketplace (two-sided)
**Stack:** Web app stack (#4/#5) + Stripe Connect for split payments/payouts, search engine (Meilisearch/Typesense/OpenSearch), messaging between parties, reviews, moderation queue, admin tools.
**Gotchas:** Payments compliance (KYC) is the hard part — use Connect. Trust & safety tooling early.

## 10. Booking / scheduling system
**Stack:** Web app stack + careful time handling (store UTC `timestamptz`, display in user TZ with Temporal API or date-fns-tz), Postgres exclusion constraints (`tstzrange` + `EXCLUDE USING gist`) to prevent double-booking, calendar sync (Google/Microsoft Graph APIs, ICS), reminders via job queue + email/SMS/WhatsApp. Consider Cal.com (open source) if requirements match.
**Gotchas:** Time zones and DST, concurrency on the same slot, no-shows, cancellations/refunds.

## 11. LMS / education platform
**Stack:** Web app stack + video via Mux, Cloudflare Stream or Bunny Stream; progress tracking in Postgres; quizzes; certificates (PDF generation); payments. Off-the-shelf: Moodle (PHP), Open edX if requirements are standard.
**Gotchas:** Video costs dominate — choose a video platform with transparent pricing; signed URLs to prevent leeching.

## 12. Social network / community
**Stack:** Web + mobile (Expo) on a TS API; Postgres (posts, follows) + Redis (feeds, counters, rate limits); object storage + image CDN; search; notifications (push + email) via job queue; moderation (automated + human queue). Off-the-shelf community: Discourse, Circle.
**Gotchas:** Feed generation (fan-out on write vs read), spam/abuse, content moderation, privacy controls.

## 13. Realtime chat / messaging
**Stack:** See `11-realtime.md`. Small/medium: WebSockets via Socket.IO or a managed service (Ably, Pusher, Stream); Postgres for history; Redis pub/sub for multiple servers. High concurrency: Elixir/Phoenix Channels or Cloudflare Durable Objects. Chat-as-a-service: Stream Chat, Sendbird.
**Gotchas:** Presence, read receipts, ordering, offline delivery, push notifications, E2E encryption needs (Signal protocol libraries) if private messaging.

## 14. Collaborative editor / whiteboard
**Stack:** CRDTs with Yjs (or Automerge/Loro); editors: Tiptap/ProseMirror, Lexical, BlockNote; canvases: tldraw, Excalidraw; sync via Liveblocks (managed), Hocuspocus (self-host) or PartyKit/Durable Objects. Persist snapshots in Postgres/R2.
**Gotchas:** Don't build CRDTs yourself. Plan permissions per document and version history.

## 15. Public API / developer platform
**Stack:** Hono (TS) or FastAPI (Python) or Go; OpenAPI spec as source of truth (generate SDKs with Speakeasy/Stainless/openapi-generator); API keys hashed in DB; rate limiting (Redis or Cloudflare); usage metering; docs via Scalar/Mintlify/Redoc; versioning in URL or header.
**Gotchas:** Idempotency keys for POST, pagination (cursor-based), consistent errors (RFC 9457 problem+json), webhooks with signatures and retries.

## 16. Mobile app
See `09-mobile-desktop-other.md`. Default: Expo (React Native) + TypeScript API. Flutter if the team is Dart-first or needs pixel-identical custom UI. Native Swift/Kotlin for heavy platform-specific features (AR, advanced camera, widgets-first apps).

## 17. Desktop app
Default: Tauri (Rust core, web UI, small binaries). Electron when you need Node.js APIs, Chromium consistency or a mature plugin ecosystem. Native: SwiftUI (Mac-only), WinUI/.NET MAUI (Windows), Qt (C++/Python, industrial).

## 18. Browser extension
WXT (framework, Manifest V3, cross-browser) + React/Svelte; Plasmo as alternative. Backend only if needed (sync, auth).

## 19. CLI tool
Go (Cobra) or Rust (clap) for single-binary distribution; Python (Typer + uv) or Node (commander/citty) for internal/dev tools. Distribute via Homebrew, npm, PyPI (uvx/pipx), GitHub Releases with GoReleaser/cargo-dist.

## 20. Chat bots
Telegram: grammY (TS) or aiogram/python-telegram-bot. Discord: discord.js or discord.py. Slack: Bolt. WhatsApp: official Cloud API (Meta) via a BSP or direct. Webhooks over polling in production. Postgres for state; VPS or serverless (Cloudflare Workers works well for webhook bots).

## 21. LLM / AI assistant / RAG app
See `10-data-ai.md`. Default: TS (TanStack Start/Next.js + Vercel AI SDK) or Python (FastAPI) + provider SDK; Postgres + pgvector; document parsing pipeline; streaming UI; evals; cost tracking per user.

## 22. AI agents and automation
Provider SDKs with tool calling, or agent frameworks (Claude Agent SDK, OpenAI Agents SDK, LangGraph, Mastra for TS). MCP servers to expose tools. Durable execution for long tasks (Temporal, Inngest, Trigger.dev). Human-in-the-loop approvals for risky actions.

## 23. Data pipeline / ETL / warehouse
Python; ingestion with dlt or Airbyte; transforms with dbt or SQLMesh; orchestration with Dagster (default), Prefect or Airflow; storage: Postgres (small), DuckDB/MotherDuck (medium, analytical), ClickHouse, BigQuery, Snowflake or Databricks (large/enterprise). Parquet on object storage as the lake format (Iceberg/Delta for tables).

## 24. ML model training and serving
Python; PyTorch; scikit-learn/LightGBM/XGBoost for tabular; MLflow or Weights & Biases for tracking; serving via FastAPI, BentoML or Ray Serve; GPUs on Modal, RunPod, Lambda, or cloud providers; ONNX for portable inference.

## 25. Forecasting / time series system
Python; Polars/pandas; Nixtla statsforecast/mlforecast/neuralforecast, LightGBM with lag features, Prophet for quick baselines; backtesting with rolling-origin CV; store in Postgres + TimescaleDB or ClickHouse; Dagster/Prefect for scheduled retraining; serve forecasts via API or write to tables consumed by BI (Power BI/Metabase).
**Gotchas:** Holidays/events (Ramadan, Eid, school calendars, weather) as features; hierarchical reconciliation; monitor drift.

## 26. IoT / telemetry platform
Devices → MQTT broker (EMQX, Mosquitto, HiveMQ) → ingestion service → TimescaleDB or ClickHouse (or InfluxDB) → Grafana dashboards. Device management/OTA (Mender, balena, ESP-IDF OTA). Edge: Node-RED for quick flows.
**Gotchas:** Device auth (per-device certs), backpressure, retention/downsampling policies.

## 27. Embedded / firmware
ESP32: ESP-IDF (C) or Arduino for prototypes; Rust via esp-rs. MCUs: Zephyr RTOS or FreeRTOS; STM32CubeIDE. Linux SBCs (Raspberry Pi): Python/Go. PlatformIO as build tool. Communication: MQTT, BLE, LoRaWAN.
**Gotchas:** Power budget, OTA safety (A/B partitions), secure boot, watchdogs.

## 28. Games
Web 2D: Phaser, PixiJS; web 3D: Three.js / React Three Fiber, Babylon.js. Engines: Godot (open source, default for indie), Unity (mobile/most tutorials), Unreal (high-end 3D). Multiplayer: Colyseus, Nakama, or authoritative servers; Durable Objects for small web games.

## 29. Fintech / payments / regulated apps
Strong typing (TS/Kotlin/Go/Java), Postgres with strict constraints, double-entry ledger tables (never update balances in place — append entries), idempotency everywhere, audit logs, encryption at rest and in transit, KMS for keys, regulated cloud regions. Use licensed partners (Stripe, Adyen, Checkout.com, local banks/BaaS) rather than holding funds yourself.

## 30. Government / enterprise / on-prem
Expect: SSO with Microsoft Entra ID/ADFS, data residency (in-country cloud regions or on-prem), approved stacks (often .NET, Java/Spring, Oracle/SQL Server, Power Platform), security reviews, accessibility (WCAG 2.2 AA), Arabic/English bilingual. Containerize everything (Docker) so it runs on-prem or on OpenShift/Kubernetes. Prefer the organization's existing data platform (Dataiku, Databricks, Azure, etc.) to inherit governance.

## 31. High-scale consumer platform
Start as a modular monolith; extract services only at proven bottlenecks. Postgres with read replicas and partitioning, Redis, CDN everywhere, queues (SQS/Kafka/Redpanda), search cluster, Kubernetes once team and traffic justify it, multi-region later. Observability with OpenTelemetry.

## 32. Workflow automation / integrations
n8n (self-hostable), Zapier/Make (no-code), Windmill (scripts + UIs), Temporal/Inngest/Trigger.dev for code-first durable workflows. Webhooks with signature verification and retries.

## 33. Hackathon / MVP / prototype
Optimize for speed: Next.js or TanStack Start + Supabase (DB + auth + storage) or Convex; shadcn/ui; Vercel deploy; AI features via provider SDK. Python demos: Streamlit or Gradio. Write down what to rebuild if it survives (auth, data model, tests).
