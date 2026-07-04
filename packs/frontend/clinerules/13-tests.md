---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/*.stories.*"
  - "**/e2e/**"
  - "**/playwright/**"
---

# Test Tripwire(テスト編集時の強制ルール)

You are editing tests. Pick the layer FIRST:

1. Load the `testing` skill now if it is not loaded.
2. Pure logic → Vitest unit test. Component behavior → Storybook story + play function. Cross-page journey → Playwright E2E. Visual appearance → VRT over stories.
3. Query priority: `getByRole` with accessible name first. `data-testid` is the last resort.
4. No fixed sleeps (`waitForTimeout`, `setTimeout`). Use auto-retrying assertions (`findBy*`, `await expect(locator)`) and fake timers.
5. Mock at the network boundary with MSW. Never `vi.mock` your own modules to make a test pass.
6. A test asserting implementation details (internal state, generated class names) should be deleted, not repaired.
