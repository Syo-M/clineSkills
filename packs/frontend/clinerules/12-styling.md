---
paths:
  - "**/*.module.css"
  - "**/*.css"
---

# Styling Tripwire(CSS編集時の強制ルール)

You are editing CSS.
**FIRST: restate in one line each which rules below apply to this change. THEN write the code.**

1. Load the `css-styling` skill now if it is not loaded.
2. Colors, spacing, radii, shadows, z-index come from design tokens: `var(--...)`. Raw values live only in the tokens file itself.
3. Before writing `var(--x)`: confirm that token EXISTS in the tokens file (read it). A `var()` referencing an undefined token silently does nothing — pick an existing token instead of inventing a name.
4. No `!important`. No ad-hoc z-index numbers — use the token ladder.
5. Selectors stay flat: single class selectors from this module. No `:global()` without a comment explaining why.
6. Any significant animation (anything beyond a subtle hover/focus transition) must respect `@media (prefers-reduced-motion: reduce)`.
