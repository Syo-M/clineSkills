# templates — 機械的強制レイヤー

**弱いモデルほどlintが重要です。** ルールは破られる前提で、破った瞬間に `tsc` / ESLint / Stylelint が赤くする — それがこのフォルダの役割です。`/pre-ship` のGate 2〜3はこの設定が入っていて初めて意味を持ちます。

## 導入方法

`install.sh --with-templates` で対象リポジトリにコピーされます(既存ファイルは上書きしません)。手動の場合:

| ファイル | コピー先 | 備考 |
|---|---|---|
| `eslint.config.js` | リポジトリルート | 下記のプラグインをインストール |
| `stylelint.config.mjs` | リポジトリルート | 下記のプラグインをインストール |
| `tsconfig.strict.json` | (コピーせず)既存 `tsconfig.json` の `compilerOptions` にマージ | `_comment` キーは捨てる |
| `tokens.css` | `src/styles/tokens.css` | 値はプロジェクトに合わせて調整 |
| `AGENTS.md` | (任意)リポジトリルート | 他ツール用ミラー。**Cline利用時はRulesパネルでOFF**(二重読込防止) |

## 必要パッケージ

```bash
# eslintは ^9 に固定する。2026-07時点で eslint-plugin-import が ESLint 10 に未対応のため、
# 無印だと eslint@10 が入って peer 依存衝突(ERESOLVE)になる。
npm i -D eslint@^9 @eslint/js@^9 typescript-eslint \
  eslint-plugin-import eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y \
  stylelint stylelint-config-standard stylelint-declaration-strict-value \
  stylelint-value-no-unknown-custom-properties
```

package.json にスクリプトを追加:

```json
{
  "scripts": {
    "lint": "eslint . && stylelint \"**/*.css\"",
    "typecheck": "tsc --noEmit"
  }
}
```

## ルールとの対応

- `no-explicit-any` / `ban-ts-comment` → 01-core §Stack
- `react-hooks` / `no-array-index-key` / `no-default-export` → `react-components` スキル
- `no-eval` / `no-danger` / `forbid-dom-props(style)` → `security` スキル + 01-core
- `jsx-a11y` recommended → `a11y` スキル
- Stylelint `declaration-strict-value`(var()必須)/ z-index禁止 / camelCase → `css-styling` スキル
- Stylelint `csstools/value-no-unknown-custom-properties`(未定義トークン参照の禁止) → 12-styling #3(実機evalでLLMが未定義トークンを2度発明した実バグへの対策)

これは出発点です。フレームワークプリセット(Next.js等)やstorybook/playwright系プラグインはプロジェクトに応じて追加してください。
