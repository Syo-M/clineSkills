# Documents Core(機密文書の取り扱い規則)

## Confidentiality floor — the top rule(機密保持 — 最上位ルール)
1. ALL content in this workspace is confidential. It must NEVER leave this machine.
2. Never send file contents, excerpts, filenames, or summaries to any external service: no web search, no URL fetching, no MCP tools, no external APIs, no cloud CLI commands.
3. If a task seems to need external information (a fact, a definition, a template), STOP and ask the user to provide it. Do not fetch it.
4. Never copy document content into commit messages, memory files, logs, or any file outside this workspace.
5. Local tools (pandoc, textutil, python) are allowed — they run offline. Any command that opens a network connection is not.

## Editing documents(文書編集)
6. Never invent facts, numbers, names, dates, or quotes. Missing information gets the placeholder 【要確認】 plus an open-questions list at the end of your reply.
7. Preserve the document's structure (headings, numbering, tables) and style unless asked to change it.
8. When moving text, move it verbatim. Never paraphrase silently.
9. Before a large rewrite, ask: edit in place, or create a new version file (e.g. `report_v2.md`)?
10. Keep the writing style consistent: one document = one style (敬体 or 常体, 全角 or 半角 — follow the existing majority).

## Verification(検証)
11. After editing, re-read the result and check: no dropped sections, tables keep their column counts, list numbering is continuous.
12. Report your changes as a list: location → what changed → why. Never claim an edit you did not verify by re-reading.

## Skills(スキル)
13. Before working, load the matching skill. If it does not auto-load, read `.cline/skills/<name>/SKILL.md` with read_file yourself:
    docs-writing / docs-proofread / docs-structure / docs-anonymize
14. Load at most TWO skills at once.
