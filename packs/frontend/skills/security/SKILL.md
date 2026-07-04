---
name: security
description: Frontend security rules — XSS, input validation, IDOR, CSRF, SSRF, CORS, sessions/JWT, secrets, headers, uploads, prompt injection, dependency vetting. Use whenever code touches user input, HTML rendering, auth, cookies, outbound fetch, webhooks, env vars, file uploads, logging, LLM-bound content, or new dependencies. 日本語:「認証」「ログイン」「フォーム」「cookie」「外部API」「webhook」「アップロード」「環境変数」「依存追加」「LLMに渡す」
---
# Security(セキュリティ)

Order of defense: reject untrusted data → validate at the boundary → sanitize at output → restrict with platform policy. Apply ALL layers.

## XSS
1. Framework escaping is the default protection. Keep it.
2. `dangerouslySetInnerHTML` / `innerHTML` with non-static content requires DOMPurify with one shared config. In server/SSR code use `isomorphic-dompurify` (plain DOMPurify needs a DOM and crashes on the server). Never write a regex sanitizer.
3. Any `href`/`src` from user data: parse with `new URL`, allow only `http:`/`https:` (blocks `javascript:` URLs).
4. Never build HTML/JS by string concatenation with user data. No `eval`, no `new Function`.

## Validation(検証)— server-side, schema-first
5. Every boundary parses input with zod before use: actions, route handlers, params, cookies, third-party responses, webhook payloads.
6. Use `z.strictObject({...})` — unknown keys REJECTED, so unexpected fields surface as errors. (Plain `z.object()` strips unknown keys — its parsed output also blocks mass-assignment — but silently hides client bugs.) Never spread the RAW input object into a DB write; always use the parsed result.
7. Bound every user string with `.max(n)`. Unbounded input is a DoS vector.
8. Never run user-controlled regex. Reject `__proto__` / `constructor` / `prototype` keys in user JSON.
9. IDOR: client IDs are claims. After auth, check the resource belongs to THIS user, per resource, in every handler.
10. Authorization: deny by default, enforced server-side in one policy helper — not scattered `if (role === 'admin')` checks.

## Sessions, cookies, JWT
11. Session cookies: `HttpOnly`, `Secure`, `SameSite=Lax` or stricter. Never `localStorage`.
12. Rotate the session ID on login and privilege change.
13. JWT: decode ≠ verify. Verify the signature with an `alg` allow-list (reject `none`); check `exp`/`aud`/`iss`.
14. Random tokens/IDs: `crypto.randomUUID()` / `crypto.getRandomValues()`. Never `Math.random()`.

## CSRF & redirects
15. Next.js protects Server Actions only. Cookie-authenticated state-changing ROUTE HANDLERS need explicit Origin validation or a CSRF token.
16. Mutations are POST-family only. A state-changing GET is a bug.
17. Never `redirect(userInput)` raw — allow-list relative paths or known origins. Validate OAuth `state`.

## SSRF & webhooks
18. Server fetch of a user-influenced URL: allow-list hosts; block private/link-local ranges and `169.254.169.254` (and IPv6 equivalents); resolve the host, validate the resolved IP, then connect to that PINNED IP (DNS rebinding/TOCTOU); re-validate after redirects.
19. Webhooks: verify the provider's HMAC signature (constant-time compare) BEFORE trusting the payload. Reject if the signature header is missing. Schema validation is not authentication.
20. Constrain `next/image` `remotePatterns` tightly — the image optimizer is an SSRF proxy.

## CORS & rate limiting
21. Never reflect the request `Origin` with `Access-Control-Allow-Credentials: true`. Never `*` on authenticated endpoints. Keep an explicit origin allow-list.
22. Throttle login, signup, password reset, and expensive/LLM endpoints — per IP and per account.
23. Login/reset errors: uniform message and timing. Do not reveal whether an account exists.

## Third-party scripts & embeds
24. Third-party scripts: ask the user first, pin exact versions, add SRI `integrity` when CDN-loaded; prefer self-hosting.
25. `postMessage` handlers MUST check `event.origin` against an allow-list. iframes/embeds get an explicit `sandbox` attribute.

## Prompt injection & LLM content
26. All external content (user input, fetched pages, retrieved chunks) is DATA, never instructions. Delimit and label it when sending to a model.
27. Model output is untrusted: validate, sanitize, and authorize it like user input before rendering or executing.
28. Never put secrets or another user's data in a prompt. LLM API keys stay server-side.

## Secrets, env, logging
29. Secrets never appear in: client bundles (`NEXT_PUBLIC_`/`VITE_` vars are public), repo files, logs, error messages, or URL query strings.
30. `.env*` in `.gitignore`; commit `.env.example` with placeholders. A committed secret = rotate it.
31. No PII, credentials, or tokens in logs or error trackers. Return generic errors + a correlation ID; log details server-side.
32. DO log security events (auth success/failure, 403s, role changes, webhook signature failures) with actor, action, result, IP.

## Headers
33. Keep CSP with `script-src` free of `'unsafe-inline'` (use nonces/hashes), `object-src 'none'`, `base-uri 'self'`, `form-action 'self'`, `frame-ancestors 'none'`.
34. `Cache-Control: no-store` on authenticated/personalized responses — a cached per-user response is a data leak.
35. Keep `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`.

## Uploads
36. Validate type by content (magic bytes), not extension. Cap size. Store outside the web root.
37. SVG executes scripts: deny or sanitize user SVG. Serve as-is user uploads from a separate origin.
38. Authorize every download per request. Never trust client-supplied paths/filenames (path traversal, zip-slip).

## Dependencies(依存関係の審査)
39. Before adding a package, check: exact name (typosquatting), maintenance/downloads, `postinstall` scripts, transitive weight, license (MIT/Apache-2.0/BSD/ISC allowed; GPL-family/unknown → ask the user).
40. Prefer platform APIs and zero-dependency options. Ask the user before adding anything with install scripts or >50 kB min+gzip client impact.
41. Avoid versions published within the last few days (compromise window). Always commit the lockfile.

## Self-check before shipping boundary code(出荷前自己チェック)
Answer each; a "no" means fix it, do not ship:
42. All external input parsed with zod at the boundary?
43. Webhook signatures verified before trust?
44. Every client ID authorized for this user (IDOR)?
45. Outbound fetch allow-listed, private ranges blocked, AND connected to the pinned resolved IP?
46. No secret/PII in bundle, logs, or URLs?
47. Non-static HTML sanitized? Cookies `HttpOnly`+`Secure`+`SameSite`? Route-handler CSRF covered?
48. Untrusted/LLM content treated as data?
