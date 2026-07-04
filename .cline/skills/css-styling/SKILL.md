---
name: css-styling
description: CSS Modules, design tokens, variants, responsive layout, dark mode, motion, and design-system consistency. Use when styling components, editing any CSS file, defining tokens, adding animations, or implementing Figma designs. 日本語:「スタイル」「見た目」「デザイン調整」「ダークモード」「レスポンシブ」「CSS」「アニメーション」「トークン」「Figma」
---
# CSS & Styling(スタイリング)

## Files & naming
1. One module per component, colocated: `UserCard.tsx` + `UserCard.module.css`. Import as `styles`.
2. Class names camelCase (`primaryButton`), named by role not appearance (`.errorMessage`, not `.redText`). No BEM prefixes.

## Design tokens(デザイントークン)
3. All colors, spacing, radii, shadows, typography, z-index live as CSS custom properties in `src/styles/tokens.css` on `:root`.
4. Component modules consume tokens ONLY: `var(--color-action)`. A raw hex/px value for a themable property in a component module is a bug.
5. Token tiers: primitive (`--blue-600`, never used in components) → semantic (`--color-action`, what components consume) → component (`--button-height-md`, only when needed).
6. Spacing on a scale (`--space-1` … `--space-8`). Z-index from a fixed ladder (`--z-dropdown`, `--z-modal`, `--z-toast`) — never `z-index: 9999`.
7. Dark mode: redefine tokens under `prefers-color-scheme` or `[data-theme]`. Components never branch on theme themselves.
8. Every new token gets a value for every theme at creation time.

## Variants & state(バリアント)
9. Variants via data attributes, not class string concatenation:
```tsx
<button className={styles.button} data-variant={variant} data-size={size}>
```
```css
.button[data-variant='danger'] { background: var(--color-danger); }
```
10. Boolean UI state the same way (`data-open`); style off ARIA attributes when one exists: `[aria-expanded='true']`.
11. `clsx` has one job: merging a consumer-passed `className` with the base class. 3+ conditional classes → restructure into variants.

## Layout & responsive
12. Mobile-first: base styles, then `@media (min-width: …)` upward.
13. Flex `gap` / grid over margin hacks. `aspect-ratio` for media boxes. Container queries for container-adaptive components.
14. Logical properties (`margin-inline`, `padding-block`, `inset-inline-start`) over physical ones — free RTL support.
15. No fixed heights on text containers; use `min-height` if needed.

## Globals
16. `src/styles/` contains exactly: `tokens.css`, `reset.css`, `globals.css`. Nothing else is global.
17. No `:global()` in component modules except for third-party DOM — with a comment naming the library.

## Motion(モーション)
18. Animate `transform` and `opacity` only. Never animate `width/height/top/left`.
19. Escalation ladder: CSS transition → CSS keyframes → Web Animations API → animation library (last resort, ask the user first — never add a library for a fade).
20. Every significant animation respects `@media (prefers-reduced-motion: reduce)`: remove decorative motion; reduce state-conveying motion to a quick fade, not deleted.
21. Durations/easings as tokens (`--duration-fast`, `--ease-out`). UI feedback stays 100–250ms.
22. Never gate content behind an entrance animation. Never start the LCP element at `opacity: 0`.
23. Exit animations: keep the element mounted until `transitionend`/`animationend`, then unmount.

## Design-system consistency(デザインシステム)
24. Same variant vocabulary everywhere: `variant`, `size` (`sm/md/lg`). No per-component synonyms (`kind`, `appearance`).
25. Shared components accept `className` (merged onto the root) and forward `ref`; spread remaining DOM props onto the root.
26. One icon system: SVG-as-component, sized via tokens, `fill="currentColor"`. Decorative icons `aria-hidden="true"`; icon-only buttons need `aria-label`.
27. Type scale as tokens (`--text-sm` … `--text-2xl`), sizes in `rem`, line-height unitless. Body text `max-inline-size: 65ch`.
28. From Figma: map every value to the nearest existing token — never hardcode inspect-panel pixels. Auto-layout maps to flex/grid + `gap`. Resolve what the mock doesn't show: responsive, focus/hover, loading/error/empty, long text, dark theme.
