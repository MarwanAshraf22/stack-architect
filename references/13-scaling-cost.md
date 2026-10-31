# Scaling Path, Performance and Cost

> Last reviewed: October 2026. Numbers are rough orders of magnitude; measure your own workload.

## Table of contents
1. How far one server goes
2. Scaling stages
3. Performance checklist
4. Load testing
5. Cost model by stage
6. Cost traps
7. When to switch architecture

---

## 1. How far one server goes
A well-built monolith on one modern VPS (4–8 vCPU, 16–32 GB RAM, NVMe) with Postgres on the same machine, indexes and caching typically handles:
- Thousands of requests per second for cached/simple reads.
- Hundreds of requests per second for typical DB-backed pages.
- Tens of thousands of daily active users for most SaaS/CRUD apps.
- Databases of hundreds of GB.
Most products never outgrow this. Scale vertically (bigger server) before horizontally.

## 2. Scaling stages

| Stage | Signals | Changes |
|---|---|---|
| 0. Prototype | < 100 users | Single server or PaaS free tier; SQLite or Postgres |
| 1. Launch | 100–10k users | One VPS (app + Postgres + Redis), Cloudflare CDN, backups with PITR, monitoring |
| 2. Growth | CPU/RAM sustained > 60–70%, slow queries | Bigger VPS; move Postgres to its own server (private network) or managed; add Redis caching; background workers on separate process; read-heavy pages cached at edge |
| 3. Scale-out | One app server not enough, need HA | 2+ app servers behind load balancer (Cloudflare LB, HAProxy, provider LB); stateless app (sessions in DB/Redis, files in object storage); Postgres primary + replica with automated failover (Patroni/managed); PgBouncer |
| 4. Large | Millions of users, many teams | Read replicas, table partitioning, dedicated search/analytics stores, queues/streams, CDN for APIs, possibly Kubernetes, extract services at real bottlenecks |
| 5. Global | Users worldwide with latency needs, regulatory regions | Multi-region read replicas, edge compute, regional data residency, distributed SQL (CockroachDB/Yugabyte/Spanner/Aurora DSQL) if writes must be global |

Prepare early (cheap now, expensive later): stateless app servers, files in object storage, sessions in DB/Redis, background jobs in a queue, migrations as code, config via env vars, everything in Docker.

## 3. Performance checklist
**Backend/DB**
- Colocate app and DB; same region as users.
- Indexes for every frequent query; check `pg_stat_statements` weekly.
- No N+1; batch and join.
- Connection pooling.
- Cache expensive, frequently read data with TTLs.
- Move slow work to background jobs.
- Paginate everything; cap result sizes.
- Compress responses (zstd/brotli/gzip).
- Use HTTP/2 or HTTP/3 (Cloudflare handles).

**Frontend**
- SSR/streaming for first paint; static for public pages.
- Code split per route; lazy-load heavy components (charts, editors, maps).
- Optimize images and fonts; set dimensions.
- Prefetch routes on intent.
- Avoid layout shift; measure Core Web Vitals with real-user monitoring.

**Network**
- CDN cache static assets with immutable hashes.
- Edge caching for public API responses where safe.
- Keep payloads small (select fields, avoid over-fetching).

## 4. Load testing
- Tools: k6 (default, JS scripts), Grafana k6 Cloud, Artillery, Locust (Python), oha/hey/wrk (quick HTTP benchmarks).
- Test realistic flows (login → browse → write), not just one endpoint.
- Watch p95/p99 latency, error rate, DB CPU and connections, memory.
- Find the breaking point before customers do; re-test after major changes.

## 5. Cost model by stage (rough USD/month)

| Stage | Self-host (VPS) | Managed/serverless |
|---|---|---|
| Prototype | $0–10 (small VPS or free tiers) | $0 (free tiers: Vercel/Cloudflare/Neon/Supabase) |
| Launch | $10–60 (1 VPS + R2 + email + domain) | $50–200 (Vercel Pro + managed DB + auth service) |
| Growth | $60–400 (2–3 servers, managed backups) | $300–2,000+ |
| Scale-out | $400–3,000 | $2,000–20,000+ |

Typical line items: compute, database, storage + egress, CDN, email volume, auth per-MAU (if hosted), monitoring (per GB/events), AI tokens, SMS (expensive), video streaming, payments fees (~2.9% + fixed in many regions), domain, Apple/Google developer accounts.

Track cost per active user and per feature (especially AI) from day one.

## 6. Cost traps
- Egress/bandwidth fees on AWS/GCP/Azure and some PaaS — prefer R2/Cloudflare for public assets.
- Serverless function duration and invocations at scale (AI streaming holds functions open).
- Hosted auth per-MAU pricing at consumer scale.
- Observability ingestion (logs/traces) growing unchecked — sample and set retention.
- Managed database storage/IOPS and cross-region replicas.
- AI API costs from unbounded prompts, agents looping, or abuse — enforce limits.
- SMS OTP pumping fraud — rate limit and use bot protection.
- Idle staging/preview environments and forgotten resources — tag and review monthly.
- NAT gateways and load balancers on big clouds (fixed hourly costs).

## 7. When to switch architecture
Change only when a measured problem requires it:
- **Add caching** when the same expensive reads dominate DB load.
- **Add a read replica** when reads saturate the primary after query optimization.
- **Dedicated search engine** when Postgres FTS is too slow or lacks needed relevance features.
- **Analytics store (ClickHouse/warehouse)** when reporting queries hurt OLTP performance.
- **Message queue/stream** when async work volume or fan-out exceeds the DB-backed queue.
- **Split a service** when one module needs different scaling, language or release cadence, or a separate team owns it.
- **Kubernetes** when you run many services and have people to operate it.
- **Multi-region** when latency or regulation demands it and the business can fund the complexity.
