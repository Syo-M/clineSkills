# Project Memory(プロジェクト固定情報)

<!-- 導入時に project.md にリネームし、このリポジトリの実情報で埋めてください。40行以内厳守。 -->

## Stack
- Framework: (e.g. Next.js 16 App Router / Vite + React 19)
- Language: TypeScript strict
- Styling: CSS Modules + design tokens in src/styles/tokens.css
- Package manager: (from the lockfile)

## Commands
- Typecheck: `npx tsc --noEmit`
- Lint: `npm run lint`
- Unit/story tests: `npm test`
- E2E: `npm run test:e2e`
- Dev server: `npm run dev`

## Architecture
<!-- 5行以内のディレクトリマップ。例: -->
- `src/app/` — routes and providers
- `src/features/<name>/` — feature code, colocated tests
- `src/components/` — shared UI
- `src/lib/` — framework-agnostic utilities

## Conventions
<!-- このリポジトリ固有の逸脱・決めごとのみ、5項目以内。一般ルールはskillsにあるので書かない。 -->
- (e.g. API client lives in src/lib/api.ts — always go through it)
