---
paths:
  - "**/*Form.*"
  - "**/*Form/**"
  - "**/*-form.*"
  - "**/*-form/**"
  - "**/forms/**"
---

# Form Tripwire(フォーム編集時の強制ルール)

You are editing a form — the most common place user input enters the system.

1. Load the `security` skill now if it is not loaded.
2. Re-validate on the server with a zod schema: `z.strictObject({...})`, `.max(n)` on every string. Client validation is UX only.
3. Treat the submit target (Server Action / route handler) as boundary code: parse input with zod, authenticate, and authorize the resource for THIS user there too.
4. Every input has a programmatic `<label>`. Errors are linked via `aria-describedby` and announced, not just painted red.
5. Prefer uncontrolled inputs + FormData for plain forms. Controlled inputs only for per-keystroke logic.
