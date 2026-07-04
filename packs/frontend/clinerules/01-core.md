# Core Rules(コア規則)

## Stack
1. TypeScript strict mode. React function components only.
2. Styling: CSS Modules (`*.module.css`). No inline styles, no CSS-in-JS.
3. Detect the package manager from the lockfile. Use only that one.
4. Never use `any`. Use `unknown` + narrowing. `@ts-expect-error` needs a one-line reason. `@ts-ignore` is banned.

## Security floor(セキュリティ最低ライン)
5. Validate ALL external input (body, params, form data, cookies, API responses) with a zod schema at the server boundary. Client validation is UX only.
6. Never use `dangerouslySetInnerHTML` / `innerHTML` with non-static content. If unavoidable, sanitize with DOMPurify.
7. Never put secrets in client code, logs, or URLs. Client env vars only via `NEXT_PUBLIC_` / `VITE_` prefix — those are public by definition.
8. Session tokens: `HttpOnly` + `Secure` + `SameSite` cookies. Never `localStorage`.
9. Server fetch of a user-influenced URL: allow-list hosts, block private/metadata IP ranges.
10. Webhooks: verify the HMAC signature before trusting the payload.
11. Creating a NEW file under api/, actions/, auth/, webhooks/, a form, or a config path: apply the matching tripwire rule file (.clinerules/10-14) yourself — path triggers may not fire for a file that does not exist yet. For boundary files, load the `security` skill first.

## A11y floor(アクセシビリティ最低ライン)
12. Semantic HTML first: `button` for actions, `a href` for navigation. Never `div onClick`.
13. Every interactive element must work with the keyboard (Tab, Enter/Space, Escape).
14. Every input has a `<label>`. A placeholder is not a label.
15. Never remove focus outlines without a visible replacement.

## Verification — never skip(検証)
16. You are done ONLY when these commands pass. Run them and paste the output:
    - the repo's `typecheck` script if package.json has one; otherwise `npx tsc --noEmit`
    - the repo's lint script (check package.json scripts)
    - tests for the changed files
17. If a command fails, report the error verbatim. Never claim success with failing output.
18. Never guess an API, import path, or config flag. If unsure it exists, read the file or search first.
19. If the repo has no lint or test script, say so and propose adding one. Never invent ad-hoc commands.
20. Match this repo's existing conventions over any general knowledge you have.

## Skills(スキル)
21. Before writing code, check the available skills for a match and load it first. If it does not auto-load, read `.cline/skills/<name>/SKILL.md` with read_file yourself — never claim a skill is loaded without its content in context:
    react-components / css-styling / testing / security / a11y / nextjs / data-media / i18n
22. Load at most TWO skills at once — pick the most specific. Three only when a workflow explicitly names three.
