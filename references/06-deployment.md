# Hosting, Deployment, CI/CD, Infrastructure

> Last reviewed: October 2026. Verify pricing and region availability before committing.

## Table of contents
1. Hosting tiers
2. Choosing a tier
3. VPS setup (house default)
4. PaaS and serverless options
5. Cloudflare in front
6. Containers and orchestration
7. CI/CD pipeline
8. Infrastructure as code
9. Secrets and configuration
10. Environments and releases
11. Region and data residency
12. Reference configs

---

## 1. Hosting tiers

| Tier | Examples | Best for | Trade-off |
|---|---|---|---|
| Static/CDN | Cloudflare (Pages / Workers static assets), Netlify, Vercel, GitHub Pages | Landing pages, docs, SPAs | No server logic (except functions) |
| Edge/serverless functions | Cloudflare Workers, Vercel Functions, Netlify Functions, AWS Lambda, Deno Deploy | Spiky traffic, APIs, webhooks, global low latency | Execution limits, cold starts (not Workers), DB connection handling |
| PaaS | Railway, Render, Fly.io, Heroku, DigitalOcean App Platform, Google Cloud Run, Azure Container Apps, Koyeb | Teams wanting `git push` deploys without ops | Higher cost per resource, less control |
| VPS | Hetzner, DigitalOcean, Vultr, Linode/Akamai, OVHcloud, Contabo, AWS Lightsail | Best price/performance, full control, colocated DB | You own patching, backups, security, uptime |
| Self-hosted PaaS on VPS | Coolify, Dokploy, CapRover, Kamal (CLI), Dokku | VPS economics with PaaS convenience | Still your server to maintain |
| Kubernetes | EKS, GKE, AKS, DigitalOcean K8s, k3s on VPS | Many services, big teams, autoscaling | Significant complexity |
| Big cloud full platform | AWS, Google Cloud, Azure, Oracle Cloud, Alibaba Cloud | Enterprise, compliance, managed everything | Cost complexity, learning curve |
| On-prem / private cloud | VMware, OpenShift, bare metal | Government, strict data residency | Hardware and ops burden |

## 2. Choosing a tier
- Static site → Cloudflare static hosting (free tier is generous).
- Solo/small team, cost-sensitive, wants speed and control → **VPS + Docker Compose + Caddy + Cloudflare** (house default).
- Small team, no ops time → Vercel/Netlify (frontend) + managed Postgres in same region, or Railway/Render for everything.
- Global edge app → Cloudflare Workers + D1/Hyperdrive/Durable Objects, or Fly.io multi-region.
- Containerized APIs with scale-to-zero → Cloud Run / Azure Container Apps.
- Enterprise/government → the organization's approved cloud (Azure/AWS/Oracle/G42/Core42 in UAE) or on-prem.
- Many services, platform team exists → Kubernetes.

## 3. VPS setup (house default)
**Sizing start:** 2–4 vCPU, 4–8 GB RAM, NVMe SSD runs app + Postgres + Redis for most early products. Scale vertically first.

**Provision & harden:**
1. Latest Ubuntu LTS or Debian stable.
2. Create non-root sudo user; SSH key auth only; disable password and root login.
3. Firewall (UFW or provider firewall): allow 22 (ideally restricted to your IP or via Tailscale), 80, 443 only. Database and Redis ports **never** public.
4. `unattended-upgrades` for security patches; fail2ban or CrowdSec.
5. Install Docker Engine + Compose plugin.
6. Optional: Tailscale for private admin access; Cloudflare Tunnel to expose apps without opening ports at all.

**Run:**
- `docker compose` with services: `app`, `postgres`, `redis` (valkey), `caddy` (reverse proxy, automatic HTTPS), `backup` (scheduled), optionally `worker`.
- Postgres data on a named volume; bind only to the internal Docker network.
- Healthchecks and `restart: unless-stopped`.
- Logs: Docker log rotation (`max-size`, `max-file`).

**Deploy flow:** GitHub Actions builds image → pushes to GHCR → SSH to server → `docker compose pull && docker compose up -d` (or Kamal / Coolify webhook). Run migrations before switching traffic.

**Zero-downtime:** Kamal (built-in), Coolify, or Caddy with two app replicas and health checks; or blue/green with Docker Compose profiles.

## 4. PaaS and serverless options
- **Vercel:** best Next.js experience; preview deploys per PR; pricing scales with usage — watch function duration and bandwidth.
- **Netlify:** similar; strong for static and Astro.
- **Cloudflare Workers:** V8 isolates, near-zero cold start, global; Hyperdrive to pool connections to an external Postgres; D1 (SQLite), KV, R2, Queues, Durable Objects, Workers AI. Node compatibility is good but not 100% — check libraries.
- **Railway / Render:** easiest full-stack PaaS with managed Postgres/Redis.
- **Fly.io:** run containers close to users worldwide; good for multi-region and SQLite+LiteFS.
- **Google Cloud Run:** containers, scale to zero, pay per use.
- **AWS:** Lambda + API Gateway, ECS Fargate, App Runner, Amplify; use SST or CDK to tame it.
- **Supabase / Firebase / Convex:** backend platforms (DB+auth+functions); deploy frontend separately.

## 5. Cloudflare in front
- DNS on Cloudflare; proxy (orange cloud) for app domains.
- SSL/TLS mode **Full (strict)** with Caddy certificates or a Cloudflare Origin Certificate.
- WAF managed rules, rate limiting rules, Bot Fight Mode / Turnstile for forms.
- Cache rules for static assets and public pages; bypass cache for authenticated routes.
- Restrict origin to Cloudflare IPs (firewall allowlist or Cloudflare Tunnel) so attackers can't bypass it.
- Cloudflare Access (Zero Trust) to protect admin panels and internal tools with SSO.
- R2 for object storage and backups; Email Routing for inbound; Web Analytics.

## 6. Containers and orchestration
- Dockerfile rules: multi-stage builds, small base images (distroless, `-slim`, Alpine where compatible), pinned versions, non-root user, `.dockerignore`, healthcheck.
- Docker Compose is enough for single-server deployments.
- Docker Swarm or Nomad for simple multi-node.
- Kubernetes when you have many services and people to run it; use Helm/Kustomize, Argo CD/Flux (GitOps), cert-manager, ingress-nginx or Gateway API, external-secrets.
- Image registry: GHCR (default), Docker Hub, AWS ECR, Google Artifact Registry.

## 7. CI/CD pipeline
**GitHub Actions (default)** — alternatives: GitLab CI, Azure DevOps (enterprise Microsoft), CircleCI, Buildkite.

Pipeline stages:
1. Install with lockfile (cache dependencies).
2. Lint + format check + type check.
3. Unit tests; integration tests with a Postgres service container.
4. Build artifact / Docker image (tag with git SHA).
5. Security scans: dependency audit, secret scanning, container scan (Trivy), CodeQL.
6. E2E tests (Playwright) against a preview environment.
7. Deploy to staging automatically; production on main/tag with approval if needed.
8. Run DB migrations as a deploy step.
9. Smoke test + automatic rollback on failure.
10. Notify (Slack/Teams/Telegram).

Preview environments per PR: Vercel/Netlify/Cloudflare built-in; Coolify/Dokploy support them on VPS.

## 8. Infrastructure as code
- **OpenTofu/Terraform** — default for cloud resources, DNS, Cloudflare config.
- **Pulumi** — IaC in TypeScript/Python.
- **SST** — AWS/Cloudflare apps in TypeScript.
- **Ansible** — server configuration (VPS hardening, packages).
- **cloud-init** — first-boot VPS setup.
Keep state remote and locked (S3/R2 backend, Terraform Cloud).

## 9. Secrets and configuration
- Never commit secrets. `.env.example` lists keys without values.
- Secret managers: Doppler, Infisical (self-hostable), 1Password Secrets Automation, HashiCorp Vault/OpenBao, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager.
- Encrypted files in git: SOPS + age.
- GitHub Actions secrets/environments for CI; OIDC federation to clouds instead of long-lived keys.
- Validate env vars at startup; fail fast if missing.
- Rotate secrets on staff changes and leaks; enable GitHub secret scanning + push protection.

## 10. Environments and releases
- local → preview (per PR) → staging → production.
- Same Docker image promoted across environments; only config differs.
- Feature flags (PostHog, Unleash, GrowthBook, Flagsmith, OpenFeature) to decouple deploy from release.
- Semantic versioning and changelogs (Changesets, release-please) for libraries/APIs.
- Database migrations backward compatible with the previous app version.

## 11. Region and data residency
- Put app + DB in the region closest to most users. For Gulf users, check which providers offer UAE/GCC regions (Azure UAE North, AWS me-central-1 UAE, Oracle Dubai/Abu Dhabi, Google Doha/Dammam, local providers); otherwise choose the nearest low-latency region and measure.
- Government, health, finance data may legally require in-country hosting (e.g., UAE regulations, Dubai DESC standards). Confirm before choosing a provider.
- CDN edge caching makes static content fast everywhere regardless of origin.

## 12. Reference configs

**docker-compose.yml (sketch)**
```yaml
services:
  app:
    image: ghcr.io/OWNER/APP:${TAG:-latest}
    env_file: .env
    depends_on:
      postgres: { condition: service_healthy }
      redis: { condition: service_started }
    restart: unless-stopped
  worker:
    image: ghcr.io/OWNER/APP:${TAG:-latest}
    command: ["node", "worker.js"]
    env_file: .env
    restart: unless-stopped
  postgres:
    image: postgres:17
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
    restart: unless-stopped
  redis:
    image: valkey/valkey:8
    restart: unless-stopped
  caddy:
    image: caddy:2
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    restart: unless-stopped
volumes: { pgdata: {}, caddy_data: {} }
```

**Caddyfile**
```
app.example.com {
  encode zstd gzip
  reverse_proxy app:3000
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    X-Content-Type-Options nosniff
    Referrer-Policy strict-origin-when-cross-origin
  }
}
```

**GitHub Actions deploy (sketch)**
```yaml
on: { push: { branches: [main] } }
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions: { contents: read, packages: write }
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with: { registry: ghcr.io, username: ${{ github.actor }}, password: ${{ secrets.GITHUB_TOKEN }} }
      - uses: docker/build-push-action@v6
        with: { push: true, tags: "ghcr.io/${{ github.repository }}:${{ github.sha }}" }
      - name: Deploy
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SSH_HOST }}
          username: ${{ secrets.SSH_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /srv/app
            export TAG=${{ github.sha }}
            docker compose pull app worker
            docker compose run --rm app npm run db:migrate
            docker compose up -d app worker
```
Pin action versions to current releases when scaffolding.
