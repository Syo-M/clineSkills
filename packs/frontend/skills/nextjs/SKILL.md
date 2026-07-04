---
name: nextjs
description: Next.js App Router rules — Server/Client Components, data fetching, caching, Server Actions, route handlers, env vars. Use for any work inside a Next.js project. 日本語:「Next.js」「Server Action」「ルートハンドラ」「RSC」「サーバーコンポーネント」「キャッシュ」
---
# Next.js App Router

Check the installed Next.js major version in package.json BEFORE using version-specific APIs. Caching semantics changed across 14 → 15 → 16 — never rely on remembered defaults.

## Server vs Client Components
1. Server Components are the default. Add `'use client'` only at interaction leaves (event handlers, state, browser APIs) — never on whole layouts/pages.
2. Push client boundaries down: pass Server Component output as `children` into client wrappers.
3. Never import server-only modules (DB clients, secrets) into client files. Add `import 'server-only'` to modules that must never reach the client.

## Data fetching
4. Fetch in Server Components, close to where data is used.
5. Parallelize independent fetches (`Promise.all` or separate components + Suspense). Sequential awaits are the #1 RSC perf bug.
6. `loading.tsx` / `<Suspense>` for streaming; `error.tsx` per segment; `notFound()` for missing resources.

## Caching
7. Be explicit about every fetch: static, revalidated, or dynamic. State the intent in code.
8. NEVER cache per-user or personalized responses — a cached per-user response is a data leak.
9. Tag cached data and invalidate after mutations (`revalidateTag`/`revalidatePath`). Do not sprinkle `router.refresh()` as a fix.

## Server Actions — treat as public HTTP endpoints
Every action, no exceptions:
10. Authenticate: verify the session INSIDE the action (middleware is not sufficient — actions are directly invokable).
11. Authorize: IDOR check on every ID argument — may THIS user act on THIS resource?
12. Validate: parse all arguments with zod. `FormData` fields are `unknown`, not `string`.
13. Return typed results (`{ ok: true, data } | { ok: false, error }`). Never throw raw DB errors to the client.
14. After mutation: revalidate, then `redirect()` if needed — `redirect` throws, call it OUTSIDE try/catch.

## Route Handlers
15. Same auth/validation rules as Server Actions, PLUS: route handlers get NO built-in CSRF protection — cookie-authenticated mutations need explicit Origin validation or a CSRF token.
16. Webhook endpoints verify the HMAC signature first (see the `security` skill).
17. Use route handlers only for genuine API needs (webhooks, third-party callbacks). Prefer Server Components for reads, Actions for mutations.

## Env vars & misc
18. `NEXT_PUBLIC_*` is compiled into the client bundle — public by definition. Secrets: no prefix, server code only.
19. Never pass secret-bearing objects as props to client components.
20. `<Link>` for internal navigation, `next/image` for images, `next/font` for fonts. Plain `<a>` is correct for external links.
21. Metadata via the `metadata` export / `generateMetadata`, not manual `<head>` tags.
22. `useSearchParams` needs a Suspense boundary.
23. Dynamic route params are user input — validate with zod before use.
