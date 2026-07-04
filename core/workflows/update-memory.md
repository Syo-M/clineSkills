# Update Memory(メモリーバンク更新)

Refresh the lightweight memory bank. Hard cap: each file stays at 40 lines or fewer — delete stale content to stay under.

## Steps
1. Read `memory/project.md` and `memory/active.md`.
2. REWRITE `memory/active.md` completely (do not append). Sections:
   - `## Current goal` — one sentence.
   - `## Done this session` — bullet list.
   - `## Decisions` — each decision + a one-line why.
   - `## Next steps` — numbered.
   - `## Known issues` — bullet list.
3. Update `memory/project.md` ONLY if stack, commands, architecture, or conventions actually changed. It holds stable facts, not session state.
4. Delete anything stale or duplicated. Old "next steps" that are done disappear; decisions worth keeping forever move to `project.md ## Conventions`.
5. Show the diff of both files. WAIT for user approval before writing.
6. Confirm both files are ≤ 40 lines after the update.
