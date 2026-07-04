<!-- 他ツール(Codex等)向けのコアルールミラー。任意でリポジトリルートにコピー。
     注意: ClineはAGENTS.mdも読むため、.clinerulesと併用すると二重読込になります。
     Clineで使う場合はRulesパネルでAGENTS.mdをOFFにしてください。 -->
# Agent Rules

1. TypeScript strict mode. React function components. CSS Modules with design tokens (`var(--...)`).
2. Never use `any`. Never use `@ts-ignore`.
3. Validate ALL external input with a zod schema at the server boundary. Client validation is UX only.
4. Never use `dangerouslySetInnerHTML` / `innerHTML` with non-static content without DOMPurify.
5. Never put secrets in client code, logs, or URLs. Session tokens in `HttpOnly`+`Secure`+`SameSite` cookies, never `localStorage`.
6. Semantic HTML first (`button`, not `div onClick`). Everything keyboard-operable. Every input labeled.
7. Work on one file at a time. Small diffs. No drive-by refactors.
8. You are done ONLY when typecheck (the repo's `typecheck` script, or `tsc --noEmit` via its package manager), lint, and affected tests pass. Paste the output. Never claim success with failing output.
9. Never guess an API or import path — read the file or search first.
10. Do not edit CI workflows, lockfiles, framework configs, or agent rule files without explicit approval.
