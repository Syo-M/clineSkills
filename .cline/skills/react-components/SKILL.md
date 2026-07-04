---
name: react-components
description: React component, hooks, and state conventions, plus Vite SPA structure. Use when creating or editing React components, custom hooks, state management, effects, or debugging re-renders. 日本語:「Reactコンポーネント」「カスタムフック」「状態管理」「再レンダリング」「useEffect」「コンポーネント作って」
---
# React Components(Reactコンポーネント)

Creating a brand-new component from scratch? Tell the user to run /new-component — it is the step-by-step pipeline.
Building a form? Load the `security` skill FIRST. Building charts/tables? Also load `data-media`.

## Components
1. Function components only. One exported component per file; file name matches component name (`UserCard.tsx`).
2. Named exports, not default exports. Exceptions: framework route/page files, config files, Storybook `meta`.
3. Props: `type Props = {...}` above the component. Destructure in the signature. No `React.FC`.
4. Keep components small: fetching + branching + layout + interaction in one component → split it.
5. Composition over configuration: `children` / slot props beat boolean prop explosions.
6. List `key` must be a stable ID from the data. Never the array index when items can reorder.

## State(状態)
7. Colocate state with the component that uses it. Lift only when actually shared.
8. Derive, don't sync: a value computable from props/state is computed during render — never mirrored into state with an effect.
9. Group related state into one object or `useReducer` when fields update together.
10. Context is for low-frequency global data (theme, locale, session). Frequently-changing shared state → a store or lifted state.

## Effects(副作用)
11. `useEffect` is ONLY for synchronizing with external systems (DOM APIs, subscriptions, non-React widgets).
12. NOT for: transforming data for render, handling user events, resetting state on prop change (use `key`), fetching when a framework loader or query library exists.
13. Every effect: complete dependency array (no lint suppression) + cleanup if it subscribes, schedules, or fetches (AbortController).
14. An effect that only calls `setState` from other state/props is a bug — replace with a derived value or event handler.

## Performance
15. Measure with the React DevTools Profiler BEFORE optimizing. Never add `memo`/`useMemo`/`useCallback` preemptively.
16. If the React Compiler is enabled (check the config), do not hand-write memoization at all.
17. `useId` for generated IDs. Never `Math.random()` in render.

## Errors & loading
18. Error boundaries at feature/route roots. Render a recovery UI, not a blank screen.
19. Prefer `Suspense` boundaries over manual `isLoading` flags where the framework supports them.

## Custom hooks
20. Extract a hook when stateful logic is reused. Name `useX`, return a stable minimal API.
21. A hook taking 5+ params or returning 8 fields is a component or store in disguise — restructure.

## Events & forms
22. Handler props named `onX`, internal handlers `handleX`.
23. Prefer uncontrolled inputs + FormData for plain forms. Controlled only for per-keystroke logic.

## Vite SPA structure(Vite SPAの場合)
24. Layout: `src/app/` (router, providers), `src/features/<name>/` (colocated feature code), `src/components/` (shared), `src/lib/`, `src/styles/`.
25. Features never import other features' internals — only via the feature's `index.ts`.
26. Only `VITE_`-prefixed env vars reach the client, via `import.meta.env`. Everything in a SPA bundle is public — secrets belong on a backend.
27. Code-split at route level: `React.lazy` + `Suspense` per route.
28. Server state via a query library (TanStack Query), not `useEffect` + `useState` fetching.
