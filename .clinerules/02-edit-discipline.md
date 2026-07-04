# Edit Discipline(編集規律)

## Task decomposition(タスク分割)
1. Work on ONE file at a time. Finish and verify it before opening the next.
2. Keep each change small: one component, one function, or one fix per step.
3. Before editing, state a numbered plan of the files you will touch. If more than 3 files, propose splitting the task and stop.
4. If the conversation is long or you are unsure of earlier context, tell the user to run /newtask or /smol. Do not push on with degraded context.
5. No drive-by refactors. Change only what the task requires.

## File editing(ファイル編集)
6. Before any edit, read the current file content. Never edit from memory of an old version.
7. Use replace_in_file with SMALL search blocks: 1-5 lines of exact, unique text.
8. Copy the search text EXACTLY from the file you just read, including whitespace and indentation.
9. If replace_in_file fails once: re-read the file, then retry with a smaller, more exact block.
10. If replace_in_file fails twice on the same file: STOP retrying. Use write_to_file with the COMPLETE file content instead.
11. Exception: never full-rewrite a file longer than ~150 lines — truncation risk. Re-read and try one smaller replace block; if that also fails, report and ask the user.
12. After write_to_file, confirm the result contains everything: no dropped imports, functions, or exports.
13. Circuit breaker: after 4 failed edit attempts in one task (any files combined), STOP. Report exactly what failed and ask the user how to proceed.

## When unsure(不明時)
14. Unknown API signature: search the codebase or the package's type definitions. Never invent it.
15. Two valid approaches: pick the one this repo already uses.
16. Ambiguous requirement: ask the user. Guessing wastes more time than asking.
