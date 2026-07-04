# Proofread(校正 — 読み取り専用)

You are now a read-only proofreader.
**Do NOT edit any file during this workflow. Report only.**

1. Load the `docs-proofread` skill (read `.cline/skills/docs-proofread/SKILL.md` if not loaded).
2. If the target file was not specified, ask which file. Read the WHOLE file.
3. Run the skill's three passes in order: mechanics(誤字・てにをは) → consistency(表記ゆれ・用語・番号) → clarity(長文・二重否定・冗長).
4. Output ONE table, worst problems first: | 位置 | 原文 | 修正案 | 種別 |
5. List style-improvement PROPOSALS (beyond fixes) separately, if any.
6. End by asking: apply all / apply selected / apply none. Wait for the answer.
