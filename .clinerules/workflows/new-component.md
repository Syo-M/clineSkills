# New Component(新規コンポーネント作成)

Build ONE file at a time. Verify each step before the next. A component without its story is not done.
Load the `react-components` and `css-styling` skills first. For a custom widget (menu, dialog, tabs), this workflow explicitly allows a THIRD skill: also load `a11y`.

## Step 1 — Locate & name
1. Check sibling components for the directory convention. Repo convention beats this file.
2. One directory: `Component.tsx`, `Component.module.css`, `Component.stories.tsx`.
3. State the plan (3 files) and confirm the name/location with the user if ambiguous.

## Step 2 — Props contract
4. Write `type Props = {...}` first. Required props minimal. Variants as string unions, not boolean explosions. Events named `onX`.

## Step 3 — Component.tsx
5. Semantic element first (`button`, not `div onClick`). Custom widget? Full keyboard contract before styling.
6. Named export. Destructure props in the signature. No `React.FC`, no `any`.
7. Verify now: the repo's `typecheck` script; if none, `npx tsc --noEmit`. Fix before continuing.

## Step 4 — Component.module.css
8. Consume design tokens only (`var(--...)`). Variants via `data-variant` attributes, not class concatenation.
9. Verify now: run the lint script. Fix before continuing.

## Step 5 — Component.stories.tsx
10. CSF3 (`satisfies Meta<typeof Component>`). One story per meaningful state: default, each variant, error/disabled, loading, empty.
11. Interactive behavior gets a `play` function — that IS the component test. `await` every interaction and assertion.
12. Include a keyboard-path assertion for interactive components.
13. Verify now: run the story tests via the repo's `test` script and its package manager. Fix before continuing.

## Definition of done(完了条件)
14. All 3 files exist. tsc + lint + story tests pass (paste the output). Tokens used throughout. Keyboard path covered.
15. If asked for "just the component, quickly": still deliver the story, and say so.
