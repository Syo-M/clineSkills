# Anonymize(匿名化)

1. Load the `docs-anonymize` skill (read `.cline/skills/docs-anonymize/SKILL.md` if not loaded).
2. Confirm with the user: the target file, and where/why the result will be shared (this decides how aggressive to be — skill rule 7).
3. Read the whole file. Build the replacement map: real value → placeholder ({PERSON_A}, {COMPANY_B}, ...). Same value = same placeholder, always.
4. Show 3-5 sample replacements from the map. WAIT for approval.
5. Create the copy `<name>_anon.<ext>` and apply the full map. NEVER touch the original.
6. Save the map to `<name>_anon_map.md` with the confidentiality header line (skill rule 4).
7. Verify: search the copy for EVERY real value in the map — including tables and URLs. Report: "残存チェック: 0件" or list what was found and fix it.
8. Final report: files created, number of replacements per category, open questions (quasi-identifiers left as-is).
