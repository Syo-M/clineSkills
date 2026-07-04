---
name: docs-proofread
description: Proofreading rules for Japanese documents — typos, particle errors, notation inconsistency (表記ゆれ), terminology drift, numbering, format. Use when checking, correcting, or reviewing an existing document. 日本語:「校正して」「誤字脱字チェック」「表記ゆれ」「文章を直して」「推敲」「チェックして」
---
# Proofreading(校正)

## Procedure(手順)
1. Read the WHOLE document first. Note the dominant style (敬体/常体), notation choices, and terminology before flagging anything.
2. Pass 1 — mechanics: typos, missing/duplicated particles(てにをは), conversion errors(誤変換), doubled words(「ののため」).
3. Pass 2 — consistency: 表記ゆれ(全角/半角、漢字/ひらがな 例: 下さい/ください、送り仮名), terminology drift, heading/list numbering continuity, date and number formats.
4. Pass 3 — clarity: sentences over ~60 characters, double negatives, ambiguous modifiers(係り受け), redundant phrases.
5. Do NOT change meaning, tone, or structure while proofreading. Improvements beyond fixes are PROPOSALS, listed separately.

## Output format(出力形式)
6. Report as ONE table: | 位置(見出し/段落) | 原文 | 修正案 | 種別(誤字/表記ゆれ/文法/冗長) |
7. Apply fixes only after the user approves — unless asked to fix directly, in which case still output the table of what changed.
8. Uncertain items (proper nouns, possibly intentional usage): mark 【要確認】 in the table. Never silently "fix" what might be intentional.
