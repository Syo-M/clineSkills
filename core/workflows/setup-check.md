# Setup Check(環境チェック — 読み取り専用)

Verify this machine's setup matches the ruleset's requirements. Run commands and report.
**Do NOT change any setting or file during this workflow.**

## Steps
1. Run: `echo "$(($(sysctl -n hw.memsize)/1073741824))GB"` → this machine's RAM.
2. Run: `ollama ps` → the loaded model's name, size, and CONTEXT length. If empty, note "モデル未ロード" and continue.
3. Run: `ollama list` → available models.
4. Judge against this table (RAM → max safe num_ctx / max model size):

| RAM | max num_ctx | max model size |
|---|---|---|
| under 24GB | 8192-16384 | RAM minus 6GB. Code editing NOT recommended on this tier |
| 24-31GB | 16384 | ~18GB |
| 32-47GB | 32768 | ~24GB |
| 48GB+ | 65536 | ~30GB |

5. Check: is the loaded CONTEXT equal to the recommended num_ctx for this RAM tier? Is model size + context within the tier's limit?
6. Check: does `.cline/ruleset-version.txt` exist in this workspace? Report its content (installed ruleset version and packs).

## Report format(報告形式)
Output ONE table:

| 項目 | 検出値 | 判定(OK/NG) | 推奨 |

Rows: RAM / ロード中モデルとサイズ / CONTEXT長 / ルールセット導入状態.
7. If anything is NG: quote the matching fix from SETUP.md §8 (troubleshoot table), or recommend re-running `./setup.sh` from the ruleset repo.
8. If `ollama ps` was empty: tell the user to send any message to the model once, then run /setup-check again.
