# Observability and Security

> Last reviewed: October 2026.

## Table of contents
1. Observability minimum
2. Errors and performance
3. Logs
4. Metrics and dashboards
5. Tracing
6. Uptime, alerts, status pages
7. Product analytics
8. Application security
9. Infrastructure security
10. Supply chain security
11. Privacy and compliance
12. Security checklist by stage

---

## 1. Observability minimum (every production app)
- Error tracking with source maps (frontend + backend).
- Structured logs with request IDs.
- Uptime monitoring + alerting to phone/chat.
- Backup heartbeat monitoring.
- Basic server metrics (CPU, RAM, disk, DB connections).
- Disk-space alert (full disks kill databases).

## 2. Errors and performance
- **Sentry** (default; self-hostable, generous free tier) — errors, performance traces, session replay.
- Alternatives: GlitchTip (self-host, Sentry-compatible, lighter), Highlight-style tools, Rollbar, Bugsnag, Honeybadger.
- Tag errors with user ID (not PII), release version, environment.

## 3. Logs
- JSON logs to stdout: pino (Node), structlog/loguru (Python), zap/slog (Go), tracing (Rust), Serilog (.NET).
- Include: timestamp, level, request_id, user_id, route, duration, error stack.
- Never log passwords, tokens, full card numbers or sensitive PII.
- Aggregation: Grafana Loki (self-host), Better Stack Logs, Axiom, Datadog, Elastic/OpenSearch, Grafana Cloud. Small setups: Docker logs + Dozzle viewer.

## 4. Metrics and dashboards
- Prometheus + Grafana (self-host standard); node_exporter, postgres_exporter, cAdvisor.
- Simpler: Netdata, Beszel (lightweight server monitoring), provider dashboards.
- Hosted: Grafana Cloud, Datadog, New Relic (cost scales quickly).
- Track the RED method for services (Rate, Errors, Duration) and USE for resources (Utilization, Saturation, Errors).

## 5. Tracing
- **OpenTelemetry** (vendor-neutral standard) for traces/metrics/logs instrumentation.
- Backends: Grafana Tempo, Jaeger, SigNoz (all-in-one OSS), Honeycomb, HyperDX/ClickStack.
- Most valuable once you have multiple services or slow requests you can't explain.

## 6. Uptime, alerts, status pages
- Uptime: Uptime Kuma (self-host — run it on a *different* server), Better Stack, UptimeRobot, Checkly (synthetic checks with Playwright).
- Cron/backup heartbeats: Healthchecks.io.
- Alert routing: Telegram/Slack/Teams/email; PagerDuty/Opsgenie/incident.io for on-call teams.
- Status page: Better Stack, Instatus, Upptime, or Uptime Kuma's status page.
- Alert on symptoms users feel (errors, latency, downtime), not every metric spike.

## 7. Product analytics
- Privacy-friendly web analytics: Plausible, Umami, Fathom, Cloudflare Web Analytics.
- Product analytics + feature flags + session replay + experiments: PostHog (self-host or cloud).
- Alternatives: Mixpanel, Amplitude.
- Respect consent requirements; avoid unnecessary cookies.

## 8. Application security (OWASP Top 10 focus)
- **Injection:** parameterized queries/ORM only; never string-concatenate SQL.
- **Broken access control:** server-side authorization on every request; tenant scoping; deny by default.
- **XSS:** framework auto-escaping; sanitize user HTML (DOMPurify); strict Content-Security-Policy with nonces.
- **CSRF:** SameSite cookies + CSRF tokens/origin checks for cookie-authenticated mutations.
- **SSRF:** validate/allowlist outbound URLs from user input; block internal IP ranges and cloud metadata endpoints.
- **File uploads:** validate type by content, size limits, store in object storage (not web root), serve via separate domain, scan if needed (ClamAV).
- **Rate limiting:** per IP/user/key on auth, search, expensive endpoints, and AI endpoints (cost abuse).
- **Security headers:** HSTS, CSP, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, frame-ancestors.
- **Secrets:** env/secret manager, never in client bundles (check `NEXT_PUBLIC_`/`VITE_` prefixes).
- **Dependencies:** keep updated; remove unused packages.
- **Errors:** no stack traces to users in production.
- **LLM features:** treat model output as untrusted; guard against prompt injection when models can call tools or read external content; restrict tool permissions.
- Webhooks: verify signatures, check timestamps, idempotent handling.

## 9. Infrastructure security
- SSH keys only, no root login, restrict SSH by IP or use Tailscale/Cloudflare Tunnel.
- Firewall: only 80/443 public; DB/Redis/admin panels private.
- Automatic security updates; reboot schedule for kernel patches.
- CrowdSec or fail2ban.
- Least-privilege DB users: app user without superuser, separate migration user, read-only user for BI.
- Encrypt disks where offered; TLS to external DBs.
- Cloudflare WAF and origin IP restriction.
- Separate production and staging credentials and networks.
- MFA on every provider account (GitHub, cloud, registrar, Cloudflare, email); hardware keys for owners.
- Registrar lock on domains.

## 10. Supply chain security
- Lockfiles committed; `pnpm install --frozen-lockfile` / `uv sync --locked` in CI.
- Renovate or Dependabot for automated updates (group minor/patch; review majors).
- Prefer packages that have existed for a while; be wary of brand-new releases of popular packages (compromised-maintainer attacks) — tools like pnpm's minimum release age settings help.
- `npm audit`/`pnpm audit`, `pip-audit`, `govulncheck`, `cargo audit`; Socket.dev or Snyk for deeper analysis.
- Container scanning: Trivy, Grype; SBOM with Syft.
- GitHub: branch protection, required reviews, secret scanning + push protection, CodeQL, pinned action SHAs for third-party actions.
- Sign images (Cosign) for higher assurance environments.

## 11. Privacy and compliance
- Map personal data: what, where, why, retention.
- Privacy policy and terms; cookie consent where required.
- User data export and deletion.
- Regulations to check: GDPR (EU users), UAE Federal PDPL, DIFC/ADGM data protection (if in those free zones), Saudi PDPL, HIPAA (US health), PCI DSS (cards — use hosted payment pages to minimize scope), SOC 2 (B2B sales).
- Data residency for government/regulated clients (see `06-deployment.md`).
- Accessibility law/standards (WCAG 2.2 AA) for public sector.

## 12. Security checklist by stage
**Prototype:** HTTPS, auth library, env secrets, parameterized queries, no public DB port.
**Launch:** + rate limiting, security headers/CSP, Sentry, uptime, backups with restore test, MFA on all accounts, dependency updates, Cloudflare WAF.
**Growth / B2B:** + audit logs, SSO, pen test, incident response plan, SOC 2 readiness (Vanta/Drata/Secureframe), vendor reviews, data processing agreements.
