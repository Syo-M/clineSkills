---
name: data-media
description: Charts, dashboards, data tables, images, fonts, and video — library choice, chart a11y, SSR issues, virtualization, responsive images, lazy loading, CLS/LCP, font loading. Use when building charts, KPI displays, any data table, or adding/optimizing images, fonts, video. 日本語:「グラフ」「チャート」「ダッシュボード」「テーブル」「一覧」「可視化」「画像」「フォント」「動画」「LCP」「画像が重い」
---
# Data & Media(データ可視化・メディア)

## Charts(チャート)
1. One charting library per repo. If one is installed, use it — never add a second. Default for new: Recharts. Denser/bespoke needs escalate deliberately (visx, D3 math, uPlot) — ask the user first, charting libraries are heavy.
2. Charts measure the DOM → render client-side. Next.js: `next/dynamic` with `ssr: false` inside a Client Component. SPA: `React.lazy`. Code-split the chart with its route.
3. Reserve space while loading: fixed `aspect-ratio` container + skeleton — a chart popping in is CLS.
4. Every chart has a text alternative: a one-sentence summary of what the data shows, plus the underlying data as a visually-hidden or toggleable `<table>`.
5. Color is never the only encoding — pair with labels or patterns. Colorblind-safe palette from tokens, not library defaults.
6. Hover-only tooltips hide data from keyboard/touch users — values must be reachable elsewhere.
7. Over ~1,000 points: aggregate or decimate server-side first. Canvas for genuinely dense plots.
8. Every chart designs its empty, loading, and error states — each is a story.

## Data tables(データテーブル)
9. Semantic `<table>` with `<th scope>`. Sort controls are real buttons with `aria-sort`.
10. Virtualize past a few hundred rows (TanStack Virtual). Big-dataset sorting/filtering happens server-side.
11. Numbers/dates through `Intl.NumberFormat` / `Intl.DateTimeFormat` — never hand-built strings. Store UTC, render in a deliberate zone, label it.

## Images(画像)— the two invariants
12. NO CLS: every image/video/embed has intrinsic dimensions — `width`+`height` attributes or CSS `aspect-ratio`. No exceptions.
13. The LCP element loads eagerly: hero images are never lazy-loaded (`priority` / `fetchpriority="high"`). Everything below the fold: `loading="lazy"` + `decoding="async"`.
14. Use the framework pipeline: `next/image` (constrain `remotePatterns` — SSRF surface) / `astro:assets`. Plain Vite: generate AVIF/WebP at build time, hand-rolled `srcset`+`sizes`.
15. `sizes` reflects actual rendered width per breakpoint — `sizes="100vw"` on a 400px card ships 3x the bytes.

## SVG
16. Styled/recolorable SVG: inline as a component with `fill="currentColor"`. Static decorative SVG: `<img>` is fine.
17. User-supplied SVG is executable content — never inline it (see `security`).
18. Decorative: `alt=""` / `aria-hidden="true"`. Meaningful: `alt` or `role="img"` + `aria-label`.

## Fonts(フォント)
19. Framework loader first (`next/font`). Otherwise: self-hosted `woff2` only, `font-display: swap`, preload the critical face, subset to used scripts.
20. Never load fonts via CSS `@import` or third-party CSS CDNs at runtime. Prefer one variable font over many static weights.

## Video
21. Short looping animation: `<video autoplay muted loop playsinline>` — never GIF.
22. Content video: `preload="metadata"`, a real `poster`, captions `<track>` required, never autoplay with sound.
23. Heavy embeds (YouTube): thumbnail facade, swap in the iframe on interaction.
