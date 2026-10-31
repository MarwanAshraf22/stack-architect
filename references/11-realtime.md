# Realtime, Collaboration, Messaging

> Last reviewed: October 2026.

## Table of contents
1. Do you need realtime?
2. Transport options
3. Self-hosted realtime servers
4. Managed realtime services
5. Collaboration (CRDTs, multiplayer)
6. Local-first and sync engines
7. Notifications (push, email, SMS, in-app)
8. Scaling realtime

---

## 1. Do you need realtime?
- Data refreshes every few seconds is fine → **polling** or TanStack Query `refetchInterval`. Simplest.
- Server pushes updates one way (progress, notifications, live dashboards, AI token streaming) → **Server-Sent Events (SSE)**.
- Two-way low latency (chat, games, collaborative editing, presence) → **WebSockets**.
- Peer-to-peer media (video/voice calls, screen share) → **WebRTC** (via LiveKit, Daily, Agora, or Cloudflare Calls/Realtime).

## 2. Transport options
| Transport | Notes |
|---|---|
| Polling | Easy, cacheable, wasteful at scale |
| SSE | HTTP-based, auto-reconnect, works through proxies/CDNs, one-way; ideal for LLM streaming |
| WebSockets | Bidirectional; needs sticky connections and pub/sub across servers |
| WebTransport | Newer, HTTP/3-based; limited support — niche |
| WebRTC | Media and P2P data; needs TURN/STUN servers |
| MQTT | IoT devices; brokers like EMQX/Mosquitto; also over WebSockets for browsers |

## 3. Self-hosted realtime servers
- **Node/TS:** Socket.IO (rooms, reconnection, fallbacks; Redis adapter for multiple servers), ws / uWebSockets.js (raw, fast), Hono/Bun built-in WebSocket support.
- **Elixir Phoenix Channels / LiveView / Presence:** best-in-class for many concurrent connections.
- **Go:** gorilla/websocket, coder/websocket; Centrifugo (standalone realtime server with pub/sub, presence, history — language-agnostic, highly recommended for self-host).
- **Python:** FastAPI WebSockets, Django Channels.
- **Postgres-driven:** LISTEN/NOTIFY for small fan-out; logical replication for change feeds.
- **Cloudflare Durable Objects:** a stateful object per room/document with WebSocket hibernation — excellent for chat rooms, multiplayer, collaboration; PartyKit (now part of Cloudflare) builds on it.

## 4. Managed realtime services
- Pub/sub: Ably, Pusher Channels, PubNub.
- Backend platforms with realtime: Supabase Realtime (Postgres changes, broadcast, presence), Firebase (Firestore listeners), Convex (reactive queries).
- Chat-as-a-service: Stream Chat, Sendbird, CometChat.
- Video/voice: LiveKit (open source + cloud, also AI voice agents), Daily, Agora, Twilio Video alternatives, Cloudflare Realtime.

## 5. Collaboration (CRDTs, multiplayer)
- CRDT libraries: **Yjs** (default, mature ecosystem), Automerge, Loro.
- Sync providers for Yjs: Liveblocks (managed, also comments/presence/notifications), Hocuspocus (self-host, Tiptap), y-websocket, PartyKit/Durable Objects, Y-Sweet.
- Editors with collab: Tiptap, BlockNote, Lexical (with Yjs), ProseMirror.
- Canvas/whiteboard: tldraw (has multiplayer SDK), Excalidraw.
- Presence (cursors, avatars) and awareness are part of Yjs/Liveblocks.
- Persist document snapshots/updates to Postgres or R2; implement permissions per document; version history.

## 6. Local-first and sync engines
- Keep a local database on the client, sync with server: works offline, instant UI.
- Options: Zero (Rocicorp), Replicache, ElectricSQL (Postgres → clients), PowerSync (Postgres/Mongo ↔ SQLite, mobile-focused), Triplit, Jazz, InstantDB, TinyBase, LiveStore, Convex (online-first reactive).
- Choose when offline use, instant UX or field work (inspectors, drivers, crews) matters. Adds complexity in conflict resolution and permissions.

## 7. Notifications
- **In-app:** notifications table in Postgres + realtime push (SSE/WebSocket) or polling; unread counts cached.
- **Email:** transactional provider (see `12-supporting-services.md`), queued via jobs.
- **Mobile push:** FCM (Android), APNs (iOS); via Expo Notifications, OneSignal, or Firebase.
- **Web push:** Web Push API with VAPID keys.
- **SMS/WhatsApp:** Twilio, Vonage, Infobip, Unifonic, MessageBird; WhatsApp Business Cloud API (template messages need approval).
- **Orchestration (user preferences, digests, multi-channel):** Novu (open source), Knock, Courier, SuprSend.
- Respect user preferences, quiet hours and unsubscribe links.

## 8. Scaling realtime
- Multiple app servers → shared pub/sub (Redis/Valkey, NATS) so a message reaches users on any server.
- Sticky sessions at the load balancer for WebSockets (or use a dedicated realtime server like Centrifugo).
- Cloudflare proxies WebSockets; check timeout and plan limits.
- Track connection counts, message rates, memory per connection.
- Backpressure and message size limits; heartbeat/ping to detect dead connections.
- Store authoritative state in the database; realtime layer only delivers updates.
