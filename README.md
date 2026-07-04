# cline_local_skills

**Cline + Ollama(ローカルLLM)で、ミドルクラスPCでも正確なフロントエンド開発をするためのルールセット。**

[fable_skills](../fable_skills/)(Claude Code 用の本格構成)を、27〜30B クラスのローカルモデルの制約 — 小さいコンテキスト窓・弱い指示追従・diff 編集の失敗 — に合わせて翻案したもの。速度は目標にしない。正確性が目標。

## 設計思想

1. **トークン緊縮** — 常時読込ルール(01〜03)は合計130行以下。詳細はパス条件ルール・ワークフロー・スキルへ退避し、必要な時だけ読み込む。スキルの同時読込は2本まで(01-core #22。ワークフローが明示した場合のみ3本)。32K窓の最悪ケース(3スキル+メモリ+パスルール+スキルstub)でも約23%で、コードと履歴に十分残る。
2. **小型モデル向け命令文体** — 全ルールが英語・番号付き命令形・1行1指示。長い散文は小型モデルがコンテキスト中盤で落とすため排除。
3. **外部検証で正確性を担保** — モデルの自己申告を信用しない。`tsc --noEmit` / lint / テストの実出力が通るまで「完了」と言わせない(01-core §Verification)。
4. **タスク分割規律** — 1ファイルずつ、小さいdiff、3ファイル超なら分割提案、コンテキストが伸びたら `/newtask`(02-edit-discipline)。
5. **diff編集失敗の緩和** — `replace_in_file` は小さい一意なブロックで。2回失敗したら `write_to_file` 全文置換にフォールバック(02-edit-discipline)。ローカルモデル最大の失敗要因への直接対策。

## 導入

```bash
./install.sh /path/to/your-project --with-templates   # lint/tokensの強制レイヤーごと導入(推奨。tsconfigのみ手動マージ)
./install.sh /path/to/your-project --global           # 編集規律ルール(02)を全プロジェクト共通化(併用可。二重読込の注意は実行時に表示)
```

環境構築(Ollama の Modelfile / num_ctx / Compact Prompt)は **[SETUP.md](SETUP.md)** を先に読むこと。
導入後は **[eval/golden-prompts.md](eval/golden-prompts.md)** でモデルが実用ラインに達しているか採点する。

**memory/ のgitignore方針**: `memory/project.md` はコミットする(チームの共有知)。`memory/active.md` は個人の作業状態なので、チーム利用なら `.gitignore` に入れ、ソロ利用ならコミットしてよい(セッション復元に便利)。

## ファイルマップ

| レイヤー | ファイル | 読込タイミング |
|---|---|---|
| 常時ルール | `.clinerules/01-core.md`(スタック+セキュリティ/a11y最低ライン+検証) | 毎リクエスト |
| | `.clinerules/02-edit-discipline.md`(タスク分割+編集フォールバック) | 毎リクエスト |
| | `.clinerules/03-memory.md`(メモリーバンク参照) | 毎リクエスト |
| パス条件ルール | `10-forms` / `11-server-boundaries` / `12-styling` / `13-tests` / `14-sensitive-config` | 該当ファイルを触った時のみ |
| ワークフロー | `/pre-ship` `/review` `/security-check` `/a11y-check` `/new-component` `/retro` `/update-memory` | `/名前` で呼んだ時のみ |
| スキル | `.cline/skills/` 配下の8本(下表) | タスク内容にマッチした時のみ |
| メモリ | `memory/project.md`(固定情報)+ `memory/active.md`(作業状態) | タスク開始時。各40行以内 |
| Ollama | `ollama/Modelfile.qwen`(Act用)/ `ollama/Modelfile.gemma`(Plan用) | — |
| 機械的強制 | `templates/`(ESLint / Stylelint / tsconfig / tokens.css / AGENTS.md) | lint実行時(モデル非依存) |
| 評価 | `eval/golden-prompts.md`(7課題23チェックの採点基準) | モデル・設定の変更時 |
| 履歴 | `CHANGELOG.md`(ルール変更の記録。/retro の出口) | — |
| レビュー記録 | `EVALUATION.md`(3視点独立レビューの採点推移と残存課題) | バージョン更新時 |

## fable_skills との対応表

| このリポジトリ | fable_skills での元 |
|---|---|
| skill `react-components` | react-patterns + new-component(規約部)+ vite-react |
| skill `css-styling` | css-modules + design-system + motion |
| skill `testing` | testing-vitest + storybook + testing-playwright + visual-regression |
| skill `security` | frontend-security + governance(依存関係審査部) |
| skill `a11y` | a11y |
| skill `nextjs` | nextjs |
| skill `data-media` | data-viz + images-media |
| skill `i18n` | i18n |
| workflow `/pre-ship` | pre-ship スキル |
| workflow `/security-check` | security-reviewer エージェント(Clineにサブエージェントがないため読み取り専用ワークフロー化) |
| workflow `/a11y-check` | a11y-auditor エージェント(同上) |
| workflow `/new-component` | new-component スキル(1ファイルずつ生成→即検証の手順に再構成) |
| workflow `/retro` | retro スキル |
| rule `14-sensitive-config` | sensitive-paths フック(Clineにフックがないため「編集前に承認を待つ」ルールへ変換) |

## 移植しなかったもの(理由)

- **astro** — 対象スタック外。
- **tooling** — 価値の実体は設定ファイルなので、スキルではなく [templates/](templates/) として同梱した(fable_skills/templates/ から適応)。**弱いモデルほど機械的強制(lint)が重要** — `--with-templates` での導入を強く推奨。
- **governance(残り)** — チーム/CI運用向け。ソロ+ローカル環境では過剰。依存関係の審査ルールだけ `security` スキルに吸収済み。
- **output-styles / hooks 本体** — Cline に該当機構がない。フックの意図は 14-sensitive-config が、レビュアーの読み取り専用性は各チェック系ワークフロー冒頭の禁止指示が引き継ぐ。

## 運用のコツ

- 1タスク=1機能。大きな依頼はまず Plan モードで分割してから Act へ。
- 会話が長くなったら迷わず `/newtask`。ローカルモデルは長いコンテキストで確実に劣化する。
- 仕上げは常に `/pre-ship`。境界コードを触ったら新タスクで `/security-check`、UIを触ったら `/a11y-check`。
- 週の終わりや大きな作業の後に `/retro` — ルールはこのループでだけ育つ。

## アップグレードとルールの同期

- **再インストール = アップグレード**: install.sh は前回導入時のマニフェスト(`.cline/ruleset-manifest.txt`)と照合し、ローカル編集されたルールを `.cline/rules-backup-<日時>/` に退避してから更新する。上流で消えたルールは(未編集なら)削除される。導入バージョンは `.cline/ruleset-version.txt` で確認できる。
- **改善は本体に持ち帰る**: プロジェクト内で `/retro` が生んだルール改善は、そのままでは次のアップグレードでバックアップ送りになる。良い改善は diff をこのリポジトリ(cline_local_skills)に反映し、CHANGELOG.md に記録すること — それが全プロジェクトに配られる唯一の経路。
- **スキルを増減したとき**: `01-core.md` #21 の一覧・`workflows/review.md` #3 の一覧・READMEの2つの表、**計4箇所**を手で更新する(自動検出はない)。
