# Supporting Services

> Last reviewed: October 2026. Pricing and regional availability change often — verify before committing.

## Table of contents
1. Payments and billing
2. Email
3. File storage, images, video
4. CMS and content
5. Search (hosted)
6. Maps and geolocation
7. Internationalization and RTL
8. PDFs, documents, spreadsheets
9. Scheduling and cron
10. Feature flags and experiments
11. Customer support and feedback
12. Domains and DNS
13. Developer tooling

---

## 1. Payments and billing
- **Stripe** (default where available): Checkout, Elements, Billing (subscriptions, usage-based), Connect (marketplaces), Tax, Invoicing. Supports UAE businesses.
- **Merchant of Record** (they handle global sales tax/VAT and are the legal seller): Paddle, Lemon Squeezy (owned by Stripe), Polar (developer-focused). Great for solo founders selling software globally.
- **Regional (MENA):** Checkout.com, Tap Payments, Network International (N-Genius), PayTabs, Telr, HyperPay, Amazon Payment Services; Tabby/Tamara for buy-now-pay-later; Apple Pay/Google Pay via gateways.
- **Mobile in-app purchases:** App Store / Google Play billing via RevenueCat.
- **Billing logic tools:** Stripe Billing, Lago or Orb (usage-based metering), Autumn/Flowglad-style wrappers.
- Rules: never handle raw card numbers (use hosted fields/pages → minimal PCI scope); process payment events via **verified webhooks**, idempotently; store Stripe IDs and your own ledger of what users are entitled to; handle failed payments (dunning), refunds, proration, taxes (UAE VAT 5%).

## 2. Email
- **Transactional:** Resend (default, great DX + React Email), Postmark (excellent deliverability), AWS SES (cheapest at volume), SendGrid, Mailgun, Brevo, Loops (product/SaaS email), Plunk.
- **Marketing/newsletters:** Loops, Brevo, Mailchimp, Kit (ConvertKit), Beehiiv, Listmonk (self-host).
- **Templates:** React Email, MJML, Maizzle.
- **Inbound email:** Cloudflare Email Routing/Workers, Postmark inbound, SES receiving.
- **Deliverability:** configure SPF, DKIM, DMARC on your domain; send from a subdomain (e.g., `mail.example.com`); separate transactional and marketing streams; handle bounces/complaints; one-click unsubscribe for marketing.
- **Business inbox:** Google Workspace, Microsoft 365, Zoho Mail, Proton.
- Never send email in the request path — queue it.

## 3. File storage, images, video
- **Object storage:** Cloudflare R2 (default), AWS S3, Backblaze B2, Wasabi, Google Cloud Storage, Azure Blob; self-host: MinIO, Garage, SeaweedFS.
- **Uploads UX:** presigned URLs direct to storage; libraries: Uppy, UploadThing (managed), react-dropzone; resumable uploads with tus for large files.
- **Images:** Cloudflare Images / Image Transformations, imgproxy (self-host), Thumbor, Bunny Optimizer, Cloudinary/ImageKit (managed, feature-rich), sharp (Node processing).
- **Video:** Mux (developer-friendly), Cloudflare Stream, Bunny Stream (cheap), api.video; self-host with FFmpeg + HLS on object storage.
- **Audio/transcription:** provider speech-to-text APIs (OpenAI, Deepgram, AssemblyAI, ElevenLabs), Whisper self-hosted.

## 4. CMS and content
- **Headless, code-first:** Payload (TS, Next.js-native, self-host, Postgres), Strapi, Directus (wraps any SQL DB with admin + API), Keystatic/Tina (git-based).
- **Hosted headless:** Sanity, Contentful, Storyblok (visual editor), Hygraph, Prismic.
- **Traditional:** WordPress (huge ecosystem; headless via WPGraphQL), Ghost (publishing/newsletters).
- **Docs:** Mintlify, GitBook, Starlight, Docusaurus.
- Pick git-based for developer-only content, headless CMS when marketing/editors publish.

## 5. Search (hosted)
Algolia, Meilisearch Cloud, Typesense Cloud, Elastic Cloud, OpenSearch Service; see `04-data-layer.md` for self-hosted.

## 6. Maps and geolocation
- **Rendering:** MapLibre GL JS (open source), Mapbox GL, Leaflet, OpenLayers, deck.gl/kepler.gl (big data), Google Maps JS.
- **Tiles:** OpenFreeMap, Protomaps (single-file PMTiles on R2), MapTiler, Stadia Maps, Mapbox.
- **Geocoding/places/routing:** Google Maps Platform (best POI coverage in many regions), Mapbox, HERE, TomTom, OpenRouteService/OSRM/Valhalla/GraphHopper (self-host routing, OSM data), Nominatim/Pelias/Photon (geocoding).
- **Storage/analysis:** PostGIS, H3 (hexagonal indexing), GeoPandas, DuckDB spatial.
- **Transit data:** GTFS/GTFS-Realtime feeds; OpenTripPlanner for multimodal journey planning.
- Check licensing and quotas (Google requires its maps for displaying its data).

## 7. Internationalization and RTL
- Libraries: Paraglide JS, i18next, next-intl, Lingui, FormatJS; Python: Babel/gettext; Django i18n.
- Translation management: Tolgee (open source), Crowdin, Lokalise, Phrase, Weblate.
- Use `Intl` APIs for dates, numbers, currencies; Arabic-Indic vs Latin digits per preference; Hijri calendar via `Intl.DateTimeFormat` with `islamic-umalqura` when needed.
- RTL: `dir="rtl"`, logical CSS properties, mirrored icons, bidirectional text handling (`<bdi>`), Arabic font support, test layouts in both directions.
- Store user locale and timezone on the profile.

## 8. PDFs, documents, spreadsheets
- Generate PDFs: Typst (fast, programmable), Playwright/Puppeteer HTML→PDF, @react-pdf/renderer, WeasyPrint (Python), Gotenberg (self-host conversion service), DocRaptor (managed).
- Read/parse: pdf.js, PyMuPDF, pdfplumber, Docling, Unstructured.
- Office files: docx (JS), python-docx, openpyxl/xlsxwriter, SheetJS, ExcelJS; LibreOffice headless for conversions.
- E-signatures: Documenso (open source), DocuSign, Dropbox Sign.

## 9. Scheduling and cron
- In-app scheduled jobs via the job queue (pg-boss, BullMQ repeatables, Celery beat, Solid Queue recurring).
- Platform cron: Cloudflare Cron Triggers, Vercel Cron, GitHub Actions schedule (not for critical jobs), systemd timers, Kubernetes CronJobs.
- Heartbeat-monitor every critical cron (Healthchecks.io).
- Calendar integrations: Google Calendar API, Microsoft Graph, Cal.com (open source scheduling), Nylas (unified calendar/email).

## 10. Feature flags and experiments
PostHog, GrowthBook (open source, experiments), Unleash (open source), Flagsmith, LaunchDarkly (enterprise), Statsig; standardize with OpenFeature SDKs.

## 11. Customer support and feedback
- Support/chat: Chatwoot (open source), Intercom, Crisp, Plain, Zendesk, Freshdesk, Help Scout.
- Feedback/roadmaps: Featurebase, Canny, Fider (open source).
- Status pages: see `08-observability-security.md`.

## 12. Domains and DNS
- Registrars: Cloudflare Registrar (at-cost), Porkbun, Namecheap; local TLDs (.ae via accredited registrars).
- DNS: Cloudflare (default), Route 53, deSEC.
- Enable DNSSEC, registrar lock, auto-renew, MFA. Keep records in IaC or exported.

## 13. Developer tooling
- Source control: GitHub (default), GitLab, Azure DevOps Repos, Bitbucket.
- Project tracking: Linear, GitHub Projects, Jira, Plane (open source).
- API testing: Bruno (open source, git-friendly), Hoppscotch, Postman, HTTPie.
- Local dev: Docker Compose for services, mise or asdf for tool versions, devcontainers/Codespaces, direnv.
- Database GUIs: TablePlus, DBeaver, Beekeeper Studio, pgAdmin, Drizzle Studio, Prisma Studio.
- Code quality: pre-commit hooks (lefthook, husky + lint-staged, pre-commit for Python), Conventional Commits, CODEOWNERS.
- AI coding: Claude Code, Cursor, GitHub Copilot; keep a `CLAUDE.md`/`AGENTS.md` describing the stack and conventions in each repo.
