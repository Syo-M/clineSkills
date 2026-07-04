---
name: testing
description: Test writing rules for Vitest units, Storybook play functions, Playwright E2E, and visual regression. Use when writing or fixing any test, story, spec, mock, or test config. 日本語:「テスト書いて」「ユニットテスト」「ストーリー」「play関数」「E2E」「モック」「スクショテスト」「テストが不安定」
---
# Testing(テスト)

## Pick the layer FIRST(レイヤー選択)
1. Pure logic (utils, reducers, formatting) → Vitest unit test.
2. Component behavior → Storybook story + play function. NOT a plain Vitest component test.
3. Cross-page user journey → Playwright E2E. Critical paths only.
4. Visual appearance → VRT over existing stories. Never screenshot what a DOM assertion can check.

Worked examples:
- "Button shows a spinner while submitting" → Storybook play function.
- "formatCurrency rounds half-up" → Vitest unit test.
- "useDebounce timing" → Vitest with fake timers.
- "Checkout flow end to end" → Playwright.

## Cross-layer invariants(全レイヤー共通)
5. Query priority: `getByRole` with accessible name > `getByLabelText` > `getByText` > `getByTestId` (last resort). Never query by placeholder.
6. No fixed sleeps (`waitForTimeout`, `setTimeout`). Use auto-retrying assertions: `findBy*`, `waitFor` (assertions only), `await expect(locator)`.
7. Mock at the network boundary with MSW. `vi.mock` only for true externals (analytics SDK). Never mock your own modules to make a test pass.
8. Test behavior users observe. Never assert internal state, generated class names, or spy on internals of the unit under test.
9. A flaky test is a bug to fix now — never retry-loop, skip, or loosen it.

## Vitest
10. Colocate: `format.ts` + `format.test.ts`. Test names are behavior sentences: `it('disables submit while the request is in flight')`.
11. Arrange–Act–Assert, one behavior per test. No if/loops computing expectations — expected values are literals.
12. All interactions via `userEvent.setup()`, never `fireEvent`.
13. Time: `vi.useFakeTimers()` + `vi.setSystemTime()`; always `vi.useRealTimers()` in `afterEach`. With fake timers + userEvent, use `userEvent.setup({ advanceTimers: vi.advanceTimersByTime })` — without it the test HANGS.
14. `vi.restoreAllMocks()` in `afterEach` — leaked mocks cause order-dependent flake.

## Storybook
15. CSF3 shape:
```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { expect, fn, userEvent } from 'storybook/test';
const meta = { component: LoginForm, args: { onSubmit: fn() } } satisfies Meta<typeof LoginForm>;
export default meta;
type Story = StoryObj<typeof meta>;
```
16. One story per meaningful state: default, each variant, loading, error, empty, edge content (long text).
17. Interactive behavior gets a `play` function — that IS the component test:
```tsx
export const ShowsValidationError: Story = {
  play: async ({ canvas, args }) => {
    await userEvent.click(canvas.getByRole('button', { name: /log in/i }));
    await expect(canvas.getByRole('alert')).toHaveTextContent(/required/i);
    await expect(args.onSubmit).not.toHaveBeenCalled();
  },
};
```
18. `await` EVERY interaction and assertion — a missing await flakes in CI.
19. Assert outcomes: error visible AND callback not called. Not just "no crash".
20. `fn()` for every callback prop. Providers go in `.storybook/preview.tsx` decorators once, not per story. Portals/modals render outside the canvas — query them via `within(canvasElement.parentElement!)`, not `canvas`.
21. Check the installed Storybook major version before using version-specific imports.

## Playwright
22. Locators: `getByRole(…, { name })` first. Never CSS/XPath tied to DOM structure or generated class names.
23. Web-first assertions only: `await expect(locator).toBeVisible()`. Banned: `page.waitForTimeout()`, `expect(await locator.isVisible())`.
24. Every test independent: own data, parallel-safe. Auth once per worker via `storageState` setup project; test the login flow itself in exactly one spec.
25. Gitignore `playwright/.auth/`. Only ephemeral test accounts — never real credentials.
26. Stub with `page.route()` for hard-to-trigger states. Never stub the thing the test verifies.
27. CI: `retries: 2`, `trace: 'on-first-retry'`. Local: 0 retries so flake is loud. A retried pass is a flake report.

## Visual regression
28. Stories are the VRT surface. Do not build a parallel screenshot harness.
29. Pin every flake source: mock the clock, fixture data via MSW, wait for `document.fonts.ready`, `animations: 'disabled'`, fixed viewport, generate baselines in the CI container (never mix macOS/Linux baselines).
30. Keep `maxDiffPixelRatio` ≤ 0.01. Mask genuinely dynamic regions instead of loosening thresholds.
31. Never auto-accept baselines. A diff is a regression to fix or an intended change to approve in the same PR.
