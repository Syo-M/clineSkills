---
name: i18n
description: Internationalization — message catalogs, ICU plurals, Intl formatting, locale routing, RTL, locale-aware input. Use when adding translations, multi-locale UI, date/number/currency formatting, language switching, or RTL support. 日本語:「多言語対応」「i18n」「翻訳」「ロケール」「日付表示」「通貨表示」「RTL」「言語切替」
---
# Internationalization(国際化)

## Message catalogs
1. Every user-visible string comes from a message catalog keyed by ID — never a literal in JSX.
2. One library per repo, framework-idiomatic: `next-intl` (Next.js) / `react-i18next` (Vite SPA).
3. Keys are semantic and namespaced (`checkout.payment.submit`), not the English text.
4. Never concatenate sentence fragments across keys — word order differs per language.

## Plurals & interpolation — ICU MessageFormat
5. Never `count === 1 ? 'item' : 'items'` — languages have 3-6 plural categories. Use ICU `{count, plural, ...}`.
6. Interpolate variables through the catalog (`{name}`), never template-string concatenation around a translated fragment.
7. Rich/linked text: the library's component interpolation (`<Trans>` / `t.rich`), never `dangerouslySetInnerHTML` on a translated string.

## Formatting — always Intl, never hand-rolled
8. Dates/times: `Intl.DateTimeFormat` with explicit locale and time zone. Store UTC, render in a deliberate zone.
9. Numbers/currency/lists: `Intl.NumberFormat` (currency code from the data, never assume `$`), `Intl.ListFormat`, `Intl.RelativeTimeFormat`.
10. No manual thousands separators, decimal marks, or "3 days ago" strings.

## Routing & RTL
11. Locale in the URL (`/ja/...`) so pages are linkable and cacheable. Set `<html lang>` and `dir` per request.
12. Negotiate initial locale: URL → stored preference → `Accept-Language`. Let users switch and persist it.
13. Load only the active locale's catalog — never ship every language to the client.
14. RTL: drive `dir` from data; use CSS logical properties (`margin-inline`, `text-align: start`). Mirror directional icons, not logos.

## Input & testing
15. Parse locale-formatted input (decimal comma, native digits) to canonical form BEFORE validating with zod. Store canonical.
16. Names/addresses/phone: do not assume Western structure. Avoid regex that rejects non-Latin input.
17. Sorting/search: `Intl.Collator`, not byte order.
18. Test with a pseudo-locale (padded strings) and one RTL locale for layout-sensitive components.
