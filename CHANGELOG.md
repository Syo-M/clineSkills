# Changelog

このルールセット自体の変更履歴。`.clinerules/**` や `.cline/skills/**` を変更したら(/retro 経由を含め)ここに1行追記する。
形式: [Keep a Changelog](https://keepachangelog.com/) 準拠、バージョンはSemVer。

## [1.2.0] - 2026-07-04

3視点の独立レビュー(ローカルLLM実効性/技術的正確性/運用・保守性、105/150)のmust-fixを反映。

### Added
- `install.sh` — マニフェスト方式のアップグレード安全化: ローカル編集の自動バックアップ(`.cline/rules-backup-*`)、上流で消えたルールのprune(二重読込防止)、バージョン刻印(`.cline/ruleset-version.txt`)、複数引数/自己インストールの拒否、`--help`
- `01-core.md` #11 — 新規作成ファイルはパストリガーが発火しない可能性があるため、該当トリップワイヤーを自分で適用するバックストップ
- `01-core.md` #22 — スキル同時読込は2本まで(トークン予算の整合)
- `02-edit-discipline.md` #11/#13 — 150行超ファイルの全文書換禁止、タスク全体で編集4連続失敗時のサーキットブレーカー
- `workflows/pre-ship.md` Gate 5 — gitleaks/semgrepの機械スキャン(未導入ならSKIPPED明示)
- `security` スキル — DNS再バインド対策(pinned IP)復元、`postMessage` origin検証+SRI、`isomorphic-dompurify`のSSR注意
- `testing` スキル — fake timers + userEvent の `advanceTimers` 設定(欠落するとテストがハング)、ポータル/モーダルのクエリ方法
- `workflows/retro.md` — 出口を修正: プロジェクト内は `.cline/ruleset-changelog.md` に記録し、本体リポジトリへのdiff持ち帰りを促す
- `README.md` — 「アップグレードとルールの同期」節(バックアップ挙動・持ち帰り運用・スキル一覧4箇所の更新)
- `SETUP.md` — `ollama pull` 手順、Ollama最新化の注意、evalへの導線

### Changed
- Modelfile — サンプリングを公式推奨値に(Qwen: temp 0.7/top_p 0.8/top_k 20/repeat 1.05 — 低tempの繰り返しループ回避。Gemma: 1.0/0.95/64)
- `templates/eslint.config.js` — 素のリポジトリで `eslint .` が通るよう修正(`allowDefaultProject` + JSファイルの型チェック除外)、`exhaustive-deps` をerrorに昇格(pre-shipゲートの実効化)、`react.version: detect`
- `templates/tsconfig.strict.json` — `exactOptionalPropertyTypes` を削除(エコシステム型との衝突ノイズ回避、理由をコメントに明記)
- `templates/tokens.css` — ダークテーマの生hexをprimitive層へ移動、`--color-action`系のダーク値を追加(自身の層構造ルールに準拠)
- reduced-motionの閾値を「significant(hover/focusの軽微な遷移は除く)」で3ファイル間統一(css-styling / 12-styling / eval P3)
- eval — P2を `z.strictObject` 必須に(スキル#6と整合)、P7に「未コミット変更を残して実行」の前提を追加、P1にスキル発火チェックの注記
- typecheckコマンドを「`typecheck`スクリプト優先、なければ `npx tsc --noEmit`」に統一(PM検出ルールとの矛盾解消)
- `SETUP.md` RAM表 — qwen3.6実測23GBベースに修正(32Kはギリギリ可)、qwen3-coder乗り換えの余裕を明記
- README — トークン予算の主張を実態に合わせ訂正(最悪ケース約23%)、`--with-templates` の説明からtsconfigを分離
- `14-sensitive-config.md` — `**/bun.lockb` と `AGENTS.md` をゲート対象に追加

## [1.1.0] - 2026-07-04

### Added
- `templates/` — 機械的強制レイヤー: eslint.config.js / stylelint.config.mjs / tsconfig.strict.json / tokens.css / AGENTS.md(他ツール用ミラー)+ 導入ガイド
- `eval/golden-prompts.md` — モデル・設定比較用の手動評価基準(7課題23チェック)
- `CHANGELOG.md`(このファイル)
- `install.sh` — `--with-templates`(templates導入)と `--global`(編集規律ルールを ~/Documents/Cline/Rules へ)オプション
- `01-core.md` — lint/テストスクリプト欠落時は追加を提案するルール(#18)
- `workflows/retro.md` — 適用後に CHANGELOG へ追記するステップ
- `SETUP.md` §7 — Compact Prompt ON でのスキル発火再確認の項目
- `README.md` — memory/ のgitignore方針

## [1.0.0] - 2026-07-04

### Added
- 初版: fable_skills v3.0.3 を Cline + Ollama ローカルLLM向けに移植
- 常時ルール3本(core / edit-discipline / memory)、パス条件ルール5本、ワークフロー7本、スキル8本
- 軽量Memory Bank(project.md / active.md、各40行以内)
- Ollama Modelfile(qwen: Act用 / gemma: Plan用、num_ctx 32768)
- SETUP.md / README.md / install.sh
