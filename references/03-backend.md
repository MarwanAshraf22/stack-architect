# Backend

> Last reviewed: October 2026.

## Table of contents
1. Do you need a separate backend?
2. Language choice
3. Frameworks by language
4. API styles
5. Architecture patterns
6. Background jobs, scheduling, workflows
7. API design rules
8. Runtime and process management

---

## 1. Do you need a separate backend?
- **No** — if a full-stack framework's server functions/routes cover it (TanStack Start, Next.js, SvelteKit, Nuxt, Laravel, Rails, Django). One deployable, one codebase. Default for most web apps.
- **Yes** — when multiple clients (web + mobile + third parties) consume the same API, when heavy processing (ML, video) needs another language, when teams are split, or when you're shipping a public API.
- **Middle ground** — full-stack app for web, plus a small separate service (e.g., Python FastAPI for ML) called internally.

## 2. Language choice

| Language | Strengths | Pick when |
|---|---|---|
| TypeScript (Node/Bun/Deno) | One language with frontend, huge ecosystem, fast iteration | Default for web apps and APIs |
| Python | Data, ML, AI, scripting, readability | Data/ML/AI products, automation, scientific work |
| Go | Simple, fast, tiny memory, single binaries, great concurrency | High-throughput APIs, infra tools, CLIs, proxies |
| Rust | Max performance and safety | Performance-critical services, systems, WASM, embedded |
| Java / Kotlin | Mature enterprise ecosystem, JVM performance | Enterprise, banks, Android-heavy orgs, large teams |
| C# / .NET | Excellent performance, enterprise tooling, Microsoft integration | Microsoft-centric orgs, government, Windows/Azure |
| PHP (Laravel) | Fastest solo CRUD productivity, cheap hosting | Solo devs/agencies building SaaS/CRUD fast |
| Ruby (Rails 8) | Convention, productivity, "one person framework" | Small teams shipping full-stack fast |
| Elixir (Phoenix) | Massive concurrency, realtime, fault tolerance | Chat, realtime, many persistent connections |

## 3. Frameworks by language

**TypeScript**
- **Hono** — tiny, fast, web-standard; runs on Node, Bun, Deno, Cloudflare Workers, Lambda. Default for standalone TS APIs.
- **Fastify** — mature, fast Node server with plugins and schema validation.
- **NestJS** — Angular-style structured framework (DI, modules); good for large teams/enterprise.
- **Elysia** — Bun-first, very fast, end-to-end types.
- **Express** — legacy default; fine for maintenance, not first choice for new projects.
- **Effect** — powerful typed effects system for complex backends (steeper learning curve).
- **Runtimes:** Node.js LTS (default, safest), Bun (fast installs/runtime, good compatibility), Deno 2 (secure-by-default, npm compatible).

**Python**
- **FastAPI** — default for APIs: async, Pydantic validation, auto OpenAPI docs.
- **Django** (+ Django Ninja or DRF for APIs) — batteries included: ORM, admin, auth, migrations. Best for data-heavy CRUD with admin needs.
- **Litestar** — FastAPI alternative, performance-focused.
- **Flask** — minimal; fine for small services and internal tools.
- Tooling: uv (packages/venvs), Ruff (lint/format), mypy or Pyright (types), pytest.

**Go**
- Standard library `net/http` (enhanced routing since 1.22) + chi; Gin or Echo for familiarity; Huma for OpenAPI-first. Data: sqlc (SQL → typed Go) or pgx; GORM if ORM is preferred.

**Rust**
- Axum (default, Tokio-based), Actix Web, Loco (Rails-like). Data: SQLx, SeaORM, Diesel.

**Java / Kotlin**
- Spring Boot (default enterprise), Quarkus or Micronaut (fast startup, native images), Ktor (Kotlin).

**C# / .NET**
- ASP.NET Core Minimal APIs or controllers; Entity Framework Core; .NET Aspire for local orchestration.

**PHP** — Laravel (+ Livewire or Inertia with React/Vue), Symfony for enterprise.

**Ruby** — Rails 8 (Solid Queue, Solid Cache, Kamal deploy built-in).

**Elixir** — Phoenix + LiveView (realtime UIs without JS frameworks), Ecto.

## 4. API styles

| Style | Use when |
|---|---|
| Server functions (TanStack Start/Next.js) | Single web app, same repo — simplest |
| REST + OpenAPI | Default for public APIs, mobile clients, multiple languages |
| tRPC / oRPC | TS monorepo, frontend and backend together; oRPC also emits OpenAPI |
| GraphQL | Many clients with very different data needs, aggregating many services. Avoid for simple apps (complexity, caching, N+1). Tools: Pothos/GraphQL Yoga, Apollo, Hasura, PostGraphile |
| gRPC / Connect | Service-to-service, high performance, polyglot internals |
| WebSockets / SSE | Realtime push (see `11-realtime.md`) |
| Webhooks | Notifying external systems of events |

## 5. Architecture patterns
- **Modular monolith (default):** one deployable, internal modules with clear boundaries (e.g., `modules/billing`, `modules/users`). Easy to split later.
- **Layering:** routes/handlers → services (business logic) → repositories/data access. Keep business logic out of route handlers.
- **Microservices:** only when independent teams/scaling/deploy cadence demand it. Brings network failures, distributed transactions, observability cost.
- **Event-driven:** outbox pattern (write event to DB in same transaction, publish asynchronously) for reliable events.
- **Serverless functions:** good for spiky, stateless workloads and webhooks; watch cold starts, DB connection limits (use pooling/HTTP drivers), and execution time limits.
- **Hexagonal/clean architecture:** useful in complex domains; overkill for CRUD.

## 6. Background jobs, scheduling, workflows
- **Postgres-backed queues (default for small/medium):** pg-boss, Graphile Worker (TS); Procrastinate, or Django tasks (Python); River (Go); Solid Queue (Rails); Oban (Elixir). No extra infra.
- **Redis-backed:** BullMQ (TS), Celery/RQ/Dramatiq/arq (Python), Sidekiq (Ruby).
- **Durable workflows (multi-step, retries, long-running):** Temporal (self-host or cloud), Inngest, Trigger.dev, Restate, DBOS, Hatchet.
- **Cloud queues:** AWS SQS, Google Pub/Sub, Cloudflare Queues.
- **Event streaming (high volume, replay):** Kafka, Redpanda, NATS JetStream.
- **Cron:** system cron or the queue's scheduler; Cloudflare Cron Triggers; ensure single execution (locks) when running multiple instances.

Rule: anything slow (emails, image processing, AI calls, exports, webhooks out) goes to a job queue, not the request path.

## 7. API design rules
- Validate all input at the boundary (Zod/Pydantic) and return consistent errors (RFC 9457 problem details).
- Cursor-based pagination for lists; limit max page size.
- Idempotency keys on create/payment endpoints.
- Version public APIs (`/v1/`) and never break existing clients silently.
- Rate limit per user/API key/IP.
- Use `timestamptz` and ISO 8601 in UTC across the wire.
- Return only needed fields; avoid N+1 queries (joins, dataloaders).
- Document with OpenAPI; render with Scalar or Redoc.
- Health endpoints: `/healthz` (liveness) and `/readyz` (readiness incl. DB check).
- Graceful shutdown: finish in-flight requests, close DB pools.

## 8. Runtime and process management
- Containerize with multi-stage Dockerfiles; run as non-root; pin base image versions.
- One process per container; scale by replicas.
- Configuration via environment variables validated at startup (t3-env/Zod, pydantic-settings).
- Structured JSON logs to stdout.
- Use connection pools sized to DB limits (see `04-data-layer.md`).
