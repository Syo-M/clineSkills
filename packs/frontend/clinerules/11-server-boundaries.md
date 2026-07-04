---
paths:
  - "**/api/**"
  - "**/api.*"
  - "**/route.*"
  - "**/routes.*"
  - "**/actions.*"
  - "**/actions/**"
  - "**/server/**"
  - "**/server.*"
  - "**/*.server.*"
  - "**/middleware.*"
  - "**/webhooks/**"
  - "**/auth/**"
  - "**/oauth/**"
  - "**/sessions/**"
  - "**/login/**"
  - "**/payments/**"
  - "**/billing/**"
---

# Server-Boundary Tripwire(境界コード編集時の強制ルール)

You are editing server-side boundary code.
**FIRST: in your reply, restate in one line each which rule numbers below apply to this change. THEN write the code.** Rules you did not restate are the rules you will forget.

1. Load the `security` skill now if it is not loaded.
2. Parse ALL external input (body, params, cookies, headers, third-party responses) with a zod schema before use: `z.strictObject`, `.max(n)` on strings.
3. Client-supplied IDs are claims, not facts. Authorize the resource for THIS user in every handler (IDOR).
4. Cookie-authenticated state-changing route handlers need explicit CSRF protection. Next.js covers Server Actions only.
5. Webhooks: verify the provider's HMAC signature (constant-time) BEFORE trusting the payload.
6. Outbound fetch of a user-influenced URL: host allow-list + block private/link-local/metadata IP ranges + resolve the host once and connect to that pinned IP (DNS rebinding).
7. No secret, PII, or token in responses, logs, or error payloads.
8. Before finishing, run the `security` skill's self-check list against what you touched.
