# Authentication and Authorization

> Last reviewed: October 2026. Never hand-roll password hashing, session crypto or OAuth flows.

## Table of contents
1. Decide the model
2. Library vs hosted vs self-hosted IdP
3. Options by ecosystem
4. Sessions vs JWT
5. Login methods
6. Authorization (who can do what)
7. Multi-tenant and enterprise SSO
8. Security checklist

---

## 1. Decide the model
- **Who signs in?** Public consumers, business customers (teams), internal staff, machines (API keys/service accounts), devices.
- **How?** Email + password, magic link/OTP, social OAuth (Google, Apple, Microsoft, GitHub), passkeys, phone OTP (SMS/WhatsApp), enterprise SSO (SAML/OIDC), UAE Pass or national ID for government services.
- **Where are users stored?** Your own DB (library approach) or a vendor (hosted approach).
- **Roles and orgs?** Simple roles, organizations/teams, fine-grained sharing.

## 2. Library vs hosted vs self-hosted IdP

| Approach | Examples | Pros | Cons |
|---|---|---|---|
| Library in your app (users in your DB) | Better Auth, Auth.js, Django allauth, Laravel Fortify/Breeze, Devise, ASP.NET Identity, Spring Security | Free, full control, no vendor lock-in, data stays yours, fast (same DB) | You own security updates and UX flows |
| Hosted auth service | Clerk, WorkOS (AuthKit), Auth0, Kinde, Stytch, Descope, Supabase Auth, Firebase Auth, AWS Cognito, Microsoft Entra External ID | Fast setup, prebuilt UI, enterprise SSO, compliance | Monthly cost per MAU, lock-in, user data with vendor, extra latency |
| Self-hosted identity provider | Keycloak, Zitadel, Authentik, Ory (Kratos/Hydra), Logto, Authelia (forward auth), SuperTokens | Central SSO for many apps, enterprise protocols, no per-user fees | Heavier to run and secure |

**Default:** library approach (Better Auth for TS). Choose hosted when time-to-market and enterprise SSO matter more than cost. Choose a self-hosted IdP when many apps need one shared login or for on-prem/government.

## 3. Options by ecosystem
- **TypeScript (any framework):** **Better Auth** — framework-agnostic, stores users in your DB via Drizzle/Prisma/Kysely adapters; plugins for 2FA, passkeys, organizations, admin, magic links, phone OTP, SSO, API keys, rate limiting. Default.
- **Auth.js (NextAuth):** widely used with Next.js; now maintained under the Better Auth team — prefer Better Auth for new projects.
- **Lucia:** no longer maintained as a library; now a learning resource for building sessions yourself.
- **Python:** Django allauth (Django), FastAPI Users or Authlib (FastAPI), or a hosted/IdP provider.
- **PHP/Ruby/.NET/Java:** use the framework's built-in auth (Laravel, Rails 8 auth generator/Devise, ASP.NET Identity, Spring Security).
- **Mobile (Expo):** Better Auth Expo plugin, Clerk Expo, or Supabase Auth; use secure storage (expo-secure-store) for tokens.
- **Supabase/Firebase projects:** use their built-in auth for prototypes.

## 4. Sessions vs JWT
- **Web apps: server-side sessions in HTTP-only, Secure, SameSite=Lax cookies.** Session ID stored in DB (optionally cached in Redis). Easy revocation, no tokens in JS.
- **JWT access tokens:** for stateless APIs, service-to-service, or third-party clients. Keep them short-lived (5–15 min) with rotating refresh tokens; you can't easily revoke them otherwise.
- **Mobile apps:** tokens (or session tokens) stored in Keychain/Keystore via secure storage, never AsyncStorage/localStorage.
- **Never** put tokens in localStorage on the web (XSS steals them).
- **API keys for machines:** generate random, show once, store only a hash, prefix for identification (`sk_live_...`), scope and rotate.

## 5. Login methods
- **Email + password:** hash with Argon2id (or bcrypt/scrypt via the library). Enforce length (min 8–12), check against breached passwords (HIBP k-anonymity API). Email verification and secure reset tokens (single use, expiring).
- **Passkeys (WebAuthn):** phishing-resistant, best UX; offer alongside other methods.
- **Magic links / email OTP:** passwordless; good for low-frequency apps. Watch email deliverability.
- **Social OAuth:** Google, Apple (required on iOS if other social logins exist), Microsoft, GitHub. Use PKCE; verify state.
- **Phone OTP:** SMS/WhatsApp via Twilio, Vonage, MessageBird, Unifonic (MENA); costly and SIM-swap prone — use as secondary factor or where phone is the identity norm.
- **2FA/MFA:** TOTP apps, passkeys, backup codes; require for admins.
- **Enterprise SSO:** SAML 2.0 and OIDC with Microsoft Entra ID, Google Workspace, Okta.
- **Government:** UAE Pass (OIDC-based) for UAE government/regulated services — requires onboarding with the provider.

## 6. Authorization (who can do what)
- **RBAC (roles):** user → role → permissions. Enough for most apps. Check permissions on the server for every action.
- **ABAC (attributes/policies):** rules using user, resource, environment attributes. Libraries: CASL (TS), Casbin (many languages), Cerbos (policy service), Open Policy Agent (OPA).
- **ReBAC (relationships, like Google Drive sharing):** OpenFGA, SpiceDB (Zanzibar-style), Permit.io, Oso.
- **Database enforcement:** Postgres row-level security as a second line of defense.
- **Rules:** deny by default; authorize at the data-access layer; never trust client-sent role/tenant IDs; log authorization failures; admin actions audited.

## 7. Multi-tenant and enterprise SSO
- Model: users ↔ memberships ↔ organizations with role per membership.
- Invitations by email with expiring tokens.
- Org-level SSO (SAML/OIDC) with domain verification; SCIM for user provisioning in enterprise deals (WorkOS, Better Auth SSO/SCIM plugins, Keycloak).
- Session includes active organization; switching orgs re-scopes all queries.
- Impersonation tool for support with full audit trail.

## 8. Security checklist
- [ ] HTTPS everywhere; HSTS.
- [ ] Cookies: HttpOnly, Secure, SameSite=Lax (Strict for admin), scoped domain.
- [ ] CSRF protection for cookie-based mutations (library or SameSite + origin checks).
- [ ] Rate limit login, signup, reset, OTP endpoints; lockout/backoff on repeated failures.
- [ ] Generic error messages ("invalid email or password") to avoid account enumeration.
- [ ] Session rotation on login and privilege change; logout invalidates server session.
- [ ] Short session lifetime for admins; re-auth for sensitive actions (change email/password, payouts).
- [ ] MFA required for admins and staff.
- [ ] Bot protection on public forms (Cloudflare Turnstile).
- [ ] Audit log for sign-ins, role changes, sensitive actions.
- [ ] Secrets (OAuth client secrets, signing keys) in a secret manager, rotated.
- [ ] Account deletion and data export flows.
