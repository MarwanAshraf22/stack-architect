# Mobile, Desktop, Extensions, CLI

> Last reviewed: October 2026.

## Table of contents
1. Mobile: choosing the approach
2. React Native + Expo (default)
3. Flutter
4. Native iOS / Android
5. PWA and hybrid
6. Mobile backend concerns
7. Desktop apps
8. Browser extensions
9. CLI tools
10. Cross-platform monorepo layout

---

## 1. Mobile: choosing the approach

| Approach | Pick when |
|---|---|
| **Expo (React Native)** | Team knows React/TS, want iOS + Android (+ web) from one codebase. Default. |
| Flutter | Team knows Dart or wants pixel-identical custom UI everywhere; strong for complex animations |
| Native (Swift/SwiftUI, Kotlin/Jetpack Compose) | Deep platform features (AR, advanced camera/audio, widgets, Watch/Wear), max performance, single-platform apps |
| Kotlin Multiplatform (+ Compose Multiplatform) | Share business logic with native UIs; Kotlin teams |
| PWA | Simple apps, no app store needed, budget-limited; iOS push now supported for installed PWAs but with limits |
| Capacitor (Ionic) | Wrap an existing web app into stores quickly |
| .NET MAUI | C#/.NET organizations |

## 2. React Native + Expo (default)
- Expo SDK with the New Architecture; Expo Router (file-based routing, typed routes, deep links).
- UI: NativeWind (Tailwind for RN), Tamagui, Gluestack UI, React Native Paper (Material), Unistyles.
- Data: TanStack Query; forms with React Hook Form/TanStack Form + Zod; global state Zustand.
- Storage: expo-secure-store (tokens), MMKV (fast KV), expo-sqlite (local DB), Drizzle supports expo-sqlite.
- Offline-first/sync: PowerSync (Postgres ↔ SQLite), ElectricSQL, WatermelonDB, Replicache/Zero (Rocicorp), Legend-State, TinyBase.
- Animations: Reanimated, Moti; gestures: Gesture Handler; lists: FlashList / Legend List.
- Builds and releases: EAS Build, EAS Submit, EAS Update (over-the-air JS updates within store rules).
- Push: expo-notifications (FCM/APNs underneath) or OneSignal.
- Testing: Jest + React Native Testing Library; E2E with Maestro (simple) or Detox.
- Monitoring: Sentry for React Native.
- Payments in-app: RevenueCat (subscriptions/IAP wrapper). Digital goods must use App Store/Play billing; physical goods/services can use Stripe.

## 3. Flutter
- State: Riverpod (default), Bloc; routing: go_router; networking: Dio; local DB: Drift, Isar alternatives; codegen: freezed, json_serializable.
- Backend pairing: any REST/GraphQL API; Firebase and Supabase have first-class SDKs; Serverpod for Dart full-stack.

## 4. Native iOS / Android
- iOS: Swift, SwiftUI, Swift Concurrency, SwiftData or GRDB/Core Data, Xcode Cloud or Fastlane for CI.
- Android: Kotlin, Jetpack Compose, Coroutines/Flow, Room, Hilt, Gradle; Fastlane or GitHub Actions for CI.

## 5. PWA and hybrid
- Vite PWA plugin / Serwist for service workers; Web App Manifest; offline caching strategies.
- Good for internal field apps and simple consumer tools; check iOS limitations.

## 6. Mobile backend concerns
- Same API as web (REST/OpenAPI or tRPC/oRPC from a TS monorepo).
- Auth: tokens in secure storage; OAuth via system browser (expo-auth-session/AppAuth), Sign in with Apple when offering other social logins on iOS.
- Versioning: old app versions live for months — keep APIs backward compatible; force-update mechanism for breaking changes.
- Deep links / universal links / app links configured on your domain.
- Media upload directly to object storage with presigned URLs.
- App Store review guidelines: account deletion in-app is required on iOS when signup exists; privacy nutrition labels; data safety form on Play.

## 7. Desktop apps

| Option | Pick when |
|---|---|
| **Tauri 2** | Default: web UI (React/Svelte/Vue) + Rust backend, small binaries, low RAM, also targets mobile |
| Electron | Need Node.js ecosystem, consistent Chromium rendering, mature tooling (electron-builder/Electron Forge); larger binaries |
| Wails | Go backend + web UI |
| Native | SwiftUI (Mac), WinUI 3/WPF (.NET, Windows), GTK (Linux) |
| Qt (C++/PySide6) | Industrial, embedded displays, engineering tools |
| Flutter desktop / Compose Multiplatform | Sharing with mobile codebase |
| Python quick tools | PySide6, or a local web UI (NiceGUI, Streamlit) |

Concerns: code signing (Apple notarization, Windows signing certificate), auto-update (Tauri updater, electron-updater), local data (SQLite), crash reporting (Sentry).

## 8. Browser extensions
- **WXT** (default): Manifest V3, Chrome/Firefox/Edge/Safari builds, HMR, any UI framework.
- Plasmo: alternative framework.
- Storage: `chrome.storage` (wrapped by WXT storage API); sync with your backend for accounts.
- Minimal permissions (stores reject over-broad requests); content security; publish to Chrome Web Store, Firefox AMO, Edge Add-ons.

## 9. CLI tools

| Language | Libraries | Distribution |
|---|---|---|
| Go | Cobra/urfave/cli, Bubble Tea + Lip Gloss (TUIs) | GoReleaser → GitHub Releases, Homebrew, Scoop |
| Rust | clap, ratatui (TUIs), indicatif | cargo-dist, crates.io, Homebrew |
| Python | Typer, Click, Rich, Textual (TUIs) | PyPI; users run via `uvx` or `pipx` |
| TypeScript | commander, citty, clack (prompts), Ink (React TUIs) | npm (`npx`), Bun compile for single binaries |

Rules: `--help` and `--version`, non-zero exit codes on failure, machine-readable output (`--json`), config via file + env + flags, respect `NO_COLOR`.

## 10. Cross-platform monorepo layout
```
repo/
├── apps/
│   ├── web/          # TanStack Start or Next.js
│   ├── mobile/       # Expo
│   ├── desktop/      # Tauri (optional)
│   └── api/          # Hono/FastAPI if separate from web
├── packages/
│   ├── db/           # Drizzle schema + migrations
│   ├── auth/         # Better Auth config shared
│   ├── validators/   # Zod schemas shared client/server
│   ├── ui/           # shared components (web) / design tokens
│   └── config/       # tsconfig, eslint/biome presets
├── turbo.json
└── pnpm-workspace.yaml
```
Starters worth checking: create-t3-turbo (Next + Expo), Better-T-Stack CLI (mix-and-match TS stack scaffolder).
