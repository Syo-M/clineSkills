# A11y Check(アクセシビリティ点検 → 承認後に修正)

Two phases, in this exact order. Judge against WCAG 2.2 AA. **Phase 1 is inspection only — do NOT edit any file until the user approves in step 12.**

## Phase 1 — Inspect and report(点検・報告)
1. Load the `a11y` skill (read `.cline/skills/a11y/SKILL.md` with read_file if it is not loaded).
2. Scope: the changed components (`git diff`, plus files the user named) and every state they render (open/closed, error, loading, empty).
3. Answer the checklist below by READING THE ACTUAL JSX — not the component name.

## Checklist(チェックリスト)
4. Semantic elements (`button`, `a[href]`, `input`) — or a div pretending? Custom widgets need the full keyboard contract (arrow keys, Escape) and correct role/state attributes.
5. Focus: where does it go on mount, open, close, and deletion of the focused item? Trapped in modals and returned to the trigger after?
6. Every input has a programmatic label? Errors linked via `aria-describedby` and announced (live region)?
7. Anything conveyed by color or icon alone? Focus outlines visible on every focusable element?
8. Does motion respect `prefers-reduced-motion`?
9. Async updates (toasts, validation) announced via an `aria-live` region that exists before the update?
10. Does a story's play function cover the keyboard path?

## Report, then WAIT(報告して停止)
11. Output ONE table, ranked by user impact (blocks task > degrades task > polish) — a MISSING affordance is a finding too:

| Finding | file:line | Affected users | WCAG criterion | Fix direction |

   Then the verdict: **PASS** / **FAIL** (blocking issues first).
12. STOP. Ask the user: fix all / fix selected / fix none. **WAIT for the answer. Editing before approval is a violation of this workflow.**

## Phase 2 — Fix(承認された修正のみ)
13. Apply approved fixes ONE file at a time, following the edit discipline rules.
14. Re-run typecheck and lint; paste the output.
15. Re-answer the checklist (4-10) against the FIXED code. Report what is now covered and what still is not.
16. NEVER declare the UI "fully accessible". Report exactly: what was checked, what was fixed, what remains unaddressed.
