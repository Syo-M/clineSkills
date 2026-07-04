# Retro(振り返り → ルール改善提案)

Turn this session's friction into rule improvements. Output is a PROPOSAL — never apply silently
(`.clinerules/**` is on the sensitive-path list and needs explicit user approval).

## Gather(収集)
1. From this session: moments where the user corrected you, rejected an approach, or re-asked something a rule should have answered.
2. Run `git log --oneline -20`. Repeated fix-up commits (`fix:` right after `feat:` on the same files) are rule-gap evidence.

## Filter(選別)— a candidate deserves a rule only if ALL are true:
3. It happened twice, or cost real time once, AND generalizes beyond today's file.
4. It is not already covered. Grep the relevant rule/skill first. If covered but it did not fire, the fix is the skill's `description` (trigger), not a new rule — say which.
5. It is decidable: "prefer X" is not a rule; "X unless Y, because Z" is.

## Propose(提案)
For each candidate (max 3), output:
6. **Target file**: one `.clinerules/*.md` or `.cline/skills/*/SKILL.md`.
7. **The 1-3 line addition**, written in the target file's voice (numbered imperative).
8. **Evidence**: the concrete moment that motivated it.
9. Also propose DELETIONS for rules nobody has hit in months (security/a11y rules are exempt).

## Finish
10. Show the proposals as ready-to-apply diffs. WAIT for user sign-off before editing anything.
11. After the user approves and the edits are applied: append a one-line entry to `.cline/ruleset-changelog.md` in THIS project (create the file if missing), with the date and what changed.
12. Remind the user: copy the approved diff back to the ruleset source repo (cline_local_skills) and its CHANGELOG.md — otherwise the improvement is overwritten on the next install (locally edited rules are backed up to `.cline/rules-backup-*`, not merged).
