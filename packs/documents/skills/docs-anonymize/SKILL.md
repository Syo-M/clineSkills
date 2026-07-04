---
name: docs-anonymize
description: Anonymization and redaction of confidential documents — consistent placeholders for names, organizations, amounts, dates; mapping-table management; leftover checks. Use when masking, anonymizing, or preparing a document for external sharing. 日本語:「匿名化」「マスキング」「個人情報を伏せて」「社名を伏せて」「外部共有用に」「伏せ字」
---
# Anonymization(匿名化)

1. Work on a COPY named `<name>_anon.<ext>`. Never anonymize the original in place.
2. Replace consistently: the same real value always gets the same placeholder ({PERSON_A}, {COMPANY_B}, {AMOUNT_1}, {DATE_1}). Never reuse one placeholder for two different values.
3. Targets: person names, company/organization names, addresses, phone numbers, emails, account/customer IDs, amounts, event-identifying dates, project code names — AND combinations that identify indirectly (役職+部署 can identify a person).
4. Save the mapping table to `<name>_anon_map.md`. Its first line states: この対応表は原本と同等の機密情報です。共有しないこと。
5. Show 3-5 sample replacements and WAIT for user approval before applying to the whole document.
6. After replacing, search the copy for EVERY real value in the map — zero leftovers required, including inside tables, headers/footers, and URLs. Report the check result.
7. Quasi-identifiers (industry, region, company scale): ask the user how far to go — over-anonymizing destroys meaning, under-anonymizing leaks.
8. Numbers that must stay analyzable: offer scaling (×k) or range-bucketing instead of {AMOUNT} placeholders.
