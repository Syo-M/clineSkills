# Edit Discipline(編集規律)

## Task decomposition(タスク分割)
1. Work on ONE file at a time. Finish and verify it before opening the next.
2. Keep each change small: one component, one function, or one fix per step.
3. Before editing, state a numbered plan of the files you will touch. If more than 3 files, propose splitting the task and stop.
4. If the conversation is long or you are unsure of earlier context, tell the user to run /newtask or /smol. Do not push on with degraded context.
5. No drive-by refactors. Change only what the task requires.
6. Read only what the task needs. Before opening a long file, use search_files to confirm it is the right one — every full-file read permanently consumes context.

## File editing(ファイル編集)
7. Before any edit, read the current file content. Never edit from memory of an old version.
8. Use replace_in_file with SMALL search blocks: 1-5 lines of exact, unique text.
9. Copy the search text EXACTLY from the file you just read, including whitespace and indentation.
10. If replace_in_file fails once: re-read the file, then retry with a smaller, more exact block.
11. If replace_in_file fails twice on the same file: STOP retrying and count the file's lines first.
12. File is 150 lines or fewer → rewrite it completely with write_to_file. Longer than 150 lines → do NOT full-rewrite (truncation risk); try ONE smaller replace block, and if that fails too, report and ask the user.
13. After write_to_file, re-read the file and compare against what you read before: same imports, same exported names, similar line count. Restore anything missing before moving on.
14. Circuit breaker: after 4 failed edit attempts in one task (all files combined), STOP. Report exactly what failed and ask the user how to proceed.

## When unsure(不明時)
15. Unknown API signature: search the codebase or the package's type definitions. Never invent it.
16. Two valid approaches: pick the one this repo already uses.
17. Ambiguous requirement: ask the user. Guessing wastes more time than asking.
