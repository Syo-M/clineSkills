---
paths:
  - ".github/**"
  - "**/next.config.*"
  - "**/vite.config.*"
  - "**/middleware.*"
  - "**/vercel.json"
  - "**/netlify.toml"
  - ".clinerules/**"
  - ".cline/**"
  - "**/package-lock.json"
  - "**/pnpm-lock.yaml"
  - "**/yarn.lock"
  - "**/bun.lock"
  - "**/bun.lockb"
  - "AGENTS.md"
---

# Sensitive-Path Gate(要承認パス — 編集前に必ず停止)

This path is on the human sign-off list (CI, deploy/framework config carrying security headers, rule files, lockfiles). There is no automatic hook here — THIS RULE IS THE GATE:

1. STOP before editing. Show the exact diff you intend to make and the reason.
2. WAIT for the user to explicitly approve. Do not edit until they say yes.
3. Never weaken or remove security headers / CSP to "fix" an error. Find the legitimate origin or nonce instead.
4. A lockfile-only change with no manifest change is a red flag — explain why it moved.
5. Edits to `.clinerules/**` or `.cline/**` change your own behavior on every future task. Treat them as policy changes.
