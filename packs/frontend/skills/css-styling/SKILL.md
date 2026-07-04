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
6. Spacing on a scale (`--space-1` … `--space-8`). Z-index from a fixed ladder — never a raw integer, positive OR negative. The ladder INCLUDES a behind-content layer for decorative backgrounds/watermarks: `--z-behind: -1`, `--z-base: 0`, `--z-dropdown: 100`, `--z-modal: 300`, `--z-toast: 400`. A background element sits at `var(--z-behind)`, never a raw `z-index: -1`.
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
11. `clsx` has one job: merging a consumer-passed `className` with the base class. 3+ conditional classes → restructure into variants. A component that accepts `className` MUST merge it with its own classes (`` `${styles.base} ${className ?? ''}` ``), never let a spread `{...rest}` overwrite the base class.
12. Data-driven CONTINUOUS values (a bar's height from data, a progress %, a computed position) are the one sanctioned use of the inline `style` prop — set a CSS custom property and consume it in the module: `style={{ '--bar-h': `${pct}%` } as CSSProperties}` + `.bar { block-size: var(--bar-h); }`. Two lint escape hatches are needed because both rules assume static styling: on the TSX line, `// eslint-disable-next-line react/forbid-dom-props -- data-driven <what>`; on the CSS line, `/* stylelint-disable-next-line csstools/value-no-unknown-custom-properties -- injected at runtime via style */` (the var is runtime-injected, not a token). Enumerated states still use data-attributes (rule 9), never inline style.

## Layout & responsive
13. Mobile-first: base styles, then `@media (min-width: …)` upward.
14. Flex `gap` / grid over margin hacks. `aspect-ratio` for media boxes. Container queries for container-adaptive components.
15. Logical properties (`margin-inline`, `padding-block`, `inset-inline-start`) over physical ones — free RTL support.
16. No fixed heights on text containers; use `min-height` if needed.

## Globals
17. `src/styles/` contains exactly: `tokens.css`, `reset.css`, `globals.css`. Nothing else is global.
18. No `:global()` in component modules except for third-party DOM — with a comment naming the library.

## Motion(モーション)
19. Animate `transform` and `opacity` only. Never animate `width/height/top/left`.
20. Escalation ladder: CSS transition → CSS keyframes → Web Animations API → animation library (last resort, ask the user first — never add a library for a fade).
21. Every significant animation respects `@media (prefers-reduced-motion: reduce)`: remove decorative motion; reduce state-conveying motion to a quick fade, not deleted.
22. Durations/easings as tokens (`--duration-fast`, `--ease-out`). UI feedback stays 100–250ms.
23. Never gate content behind an entrance animation. Never start the LCP element at `opacity: 0`.
24. Exit animations: keep the element mounted until `transitionend`/`animationend`, then unmount.

## Design-system consistency(デザインシステム)
25. Same variant vocabulary everywhere: `variant`, `size` (`sm/md/lg`). No per-component synonyms (`kind`, `appearance`).
26. Shared components accept `className` (merged onto the root) and forward `ref`; spread remaining DOM props onto the root.
27. One icon system: SVG-as-component, sized via tokens, `fill="currentColor"`. Decorative icons `aria-hidden="true"`; icon-only buttons need `aria-label`.
28. Type scale as tokens (`--text-sm` … `--text-2xl`), sizes in `rem`, line-height unitless. Body text `max-inline-size: 65ch`.
29. From Figma: map every value to the nearest existing token — never hardcode inspect-panel pixels. Auto-layout maps to flex/grid + `gap`. Resolve what the mock doesn't show: responsive, focus/hover, loading/error/empty, long text, dark theme.
