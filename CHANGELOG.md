# Changelog

このルールセット自体の変更履歴。`core/**` や `packs/**` のルール・スキル・ワークフロー・templates・Modelfileを変更したら(/retro 経由を含め)ここに1行追記する。
形式: [Keep a Changelog](https://keepachangelog.com/) 準拠、バージョンはSemVer。

## [2.2.2] - 2026-07-04

### Fixed (事実誤認の訂正)
- **「dense vs MoE」の記述を全面訂正** — qwen3-coder:30b は dense ではなく `30B-A3B`(MoE、実効約3.3B)で、qwen3.6(35B-A3B)と同じMoEファミリー(Qwen3技術レポート/Ollamaで確認)。両者のツール呼び出し安定性の差はアーキテクチャではなく、**Clineのツールパーサ不一致(ローカルはXMLテキスト経路にフォールバック、[Cline #10843](https://github.com/cline/cline/issues/10843) 未解決)+ モデル毎のツールテンプレート品質差 + num_ctx**。EVALUATION/SETUPの該当箇所を訂正
- 含意の整理: **ツール呼び出しのループ/書式崩れはハーネス側要因(モデルの能力問題ではない)**。一方でセキュリティ失敗(P2=0/5)は真のモデル限界で、この結論は不変
- SETUP §4 を2026-07リサーチで更新: 推奨を qwen3-coder:30b に(MoEである旨明記)、代替候補(Devstral Small 2 24B=dense/Qwen3.6-27B/GLM-4.7-Flash)、MLX(M4で約3倍速だがツール問題は非解決)を追記

## [2.2.1] - 2026-07-04

### Fixed
- **`11-server-boundaries.md` のパスglobの穴を修正** — ルート直下の `server.js`/`server.ts`/`api.js` 等が**どのglobにもマッチせずトリップワイヤーが発火しない**問題(既存は `**/server/**`=ディレクトリ、`**/*.server.*` のみで、素の `server.*`/`api.*` を拾えなかった)。`**/server.*` `**/api.*` `**/routes.*` を追加。minimatchで実測し、`server.js`等を拾いReactコンポーネント(App.tsx等)は誤爆しないことを確認。実機P2でモデルが `server.js` を作り続けたため発覚 — **これまでのP2(0点)は復唱テストが未成立だった**(発火しなければ復唱指示が載らない)ことも判明、EVALUATION訂正済み

## [2.2.0] - 2026-07-04

実機golden-prompts検証(EVALUATION.md「実機検証」参照)の発見を設計に反映。テーマは「暗黙要件の明示化」と「機械的強制の拡充」。

### Added
- **復唱テクニック** — トリップワイヤー10〜13の先頭に「まず該当ルール番号を1行ずつ復唱してからコードを書け」を追加。実測の核心(11-server-boundariesが発火してもモデルが従わない=受動注入は効かない)への対策で、副次要件を中心タスクに格上げする。次回P2再測で効果検証
- `12-styling` #3 — 「`var(--x)` を書く前にトークンの実在をtokensファイルで確認せよ」(実測: P3/P5で未定義トークンを2度発明)
- templates/stylelint.config.mjs — `stylelint-value-no-unknown-custom-properties` を追加。**未定義トークン参照をlintで機械検出**(fixtureでP3の実バグ `--color-bg-hover` とP5の `--color-primary` を実際に検出することを確認済み)
- README「運用のコツ」— 実測ベースの使い方: 任せてよい作業/だめな作業、暗黙要件のプロンプト明示、モデルの完了宣言を信じない

### Changed
- **`/security-check` と `/a11y-check` を「読み取り専用」から「2段階型(点検・報告 → 承認待ち → 修正)」に再設計** — 実測でread-only契約が守られず直接編集されたため、「禁止」ではなく「順序の強制」に転換。欠落コントロール(認証が無い等)も指摘対象と明記し、「安全です」宣言を禁止(代わりに「確認したこと/直したこと/残っていること」の3点報告)

## [2.1.1] - 2026-07-04

実機の採点用fixture(Vite react-ts)への導入で表面化したtemplatesの不具合を修正。レビュアーがPLAUSIBLEとしていた点が実機で確定した。

### Fixed
- `templates/eslint.config.js` — `allowDefaultProject` から `*.config.ts` を除外。フレームワークは `vite.config.ts`/`next.config.ts` を tsconfig.node.json に含めるため、project service と allowDefaultProject の両方に存在してeslintがエラーになっていた(実機で確認)
- `templates/README.md` — `npm i` のeslintを `^9` に固定。2026-07時点で `eslint-plugin-import` が ESLint 10 未対応のため、無印だと `eslint@10` が入りERESOLVE衝突する
- `templates/tokens.css` — 自身のstylelint設定(config-standard継承)を通らなかった箇所を修正: `#ffffff`→`#fff`、`rgb(... / 0.05)`→`rgb(... / 5%)`

## [2.1.0] - 2026-07-04

初心者向けの導入体験を追加。「賢さが要らない判断はLLMにやらせない」方針に沿い、環境判定は決定論的スクリプトが担う。

### Added
- `setup.sh` — 対話式かんたんセットアップ: RAM/チップ自動検出 → RAM階層に応じたモデル・num_ctxの提案(既存モデルの再利用/qwen3-coder:30bのDL選択、16GB級には正直な非推奨警告+documentsパック案内)→ Modelfile生成と `ollama create` を代行 → Cline設定画面に入力する値を表示。`--check` で提案のみ(無変更)
- `core/workflows/setup-check.md` — `/setup-check`: Cline内でモデル自身に `sysctl`/`ollama ps` を実行させ、RAM階層表と照合して設定の整合を報告する読み取り専用ワークフロー(設定の書き換えはClineの仕様上不可能なため検証・助言に限定)
- SETUP.md §0「かんたんセットアップ」— まず setup.sh、§1以降は解説と手動代替という位置づけに変更

## [2.0.0] - 2026-07-04

リポジトリを「共通コア + ドメインパック」構造へ再編し、機密文書編集用の documents パックを新設。
**ソースの配置は変わるがターゲット側の配置(.clinerules/ .cline/skills/)は不変** — v1.x導入済みプロジェクトへの再インストールはクリーンに通る(実テスト済み)。

### Added
- **packs/documents/** — ローカルLLMの特性(外部に出せない書類)を活かす新パック:
  - `04-docs-core.md` — 機密保持フロア(外部送信の全面禁止・事実の発明禁止・【要確認】プレースホルダ・verbatim移動)+文書検証
  - スキル4本: `docs-writing`(日本語ビジネス文書)/ `docs-proofread`(3パス校正)/ `docs-structure`(構成・pandocローカル変換)/ `docs-anonymize`(一貫プレースホルダ+対応表+残存チェック)
  - ワークフロー2本: `/proofread`(読み取り専用校正)/ `/anonymize`(コピーに匿名化)
  - `eval/golden-prompts.md` — 4課題13チェック(D2情報発明・D3外部参照拒否がゼロのモデルは機密文書に使わない)
- `install.sh --pack <name>`(複数指定可、省略時frontend)— core+パックをステージングで合成して配置
- SETUP.md — **RAM別の目安表(Apple Silicon汎用)**: 16GB(編集非推奨)/24GB(実用ライン)/32GB/36GB/48GB+。汎用Mac対応の第一歩
- Ollamaモデル `qwen3.6-cline` / `gemma4-cline` を実機で作成済み(SETUP §2の手順を実行)

### Changed
- ソース配置: `.clinerules/` `.cline/skills/` `templates/` `eval/` → `core/` + `packs/frontend/` へ git mv(履歴保持)
- ルール番号の規約を明文化: 01-03=core+frontend常時 / 04-05=documents常時 / 10-14=frontendパス条件 / 15-19=documentsパス条件(予約)
- README/SETUP/EVALUATION のパス参照をパック構造に更新

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
