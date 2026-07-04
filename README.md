# cline_local_skills

**Cline + Ollama(ローカルLLM)で、ミドルクラスのMacでも正確な作業をするためのルールセット。**

[fable_skills](https://github.com/Syo-M/fable5_skills)(Claude Code用の本格構成)を、27〜30B クラスのローカルモデルの制約 — 小さいコンテキスト窓・弱い指示追従・diff 編集の失敗 — に合わせて翻案したもの。速度は目標にしない。正確性が目標。

## 構成: 共通コア + ドメインパック

```
core/                 # 全パック共通の常時ルール(編集規律・メモリ)+ ワークフロー(/retro /update-memory)
packs/
  frontend/           # フロントエンド開発: スキル8本・パスルール・lint強制層・eval
  documents/          # 機密文書の編集: 機密保持フロア・スキル4本・/proofread /anonymize・eval
memory/  ollama/      # 共有(Memory Bankテンプレート・Modelfile)
install.sh            # core + 指定パックをターゲットの .clinerules/ .cline/skills/ に合成配置
```

パックを分ける理由: ①トークン予算(書類作業にReactルールを常駐させない)②小型モデルの誤発火防止 ③セキュリティ要件が正反対(frontendは「外部APIを安全に叩く」、documentsは「**内容を一切外部に出さない**」が最上位ルール)。

**ルール番号の規約**: 01〜03=core+frontend常時 / 04〜05=documents常時 / 10〜14=frontendパス条件 / 15〜19=documentsパス条件(予約)。

## 設計思想

1. **トークン緊縮** — 常時読込ルールは合計130行以下。詳細はパス条件ルール・ワークフロー・スキルへ退避し、必要な時だけ読み込む。スキルの同時読込は2本まで(ワークフローが明示した場合のみ3本)。32K窓の最悪ケースでも約23%で、コードと履歴に十分残る。
2. **小型モデル向け命令文体** — 全ルールが英語・番号付き命令形・1行1指示。長い散文は小型モデルがコンテキスト中盤で落とすため排除。
3. **外部検証で正確性を担保** — モデルの自己申告を信用しない。frontendは `tsc`/lint/テスト、documentsは再読・残存チェックが通るまで「完了」と言わせない。
4. **タスク分割規律** — 1ファイルずつ、小さいdiff、3ファイル超なら分割提案、コンテキストが伸びたら `/newtask`(core/02-edit-discipline)。
5. **diff編集失敗の緩和** — `replace_in_file` は小さい一意なブロックで。2回失敗したら行数を数え、150行以下なら全文置換・超なら停止して確認(core/02)。ローカルモデル最大の失敗要因への直接対策。

## 導入

```bash
./setup.sh                                                   # 最初に1回: スペック検出→モデル作成→Cline設定値の表示(対話式)
./install.sh /path/to/your-project                          # frontendパック(既定)
./install.sh /path/to/your-project --with-templates          # + lint/tokensの強制レイヤー(推奨。tsconfigのみ手動マージ)
./install.sh /path/to/confidential-docs --pack documents     # documentsパック
./install.sh /path/to/mixed --pack frontend --pack documents # 併用も可(常時ルールは増える)
./install.sh /path/to/your-project --global                  # 編集規律(core/02)を全プロジェクト共通化
```

環境構築(Ollama の Modelfile / num_ctx / Compact Prompt / RAM別の目安)は **[SETUP.md](SETUP.md)** を先に読むこと。
導入後は **packs/<パック>/eval/golden-prompts.md** でモデルが実用ラインに達しているか採点する。

**memory/ のgitignore方針**: `memory/project.md` はコミットする(共有知)。`memory/active.md` は個人の作業状態なので、チーム利用なら `.gitignore`、ソロならコミットしてよい。documentsパックの機密ワークスペースでは、**リポジトリ自体を外部リモートにpushしない**こと(04-docs-core #1)。

## ファイルマップ

| レイヤー | ソース | ターゲット配置 | 読込タイミング |
|---|---|---|---|
| 常時ルール(共通) | `core/clinerules/02-edit-discipline.md` `03-memory.md` | `.clinerules/` | 毎リクエスト |
| 常時ルール(frontend) | `packs/frontend/clinerules/01-core.md` | `.clinerules/` | 毎リクエスト |
| 常時ルール(documents) | `packs/documents/clinerules/04-docs-core.md` | `.clinerules/` | 毎リクエスト |
| パス条件ルール | `packs/frontend/clinerules/10〜14` | `.clinerules/` | 該当ファイルを触った時のみ |
| ワークフロー(共通) | `core/workflows/`(/retro /update-memory /setup-check) | `.clinerules/workflows/` | `/名前` で呼んだ時のみ |
| ワークフロー(パック) | frontend: /pre-ship /review /security-check /a11y-check /new-component、documents: /proofread /anonymize | `.clinerules/workflows/` | 同上 |
| スキル | frontend 8本 / documents 4本 | `.cline/skills/` | タスク内容にマッチした時のみ |
| メモリ | `memory/*.template.md` → `memory/*.md` | `memory/` | タスク開始時。各40行以内 |
| 機械的強制 | `packs/frontend/templates/`(ESLint/Stylelint/tsconfig/tokens) | リポジトリルート等 | lint実行時(モデル非依存) |
| 評価 | `packs/*/eval/golden-prompts.md` | (コピーしない) | モデル・設定の変更時 |
| 履歴/記録 | `CHANGELOG.md` / `EVALUATION.md` | (コピーしない) | — |

## fable_skills との対応表(frontendパック)

| このリポジトリ | fable_skills での元 |
|---|---|
| skill `react-components` | react-patterns + new-component(規約部)+ vite-react |
| skill `css-styling` | css-modules + design-system + motion |
| skill `testing` | testing-vitest + storybook + testing-playwright + visual-regression |
| skill `security` | frontend-security + governance(依存関係審査部) |
| skill `a11y` / `nextjs` / `i18n` | 同名スキル |
| skill `data-media` | data-viz + images-media |
| workflow `/pre-ship` `/new-component` `/retro` | 同名スキル |
| workflow `/security-check` `/a11y-check` | reviewer エージェント(Clineにサブエージェントがないため読み取り専用ワークフロー化) |
| rule `14-sensitive-config` | sensitive-paths フック(Clineにフックがないため「編集前に承認を待つ」ルールへ変換) |

**移植しなかったもの**: astro(スタック外)/ tooling(実体は設定ファイル → `packs/frontend/templates/` に同梱)/ governance残り(チーム/CI向け)/ output-styles・hooks本体(Clineに該当機構なし)。documentsパックはfable_skillsに対応物のない新規設計。

## 運用のコツ

- 1タスク=1機能・1文書。大きな依頼はまず Plan モードで分割してから Act へ。
- 会話が長くなったら迷わず `/newtask`。ローカルモデルは長いコンテキストで確実に劣化する。
- frontend: 仕上げは常に `/pre-ship`。境界コードは新タスクで `/security-check`、UIは `/a11y-check`。
- documents: 校正は `/proofread`、外部共有前は `/anonymize`。**D3(外部参照拒否)がevalで通らないモデルに機密文書を触らせない**。
- 週の終わりや大きな作業の後に `/retro` — ルールはこのループでだけ育つ。

## アップグレードとルールの同期

- **再インストール = アップグレード**: install.sh は前回導入時のマニフェスト(`.cline/ruleset-manifest.txt`)と照合し、ローカル編集されたルールを `.cline/rules-backup-<日時>/` に退避してから更新する。上流で消えたルールは(未編集なら)削除、編集済みなら残して毎回警告。導入バージョンとパックは `.cline/ruleset-version.txt` で確認できる。
- **改善は本体に持ち帰る**: プロジェクト内で `/retro` が生んだルール改善は、そのままでは次のアップグレードでバックアップ送りになる。良い改善は diff をこのリポジトリに反映し、CHANGELOG.md に記録すること — それが全プロジェクトに配られる唯一の経路。
- **スキルを増減したとき**: 各パックの常時ルール(01-core #21 / 04-docs-core #13)の一覧・`packs/frontend/workflows/review.md` #3・READMEの表を手で更新する(自動検出はない)。
