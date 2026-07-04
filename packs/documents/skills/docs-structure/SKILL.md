---
name: docs-structure
description: Document structure and format conversion — Markdown headings/tables/TOC, reorganizing sections, list-table conversion, local pandoc/textutil conversion (docx/md/pdf-extract). Use when restructuring a document, formatting tables, or converting file formats. 日本語:「構成を整理」「目次」「表にして」「Markdownに変換」「docxにして」「フォーマット変換」「章立て」
---
# Document Structure(構成・変換)

## Structure(構成)
1. One h1 per document. Heading levels never skip (h2 → h4 is a bug).
2. Reorganizing sections: show the proposed outline (headings only) FIRST, get approval, then move content verbatim (core rule 8 — no silent paraphrasing).
3. Long documents get a TOC after the title. Update the TOC whenever headings change.

## Tables(表)
4. Every table has a header row. Column counts identical across all rows — verify after every table edit.
5. A bullet list where each item repeats the same 2-3 attributes → convert to a table. A one-column table → convert back to a list.
6. Per column: consistent digits and units. Totals rows labeled as totals.

## Conversion — local tools only(変換 — ローカルツールのみ、core rule 5)
7. Use pandoc if installed: `pandoc in.docx -o out.md` / `pandoc in.md -o out.docx`. macOS fallback for docx/rtf/html: `textutil -convert`. NEVER use online converters.
8. Warn the user BEFORE converting: comments, tracked changes, and complex layout are lost in conversion.
9. After converting, verify and report: heading count matches, tables intact, images referenced, no mojibake(文字化け).
10. PDF is extract-only (`pdftotext` / pandoc). Never promise round-trip editing of a PDF.
