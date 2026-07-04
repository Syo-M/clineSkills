# Pre-Ship Verification(出荷前チェック)

Run every gate below in order. Report each result VERBATIM. Never skip a gate silently.

## Gate 1 — Scope
1. Run: `git status --short` and `git diff --stat`
2. List the changed files. Classify each: boundary code / UI / styles / tests / config / sensitive path.

## Gate 2 — Typecheck
3. Run the repo's `typecheck` script; if none exists, run `npx tsc --noEmit`
4. If it fails: STOP. Paste the errors, fix them, then restart from Gate 2.

## Gate 3 — Lint
5. Run the repo's lint script (check package.json scripts; usually `npm run lint`).
6. Fix violations. Never disable a lint rule to pass. If a disable seems necessary, ask the user.

## Gate 4 — Tests
7. Run tests for the changed files and anything importing them.
8. If shared config, tokens, or shared utilities changed: run the FULL suite.
9. A failing or flaky test blocks shipping. Report it. Do not retry-loop it.

## Gate 5 — Scanners(機械スキャン — あれば実行)
10. If installed (`command -v gitleaks`): run `gitleaks dir .` (covers unstaged changes; on gitleaks older than 8.19 use `gitleaks detect --no-git`). Any finding blocks.
11. If installed (`command -v semgrep`) and a `.semgrep/` config exists: run it on the changed files.
12. If a tool is not installed, mark this gate SKIPPED (tool not installed) — never pretend it ran.

## Gate 6 — Self-check(自己点検)
Answer each question with yes or no:
13. Boundary code changed? → Does every input have a zod schema? Any new endpoint missing an auth check?
14. UI changed? → Keyboard operable? Labels present? Semantic elements used?
15. Any secret, `console.log`, TODO, or commented-out code left in the diff?

## Gate 7 — Handoff(引き継ぎ)
16. If Gate 1 found boundary code: tell the user to run /security-check in a NEW task.
17. If Gate 1 found UI changes: tell the user to run /a11y-check in a NEW task.
18. If Gate 1 touched sensitive paths (CI, lockfiles, configs, .clinerules): require explicit user sign-off.

## Report format(報告形式)
Output ONE table:

| Gate | Command | Result (verbatim summary) | PASS/FAIL/SKIPPED |

Then the verdict: **READY TO SHIP** or **NOT READY**, blocking items listed first.
Never describe a failure as "minor".
