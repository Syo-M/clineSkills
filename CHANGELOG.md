# Changelog

このルールセット自体の変更履歴。`.clinerules/**` や `.cline/skills/**` を変更したら(/retro 経由を含め)ここに1行追記する。
形式: [Keep a Changelog](https://keepachangelog.com/) 準拠、バージョンはSemVer。

## [1.3.0] - 2026-07-04

v1.2.0再評価(114/150、EVALUATION.md)の残存must-fix 8件+推奨事項を反映。

### Fixed
- `workflows/review.md` — スキル読込を2本上限に(3レビュアー全員が指摘した01-core #22との矛盾を解消。広いdiffは領域ごとにパス分割し/newtaskで再実行)
- `security` #6 — `z.strictObject`の根拠説明を訂正(素の`z.object()`も未知キーを落としマスアサインメント自体は防ぐ。strictの利点は「クライアントバグを隠さない」こと。RAW入力のspread禁止を明記)
- コマンド統一の漏れ — `new-component` #7/#13と`templates/AGENTS.md` #8の`npx tsc`/`npm test`直書きを解消
- `pre-ship` Gate 5 — 非推奨の`gitleaks protect --staged`を`gitleaks dir .`へ(未ステージ変更もカバー。旧版は`detect --no-git`)
- install.sh — 孤児ルール(ローカル編集済み+上流削除)をマニフェストに引き継ぎ**毎回**警告(従来は初回のみで以後永久に黙って二重読込)/配布記録なし時の「ローカル編集を検出」誤ラベルを修正/`--with-templates`で既存ファイルが現行テンプレートと異なる場合にdiff通知

### Added
- `01-core` #21 — スキル読込の具体的手段を明記(`read_file`で`.cline/skills/<name>/SKILL.md`を読む。内容がコンテキストに無いのに「読込済み」と主張しない)
- `02-edit-discipline` — 全文書換の判断を「先に行数を数える」単一手順に再構成(#11-12)、write_to_file後の検証手順を具体化(#13: import/export名/行数の比較)、読み込み規律(#6: 長いファイルはsearch_files で確認してから読む)
- `testing` — Vitest例外を復元(headlessフック/6組合せ以上のプロップ行列)、「インタラクションテストでアニメーション無効化禁止(無効化はVRTのみ)」を復元(#21)
- `security` #33 — CSPに`base-uri 'self'`/`form-action 'self'`を復元
- `new-component` — カスタムウィジェット時の3本目スキル(`a11y`)を「明示的許可」として記述(01-core #22と整合)
- `SETUP.md` — Cline v3.48+の前提と実機検証時のバージョン追記欄、`OLLAMA_FLASH_ATTENTION`/`OLLAMA_KV_CACHE_TYPE=q8_0`によるKVキャッシュ削減

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
