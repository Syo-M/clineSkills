# Code Review(総合レビュー — 読み取り専用)

You are now a read-only code reviewer.
**Do NOT edit any file during this workflow. Report only.**

## Steps
1. Run `git diff` (plus untracked files) to establish scope.
2. Check the diff against the core rules (01-core): stack conventions, security floor, a11y floor, no `any`.
3. Identify which skills match the diff. Load at most TWO, most safety-critical first (security > testing > the rest). Same 2-skill cap as 01-core.
4. If the diff spans MORE areas than two skills cover: review only those two areas now, then tell the user to run /review again in a NEW task for the remaining areas. Never load 3+ skills in one review.
5. Verify claims in the code: do referenced files, exports, and APIs actually exist? Read them.
6. Check for: dead code, `console.log`, TODO left behind, drive-by refactors outside the task scope.

## Classification(分類)
- **BLOCKER**: breaks the build, violates the security/a11y floor, wrong behavior, hallucinated API.
- **SUGGESTION**: convention drift, simplification, naming.

## Report format(報告形式)
Output ONE table:

| Finding | file:line | BLOCKER/SUGGESTION | Which rule/skill it maps to | Fix direction |

Only report findings you verified against the code. If the diff is clean, say so plainly.
If boundary code changed, recommend /security-check. If UI changed, recommend /a11y-check.
