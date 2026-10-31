# Data Layer: Databases, ORMs, Cache, Search, Vectors, Queues

> Last reviewed: October 2026.

## Table of contents
1. Picking the primary database
2. PostgreSQL deep dive (default)
3. Other databases and when they win
4. Managed vs self-hosted
5. ORMs and query builders
6. Migrations and schema rules
7. Making the database fast
8. Caching
9. Search
10. Vector search
11. Analytics, time series, OLAP
12. Object/file storage
13. Data modeling rules

---

## 1. Picking the primary database

| Data / need | Choose |
|---|---|
| Almost anything relational (users, orders, bookings) | **PostgreSQL** |
| Single-server app, embedded, mobile/desktop local, edge read replicas | **SQLite** (with Litestream/LiteFS), Turso/libSQL |
| Existing MySQL skills/hosting, WordPress/Laravel shops | MySQL / MariaDB |
| Truly document-shaped, schema varies per record, no joins | MongoDB (or Postgres JSONB first) |
| Microsoft enterprise | SQL Server / Azure SQL |
| Huge write throughput, globally distributed, always-on | CockroachDB, YugabyteDB, Cassandra/ScyllaDB, DynamoDB |
| Realtime app with reactive queries, small team | Convex, Supabase (Postgres + realtime), Firebase (Firestore) |
| Analytics over billions of rows | ClickHouse, BigQuery, Snowflake, DuckDB (local) |
| Time series metrics | TimescaleDB (Postgres extension), ClickHouse, InfluxDB |
| Graph traversals central to the product | Neo4j, Memgraph (or Postgres recursive CTEs / Apache AGE first) |
| Key-value cache, sessions, rate limits | Redis / Valkey / Dragonfly |

**Default: PostgreSQL.** Only move away when a requirement clearly breaks it.

## 2. PostgreSQL deep dive (default)
- Use a recent major version (17 or 18) — check current release.
- Useful extensions: `pgvector` (embeddings), `pg_trgm` (fuzzy search), `pg_stat_statements` (query stats — always enable), `TimescaleDB` (time series), `PostGIS` (geospatial), `pg_cron` (scheduled jobs), `citext` (case-insensitive email), `uuid` generation built-in (`gen_random_uuid()`, UUIDv7 in newer versions/libs).
- **IDs:** UUIDv7 (time-ordered, index-friendly, safe to expose) or bigint identity internally + public UUID/ULID. Avoid random UUIDv4 as clustered primary keys in very large tables.
- **Types:** `timestamptz` (never `timestamp` without TZ), `numeric` for money (or integer minor units), `text` over `varchar(n)`, `jsonb` for flexible attributes, enums or lookup tables for statuses.
- **Constraints:** NOT NULL, foreign keys, unique, CHECK, exclusion constraints — let the DB enforce integrity.
- **Row-level security (RLS):** defense-in-depth for multi-tenant apps.
- **Connection pooling:** PgBouncer (transaction mode) or built-in pooling of managed providers; Supavisor (Supabase); size app pools so total < `max_connections`.
- **Config tuning (self-hosted):** shared_buffers ~25% RAM, effective_cache_size ~70% RAM, work_mem modest, use PGTune as a starting point.
- **Run it:** Docker official image for dev; on a VPS use Docker with a named volume or native packages; consider managed for production if you don't want to handle upgrades, HA and PITR.

## 3. Other databases and when they win
- **SQLite:** blazing fast (in-process, no network), zero ops. Great for single-server apps, read-heavy sites, local-first, prototypes, per-tenant DBs. Use WAL mode; back up with Litestream to S3/R2. Limits: one writer at a time, single machine (unless LiteFS/Turso).
- **MySQL/MariaDB:** solid; PlanetScale (Vitess) for massive scale. Fewer advanced features than Postgres.
- **MongoDB:** flexible docs, good for event/log-like or highly variable schemas; weak for relational integrity and multi-document transactions are costlier.
- **DynamoDB:** serverless KV/document on AWS at any scale; requires upfront access-pattern design (single-table design). Hard to query ad hoc.
- **Convex:** TS-native reactive backend (DB + functions + realtime). Superb DX for realtime apps; vendor-specific.
- **Firebase/Firestore:** fast prototyping, offline mobile sync; costs and querying limits at scale; lock-in.
- **Supabase:** managed Postgres + auth + storage + realtime + edge functions; you keep standard Postgres, so lower lock-in than Firebase.

## 4. Managed vs self-hosted

| Option | Pros | Cons |
|---|---|---|
| Postgres on same VPS as app | Lowest latency (~1 ms), cheapest, full control | You own backups, upgrades, HA, security |
| Separate DB VPS in same datacenter (private network) | Isolation, still low latency | More ops |
| Managed: Neon (serverless, branching), Supabase, AWS RDS/Aurora, Google Cloud SQL/AlloyDB, Azure Database for PostgreSQL, DigitalOcean Managed, Crunchy Bridge, Xata, PlanetScale Postgres | Backups, PITR, HA, upgrades handled | Cost, network latency — **must be same region as app** |

Rule: if self-hosting, backups with PITR are mandatory (see `07-backups-dr.md`). If the team has no ops time, use managed in the same region as the app.

## 5. ORMs and query builders

| Language | Default | Alternatives |
|---|---|---|
| TypeScript | **Drizzle** (SQL-like, lightweight, great types, works on edge) | Prisma (mature, great DX, schema file), Kysely (type-safe query builder), MikroORM, TypeORM (legacy) |
| Python | **SQLAlchemy 2 + Alembic** | SQLModel (FastAPI-friendly), Django ORM (with Django), Tortoise, Piccolo; raw psycopg 3 |
| Go | **sqlc** (+ pgx) | GORM, Ent, Bun, sqlx |
| Rust | **SQLx** | SeaORM, Diesel |
| Java/Kotlin | Spring Data JPA / Hibernate | jOOQ, Exposed (Kotlin) |
| .NET | **EF Core** | Dapper |
| Ruby | ActiveRecord | Sequel |
| PHP | Eloquent | Doctrine |
| Elixir | Ecto | — |

Rules: learn the SQL your ORM generates; use raw SQL for complex reports; avoid ORM-generated N+1 queries.

## 6. Migrations and schema rules
- Every schema change is a versioned migration in git (Drizzle Kit, Prisma Migrate, Alembic, Atlas, Flyway, Liquibase, goose, dbmate).
- Migrations run automatically in CI/CD before the new app version starts.
- Zero-downtime pattern (expand → migrate → contract): add new column nullable, backfill, switch code, then drop old.
- Create indexes `CONCURRENTLY` on big tables. Never long locks in peak hours.
- Seed scripts for dev; never copy production data to dev without anonymization.

## 7. Making the database fast
Ordered by impact:
1. **Colocate** — app and DB in the same server/datacenter/region. Every query crossing regions adds 20–200 ms.
2. **Indexes** — on foreign keys, columns in WHERE/JOIN/ORDER BY; composite indexes matching query patterns; partial indexes (`WHERE deleted_at IS NULL`); GIN for jsonb/full-text; check with `EXPLAIN (ANALYZE, BUFFERS)`.
3. **Query hygiene** — select only needed columns, avoid N+1, paginate with keyset (cursor) not huge OFFSET, batch writes.
4. **Find slow queries** — `pg_stat_statements`, slow query log (`log_min_duration_statement`), PgHero, pganalyze.
5. **Connection pooling** — PgBouncer; reuse connections; serverless needs HTTP/pooling drivers.
6. **Caching** — Redis/Valkey for hot reads; HTTP/CDN caching for public data.
7. **Materialized views / summary tables** for dashboards and heavy aggregates.
8. **Hardware** — enough RAM to hold the working set; NVMe SSD.
9. **Read replicas** — when reads dominate and one server is saturated.
10. **Partitioning** — very large time-based tables (events, logs).
11. **Specialized stores** — ClickHouse for analytics, search engine for search, only when Postgres measurably can't keep up.

## 8. Caching
- **Redis-compatible:** Valkey (open-source fork, default for self-host), Redis (8+ is open source again under AGPL option — check license fit), Dragonfly (multi-threaded, high throughput), KeyDB. Managed: Upstash (serverless, HTTP), AWS ElastiCache, Redis Cloud.
- **Patterns:** cache-aside with TTL; invalidate on write; key namespacing (`user:{id}:profile`); avoid caching per-user data publicly.
- **Other uses:** sessions, rate limiting (sliding window), distributed locks, leaderboards (sorted sets), pub/sub, BullMQ queues.
- **HTTP caching:** `Cache-Control`, `stale-while-revalidate`, Cloudflare cache rules for public pages and API responses.
- **In-process caching:** LRU for tiny hot data (beware multiple instances).
- Don't add Redis until you have a reason; Postgres alone handles a lot.

## 9. Search
1. Postgres full-text search (`tsvector` + GIN) + `pg_trgm` for typos — enough for many apps. ParadeDB (pg_search) adds BM25 inside Postgres.
2. **Meilisearch** or **Typesense** — instant, typo-tolerant search, easy self-host. Default dedicated engine.
3. **OpenSearch / Elasticsearch** — logs, complex aggregations, very large datasets.
4. **Algolia** — hosted, excellent, pricey at scale.
5. Static sites: Pagefind.
Arabic: check tokenizer/stemming support and test with real queries.

## 10. Vector search
- **pgvector** (with HNSW indexes) inside Postgres — default; keeps vectors next to relational data and permissions. pgvectorscale for larger datasets.
- Dedicated: Qdrant (default dedicated, self-host or cloud), Weaviate, Milvus, Pinecone (managed), Chroma (prototypes), LanceDB (embedded), Turbopuffer (cheap at scale).
- Hybrid search (keyword + vector) with reranking gives the best RAG retrieval.

## 11. Analytics, time series, OLAP
- **TimescaleDB:** time series inside Postgres (hypertables, compression, continuous aggregates).
- **ClickHouse:** blazing fast OLAP for events/logs/analytics; self-host or ClickHouse Cloud.
- **DuckDB:** in-process analytics on Parquet/CSV; MotherDuck for cloud.
- **Warehouses:** BigQuery, Snowflake, Databricks, Redshift for enterprise scale.
- **Product analytics:** PostHog (self-host or cloud), or events into ClickHouse.
- Pattern: OLTP (Postgres) → CDC/ETL → OLAP (ClickHouse/warehouse) for dashboards; never hammer production with BI queries.

## 12. Object/file storage
- **Cloudflare R2** (default; S3 API, zero egress), AWS S3, Backblaze B2 (cheap), Google Cloud Storage, Azure Blob, MinIO/Garage/SeaweedFS (self-host S3-compatible).
- Upload directly from browser with presigned URLs; never stream large uploads through the app server.
- Store only the object key + metadata in Postgres.
- Private files via signed, expiring URLs. Enable versioning/lifecycle rules.
- Images: transform via Cloudflare Images, imgproxy, Thumbor, or Bunny Optimizer.

## 13. Data modeling rules
- Model the domain first (entities, relationships, invariants), then tables.
- Normalize by default; denormalize deliberately for read performance with clear ownership.
- `created_at`, `updated_at` on every table; soft delete only where business needs it.
- Audit log table for sensitive changes (who, what, when, before/after).
- Money: integer minor units + currency code. Never floats.
- Time: store UTC `timestamptz`; store user timezone separately.
- Personal data: know where PII lives; plan deletion/export (GDPR, UAE PDPL).
- Multi-tenant: `tenant_id` on every tenant-owned table, indexed, included in unique constraints.
