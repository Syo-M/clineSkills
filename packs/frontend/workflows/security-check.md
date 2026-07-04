# Security Check(セキュリティ点検 → 承認後に修正)

Two phases, in this exact order. **Phase 1 is inspection only — do NOT edit any file until the user approves in step 12.**

## Phase 1 — Inspect and report(点検・報告)
1. Load the `security` skill (read `.cline/skills/security/SKILL.md` with read_file if it is not loaded).
2. Establish scope: run `git diff` and `git status --short`; include any files the user named. List every boundary the code touches: external input, HTML output, outbound fetch, cookies/session, webhook, upload, env var, LLM-bound content.
3. Answer the checklist below by READING THE ACTUAL CODE PATH. Do not assume a helper validates just because its name suggests it.

## Checklist(チェックリスト)
4. External input (body / params / cookies / API response / webhook) parsed with a zod schema (`z.strictObject`, `.max(n)`) at the boundary?
5. Authentication present in every handler? Webhook signatures verified (constant-time) before trust?
6. Every client-supplied ID authorized for THIS user, per resource (IDOR)? Deny-by-default?
7. Outbound fetch of user-influenced URL: host allow-listed, private/metadata IP ranges blocked?
8. No secret / PII / token in the client bundle, logs, error payloads, or URLs?
9. Non-static HTML sanitized with DOMPurify? Session cookies `HttpOnly`+`Secure`+`SameSite`? Route-handler CSRF covered?
10. Untrusted or LLM-bound content handled as data, never as instructions?

## Report, then WAIT(報告して停止)
11. Output ONE table — a MISSING control is a finding too (e.g. "認証が存在しない" is a BLOCKER):

| Finding | file:line | Severity (BLOCKER/WARN) | Fix direction |

   Then the verdict: **SHIP** / **SHIP WITH FIXES** / **DO NOT SHIP**.
12. STOP. Ask the user: fix all / fix selected / fix none. **WAIT for the answer. Editing before approval is a violation of this workflow.**

## Phase 2 — Fix(承認された修正のみ)
13. Apply approved fixes ONE file at a time, following the edit discipline rules.
14. Re-run typecheck and lint; paste the output.
15. Re-answer the checklist (4-10) against the FIXED code. Report what is now covered and what still is not.
16. NEVER declare the code "safe" or "secure". Report exactly three things: what was checked, what was fixed, what remains unaddressed.
