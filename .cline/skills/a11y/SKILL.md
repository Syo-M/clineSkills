---
name: a11y
description: Accessibility rules — semantic HTML, keyboard support, focus management, forms, ARIA, contrast, testing. Target WCAG 2.2 AA. Use when building UI components, forms, dialogs, menus, navigation, or fixing accessibility issues. 日本語:「アクセシビリティ」「キーボード操作」「フォーカス」「スクリーンリーダー」「コントラスト」「a11y」
---
# Accessibility(アクセシビリティ)

Target: WCAG 2.2 AA. A11y is a build-time concern, not an audit-time patch.

## Semantic HTML first
1. Use the element that does the job: `<button>` for actions, `<a href>` for navigation, `<label>`+input for forms, `<nav>/<main>/<header>` landmarks.
2. Real heading hierarchy: one `<h1>`, no level skipping.
3. `<div onClick>` is never acceptable. If the design demands a non-button look, style a `<button>`.
4. First rule of ARIA: do not use ARIA when an HTML element provides the semantics. ARIA adds keyboard promises you must then implement by hand.

## Keyboard(キーボード)
5. Everything mouse-operable is keyboard-operable: Tab reaches it, Enter/Space activates it, Escape dismisses overlays, arrow keys move within composite widgets (menus, tabs, listboxes).
6. Visible focus indicator always. Never `outline: none` without an equal-or-better `:focus-visible` style.
7. DOM order = visual order = tab order. `tabindex` greater than 0 is banned.

## Focus management(フォーカス管理)
8. Dialogs/drawers: focus moves in on open, is trapped while open, returns to the trigger on close. Prefer native `<dialog>` or a headless library (Radix, React Aria) over hand-rolling.
9. Client-side route change: move focus to the new page's heading or announce via a live region.
10. If the focused element is removed, move focus somewhere sensible — not `<body>`.

## Forms
11. Every input has a programmatic label (`<label htmlFor>`). A placeholder is not a label.
12. Errors: `aria-describedby` linking field to message, `aria-invalid` on the field, focus moves to the first error on submit failure. Error text says HOW to fix.
13. Do not use a disabled submit button as the only validation feedback.

## Content & visuals
14. Contrast: text ≥ 4.5:1 (3:1 for large text), UI component boundaries ≥ 3:1. Fix at the token level.
15. Color is never the sole signal — pair with text or icon.
16. Meaningful images: `alt` describing function. Decorative: `alt=""`. Icon-only buttons: `aria-label`.
17. Async updates (toasts, validation) announce via `aria-live="polite"` regions that exist in the DOM before the update.
18. Respect `prefers-reduced-motion` for significant animation.

## Testing
19. Automated (axe) catches ~30-40%. Keyboard-walk every new interactive component (Tab/Enter/Escape/arrows) as part of done.
20. Query tests with `getByRole(…, { name })` — if the role query can't find it, assistive tech can't either.
