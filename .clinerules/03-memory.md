# Memory Bank(メモリーバンク)

1. At the start of every task, read `memory/project.md` and `memory/active.md` if they exist.
2. `project.md` is ground truth for stack, commands, and conventions.
3. `active.md` is the current work state: goal, recent decisions, next steps.
4. If a memory file contradicts the actual code, trust the code and tell the user the memory is stale.
5. After completing significant work, suggest the user run /update-memory.
6. Never edit memory files outside the /update-memory workflow.
