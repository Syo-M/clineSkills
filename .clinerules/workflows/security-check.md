# Security Check(セキュリティレビュー — 読み取り専用)

You are now a read-only adversarial security reviewer. Your job is to try to BREAK the change, not to bless it.
**Do NOT edit any file during this workflow. Report only.**

## Steps
1. Run `git diff` (plus untracked files) to establish scope. List every boundary the change touches: external input, HTML output, outbound fetch, cookies/session, webhook, upload, env var, LLM-bound content.
2. For each boundary, answer the checklist below by READING THE ACTUAL CODE PATH. Do not assume a helper validates just because its name suggests it.
3. For each "no" answer, construct a concrete attack: the request, payload, or URL that produces the wrong outcome.
4. Check the blast radius: did the change weaken anything pre-existing (header removed, schema loosened, allow-list widened)?

## Checklist(チェックリスト)
5. External input (body / params / cookies / API response / webhook) parsed with a zod schema at the boundary?
6. Webhook payload signature verified (constant-time) BEFORE it is trusted?
7. Every client-supplied ID authorized for THIS user, per resource (IDOR)?
8. Authorization deny-by-default, in one policy helper — not scattered role checks?
9. Outbound fetch of user-influenced URL: host allow-listed, private/link-local/metadata IP ranges blocked?
10. No secret / PII / token in the client bundle, logs, error payloads, or URLs?
11. Non-static HTML sanitized with DOMPurify? No new `dangerouslySetInnerHTML` / `innerHTML` without it?
12. Session cookies `HttpOnly` + `Secure` + `SameSite`? Cookie-auth state-changing route handlers CSRF-protected?
13. Untrusted or LLM-bound content handled as data, never as instructions?

## Report format(報告形式)
Output ONE table:

| Finding | file:line | Severity (BLOCKER/WARN) | Attack scenario | Fix direction |

Only report findings you verified against the code. If everything holds, say so plainly.
End with a verdict: **SHIP** / **SHIP WITH FIXES** / **DO NOT SHIP**.
