# Example: Bilingual Freelance Landing Page

> **Prompt:** "Landing page for my freelance data analytics services. Fast, bilingual Arabic/English, a contact form, and I want to rank on Google."

---

# Stack Decision Record: Freelance Landing Page

**Date:** 2026-10-31 · **Status:** Proposed

## 1. Summary
A fast, SEO-friendly marketing site with services, case studies, and a contact form, in English and Arabic (RTL).

**Archetype:** Landing page / marketing site (proportional record: short on purpose).

## 2. The stack
| Layer | Choice | Why | Alternative (switch if...) |
|---|---|---|---|
| Framework | Astro + Tailwind CSS | Ships near-zero JS, perfect Lighthouse scores, built-in i18n routing | Next.js if it will grow into an app with login |
| Content | Markdown/MDX case studies in the repo | No CMS needed for a solo owner | Keystatic if you want a visual editor |
| i18n / RTL | Astro i18n routing (`/en`, `/ar`), `dir="rtl"`, logical Tailwind utilities | Proper Arabic layout and hreflang tags for SEO | — |
| Fonts | Self-hosted IBM Plex Sans + IBM Plex Sans Arabic | Matching Latin/Arabic design, no third-party requests | Cairo / Tajawal |
| Contact form | Cloudflare Worker endpoint → Resend email, protected by Turnstile | No server to run, spam protection | Formspree |
| Hosting | Cloudflare (Workers static assets / Pages) | Free, global CDN, fast in the Gulf | Netlify |
| Analytics | Cloudflare Web Analytics or Plausible | Privacy-friendly, no cookie banner needed | Umami |
| SEO | Sitemap, hreflang, OG images, JSON-LD (Person/ProfessionalService) | Ranking and rich previews | — |
| Database / auth / backups | Not needed | Static site; content lives in git (GitHub is the backup) | — |

## 3. Performance targets
LCP < 1.5 s, CLS < 0.05, JS < 30 KB, Lighthouse 95+ on mobile. Images in AVIF/WebP via Astro Image.

## 4. Cost
Domain (~$10–15/year) + $0 hosting.

## 5. First-day plan
1. `npm create astro@latest`, add Tailwind and i18n config.
2. Build sections: hero, services, case studies, about, contact.
3. Arabic translations + RTL check.
4. Contact Worker + Turnstile + Resend.
5. Connect domain on Cloudflare, submit sitemap to Google Search Console.
