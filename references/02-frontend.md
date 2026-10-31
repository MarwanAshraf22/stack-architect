# Frontend

> Last reviewed: October 2026.

## Table of contents
1. Rendering strategy first
2. Meta-frameworks
3. UI libraries and styling
4. State, data fetching, forms, validation
5. Charts, tables, maps, rich text
6. Build tooling, testing, quality
7. Accessibility, i18n, RTL
8. Performance budget

---

## 1. Rendering strategy first
Decide *how* pages render before choosing a framework.

| Strategy | Use when | Tools |
|---|---|---|
| Static (SSG) | Content rarely changes, SEO, max speed | Astro, Next.js export, Eleventy |
| Server-side rendering (SSR) | Personalized pages, SEO + dynamic data | TanStack Start, Next.js, React Router 7, SvelteKit, Nuxt |
| SPA (client-only) | Behind login, app-like, no SEO | Vite + React + TanStack Router |
| Islands / partial hydration | Mostly static with a few interactive parts | Astro |
| Server-driven HTML | Simple CRUD, small team, minimal JS | HTMX + Django/Laravel/Rails/Go |
| Streaming SSR | Slow data sources, want fast first paint | TanStack Start, Next.js, React Router 7 |

Rule: public pages that need SEO → static or SSR. Logged-in app screens → SSR or SPA (SEO irrelevant).

## 2. Meta-frameworks

**TanStack Start (React)** — Full-stack React on Vite with type-safe routing (TanStack Router), server functions, SSR/streaming, deploys to Node, Bun, Cloudflare, Netlify, Vercel. Stable 1.0 (Oct 2026). Best for: type-safe apps with login, dashboards, SaaS. Less "magic" than Next.js; explicit data loading.

**Next.js (React)** — Largest ecosystem, App Router with React Server Components, many tutorials and hiring pool. Best on Vercel; self-hosting works (standalone output in Docker) but some features need care (ISR cache, image optimization). Best for: teams wanting the most common choice, content + app hybrids.

**React Router 7 (framework mode, formerly Remix)** — Web-standards-focused, loaders/actions, progressive enhancement. Solid alternative to Next.

**Astro** — Content-first, ships zero JS by default, islands for interactivity with any UI library. Best for landing pages, blogs, docs, marketing sites.

**SvelteKit (Svelte 5)** — Excellent DX, small bundles, fast. Smaller ecosystem than React.

**Nuxt (Vue 3)** — Vue's full-stack framework; great if the team prefers Vue.

**SolidStart (Solid)** — Very fast fine-grained reactivity; smaller ecosystem.

**Angular** — Enterprise, opinionated, strong in large corporates and government; signals-based modern Angular is much improved.

**Qwik** — Resumability for instant load; niche.

**HTMX / Alpine.js** — Sprinkle interactivity onto server-rendered HTML; pairs with Django, Laravel, Rails, Go.

**Choosing:**
- Team knows React → TanStack Start (type safety, explicit) or Next.js (ecosystem, Vercel).
- Content site → Astro.
- Team prefers Vue → Nuxt. Svelte → SvelteKit.
- Enterprise mandate → Angular or Next.js.
- Backend-heavy team, simple UI → HTMX with their backend framework.

## 3. UI libraries and styling
- **Tailwind CSS v4** — default styling. Utility-first, tiny output, design tokens via CSS variables.
- **shadcn/ui** — copy-in components built on Radix/Base UI primitives + Tailwind. Default component layer for React. You own the code.
- **Headless primitives:** Radix UI, Base UI, React Aria (best accessibility), Ark UI (multi-framework).
- **Full component kits:** Mantine (batteries included), MUI (Material, enterprise), Chakra, Ant Design (data-heavy admin, popular in Asia), PrimeReact/PrimeVue.
- **Vue:** shadcn-vue, Nuxt UI, PrimeVue, Vuetify. **Svelte:** shadcn-svelte, Skeleton, Bits UI.
- **Icons:** Lucide (default), Heroicons, Phosphor, Tabler.
- **Animation:** Motion (formerly Framer Motion), AutoAnimate, CSS view transitions.
- **CSS-in-JS:** avoid runtime CSS-in-JS for new projects (performance, RSC incompatibility); use Tailwind, CSS Modules or zero-runtime (Panda CSS, vanilla-extract).

## 4. State, data fetching, forms, validation
- **Server state:** TanStack Query (default) — caching, retries, background refetch. SWR is lighter. In RSC/Next, fetch on the server where possible.
- **Client state:** start with React state/context; Zustand for global client state; Jotai for atomic; XState for complex flows/state machines. Avoid Redux for new projects unless the team insists (Redux Toolkit if so).
- **URL state:** TanStack Router search params (type-safe) or nuqs (Next.js). Put filters/pagination in the URL.
- **Forms:** TanStack Form or React Hook Form, with Zod schemas shared between client and server.
- **Validation:** Zod (default), Valibot (smaller bundles), ArkType. Standard Schema lets libraries accept any of them.
- **Type-safe API calls:** server functions (TanStack Start/Next), tRPC or oRPC (TS monorepos), or OpenAPI-generated clients (openapi-fetch, orval, hey-api) for language-agnostic APIs.

## 5. Charts, tables, maps, rich text
- **Charts:** Recharts (simple React), Apache ECharts (powerful, big datasets), Nivo, visx (custom), Chart.js, Tremor (dashboard components), Observable Plot, uPlot (time series, very fast).
- **Tables:** TanStack Table (headless, default) + TanStack Virtual for large lists; AG Grid for Excel-like enterprise grids.
- **Maps:** MapLibre GL (open source) with OpenFreeMap/MapTiler/Protomaps tiles; Mapbox (paid, polished); Leaflet (simple); deck.gl for big geospatial data; Google Maps when Places/Directions APIs are needed.
- **Rich text:** Tiptap (default), Lexical, BlockNote (Notion-like), Plate.
- **Dates:** date-fns or Day.js; Temporal API where available.
- **PDF:** react-pdf (render), @react-pdf/renderer or Typst/Playwright (generate).

## 6. Build tooling, testing, quality
- **Build:** Vite (default), Turbopack (Next), Rsbuild/Rspack (large webpack migrations).
- **Package manager:** pnpm (default), Bun (fast, also runtime), npm.
- **Monorepo:** pnpm workspaces + Turborepo; Nx for large orgs.
- **Lint/format:** Biome (fast, all-in-one) or ESLint + Prettier; Oxlint for speed.
- **TypeScript:** `strict: true` always.
- **Unit/component tests:** Vitest + Testing Library.
- **E2E:** Playwright (default).
- **Visual regression:** Playwright screenshots, Chromatic (Storybook).
- **Component workshop:** Storybook or Ladle.

## 7. Accessibility, i18n, RTL
- Target WCAG 2.2 AA. Use semantic HTML and accessible primitives (Radix/React Aria). Test with axe (via Playwright) and a screen reader.
- i18n: Paraglide JS (compile-time, tiny), i18next/react-i18next, next-intl (Next.js), Lingui. ICU message format for plurals.
- RTL (Arabic, Hebrew, Urdu): set `dir` per locale, use Tailwind logical utilities (`ms-`, `me-`, `ps-`, `pe-`, `start-`, `end-`), mirror directional icons, choose fonts with good Arabic support (IBM Plex Sans Arabic, Noto Sans Arabic, Cairo, Tajawal). Test number/date formatting with `Intl`.

## 8. Performance budget
- Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1.
- Initial JS for marketing pages < 100 KB gzipped; app shells < 250 KB.
- Images: modern formats, explicit width/height, lazy loading below the fold, CDN resizing (Cloudflare Images, imgproxy, Next/Image, Astro Image).
- Fonts: self-host, `font-display: swap`, subset, preload critical.
- Route-based code splitting, prefetch on hover/intent (TanStack Router does this well).
- Cache static assets with long-lived immutable headers behind Cloudflare.
