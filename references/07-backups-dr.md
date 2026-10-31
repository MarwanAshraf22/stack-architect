# Backups and Disaster Recovery

> Last reviewed: October 2026. A backup that has never been restored is not a backup.

## Table of contents
1. Define RPO and RTO
2. The 3-2-1 rule
3. What to back up
4. PostgreSQL backups
5. Other databases
6. Files and object storage
7. Servers and configuration
8. Encryption, retention, immutability
9. Restore testing
10. Disaster recovery runbook
11. Reference backup script

---

## 1. Define RPO and RTO
- **RPO (Recovery Point Objective):** how much data you can afford to lose. Nightly dumps = up to 24 h lost. WAL archiving/PITR = seconds to minutes.
- **RTO (Recovery Time Objective):** how long you can be down. Restoring from offsite backup to a new server: 30 min–few hours. Hot standby replica: minutes.
- Write both numbers in the Stack Decision Record. They drive the backup design.

| Product stage | Typical target |
|---|---|
| Prototype | RPO 24 h, RTO 1 day |
| Paying customers | RPO ≤ 15 min, RTO ≤ 4 h |
| Critical / financial | RPO ≈ 0 (sync replica), RTO minutes |

## 2. The 3-2-1 rule
- **3** copies of data (production + 2 backups)
- **2** different storage types/providers
- **1** offsite (different provider/region from production)
Modern addition: **1 immutable** copy (object lock) and **0** errors in restore tests.

A VPS provider snapshot is convenient but **not** a sufficient backup on its own — same provider, same account, often same failure domain.

## 3. What to back up
- Databases (Postgres, Redis if it holds non-cache data, SQLite files).
- User uploads (object storage or disk).
- Configuration: docker-compose, Caddyfile, `.env` (encrypted, in secret manager), cron jobs, IaC state.
- DNS records (export from Cloudflare or manage via IaC).
- Code is in git (GitHub) — mirror critical repos elsewhere if business-critical.
- Third-party data you can't recreate (Stripe is the source of truth for payments, but keep your own records).

## 4. PostgreSQL backups
**Layer 1 — Logical dumps (simple, portable):**
- `pg_dump -Fc` nightly per database (custom format, compressed, selective restore with `pg_restore`).
- `pg_dumpall --globals-only` for roles.
- Good for small/medium DBs (< ~50–100 GB) and migrations between versions.

**Layer 2 — Physical backups + WAL archiving (point-in-time recovery):**
- **pgBackRest** (default, full/differential/incremental, parallel, encryption, S3/R2 support) or **WAL-G** (lightweight, S3/R2/GCS/Azure).
- Weekly full + daily incremental + continuous WAL archive → restore to any second.
- **Barman** is another mature option.

**Layer 3 — Replication (availability, not a backup):**
- Streaming replica on another server for fast failover; Patroni for automated HA.
- Replicas copy mistakes (DROP TABLE) instantly — they don't replace backups.

**Managed Postgres:** providers include automated backups/PITR (check retention days). Still take an independent periodic logical dump to your own storage to avoid single-vendor risk.

## 5. Other databases
- **SQLite:** Litestream continuously replicates to S3/R2 (near-zero RPO); or `sqlite3 .backup` / `VACUUM INTO` for snapshots. Never copy the file while it's being written without these tools.
- **MySQL/MariaDB:** `mysqldump`/`mydumper` for logical; Percona XtraBackup / Mariabackup for physical; binlogs for PITR.
- **MongoDB:** `mongodump` or Percona Backup for MongoDB; Atlas backups if managed.
- **Redis/Valkey:** usually cache — no backup needed. If used as a primary store, enable AOF + RDB snapshots and copy them offsite.
- **ClickHouse:** `clickhouse-backup` or native BACKUP to S3.

## 6. Files and object storage
- R2/S3: enable versioning and lifecycle rules (expire old versions after N days); replicate critical buckets to a second provider (rclone sync to Backblaze B2 or another region).
- Local disk uploads: restic or Borg/borgmatic to offsite storage (encrypted, deduplicated). Kopia is a GUI-friendly alternative.
- Object Lock (WORM) on the backup bucket for ransomware resistance (S3 Object Lock, B2 Object Lock; check R2's current support for bucket locks).

## 7. Servers and configuration
- Treat servers as cattle: rebuildable from IaC/cloud-init/Ansible + docker-compose in git.
- Keep a `RESTORE.md` in the repo with exact steps.
- Back up `/etc` customizations only if not in IaC.
- Provider snapshots weekly as a convenience layer for fast whole-server rollback.

## 8. Encryption, retention, immutability
- Encrypt backups before they leave the server (pgBackRest/WAL-G built-in encryption, restic/Borg, or `age`). Store keys in a password manager/secret manager **separate** from the backups.
- Retention (GFS): 7 daily, 4 weekly, 12 monthly (adjust for compliance; financial records may need years).
- Separate credentials: backup writer key can write but not delete (or uses object lock) so a compromised server can't wipe backups.
- Different provider/account from production.

## 9. Restore testing
- Automate a monthly restore: spin up a temporary container, restore the latest backup, run sanity queries (row counts, latest timestamps), report success to monitoring.
- Do a full DR drill at least twice a year: new server from scratch, restore, switch DNS. Time it — that's your real RTO.
- Monitor backup jobs: alert if no successful backup in 26 h (Healthchecks.io, Uptime Kuma push monitors, Better Stack heartbeats).

## 10. Disaster recovery runbook (template)
1. Declare incident; assign owner; communicate status page update.
2. Identify scope: data corruption, server loss, provider outage, security breach.
3. If breach: rotate all secrets first, preserve evidence.
4. Provision new server (IaC/cloud-init).
5. Restore database to the target point in time (before corruption).
6. Restore files/uploads.
7. Deploy app at the known-good version; run migrations if needed.
8. Verify with smoke tests; compare data checks.
9. Switch DNS / Cloudflare origin; monitor.
10. Post-mortem: timeline, root cause, actions.

## 11. Reference backup script (nightly logical dump to R2)
```bash
#!/usr/bin/env bash
# Nightly Postgres dump → encrypted → Cloudflare R2. Run via cron or a scheduled container.
set -euo pipefail
STAMP=$(date -u +%Y-%m-%dT%H-%M-%SZ)
FILE="/tmp/${PGDATABASE}-${STAMP}.dump"

pg_dump -Fc -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -f "$FILE"
age -r "$AGE_PUBLIC_KEY" -o "${FILE}.age" "$FILE"

# rclone remote "r2" configured with R2 S3-compatible credentials (write-only key)
rclone copy "${FILE}.age" "r2:${BACKUP_BUCKET}/postgres/daily/"
rm -f "$FILE" "${FILE}.age"

# Heartbeat so monitoring alerts if backups stop
curl -fsS -m 10 --retry 3 "$HEARTBEAT_URL" > /dev/null
```
Pair this with WAL archiving (pgBackRest/WAL-G) once real users depend on the data, and a lifecycle rule on the bucket for retention.
