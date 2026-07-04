# SETUP — Ollama + Cline ローカルLLM環境構築

MacBook Pro (Apple Silicon, RAM 36GB) を想定した、Cline + Ollama でローカルLLMを「正確に」動かすための設定手順。速度より正確性を優先する。

## 1. 前提

- macOS + [Ollama](https://ollama.com) インストール済み(**Ollama本体は最新に保つ**)
- VS Code + **Cline v3.48以降**(Skills機能対応版)。`paths:`条件ルール・Workflows・Compact Promptも使うため、Clineも最新に保つこと
  - ※本ルールセットは2026-07時点のCline公式ドキュメントと照合して設計。実機で全機能のスモークテスト(§7)を通したら、そのClineバージョンをここに追記する
- モデルは 27〜30B クラスの 4-bit 量子化を想定(下記「モデル選定」参照)

## 2. Modelfile と num_ctx — 最重要設定

**Ollama のコンテキスト長デフォルト(2〜4K)では Cline は必ず壊れます。**
Cline のシステムプロンプト+ツール定義+ファイル内容で数回のやり取りで溢れ、「Cline is having trouble…」「You did not use a tool…」という無限ループや、ルールの黙殺(前半の指示がコンテキストから押し出される)が起きます。

Modelfile で `num_ctx` を焼き込むのが最も確実な対処です:

```bash
# 0) Ollama本体を最新にしておく(古いOllamaは新しいモデル形式を読めない)
# 1) ベースモデルを未取得なら先にpull
ollama pull qwen3.6
ollama pull gemma4

# 2) Cline用モデルを作成
cd cline_local_skills
ollama create qwen3.6-cline -f ollama/Modelfile.qwen    # Act(実装)用
ollama create gemma4-cline  -f ollama/Modelfile.gemma   # Plan(設計)用
```

作成後の確認:

```bash
ollama run qwen3.6-cline "hi"   # 一度動かしてから
ollama ps                        # CONTEXT が 32768 になっていること
```

`ollama ps` でモデルの常駐サイズを確認し、スワップが発生していないこと(アクティビティモニタのメモリプレッシャーが緑)を確認してください。

## 3. RAM × コンテキスト長のトレードオフ

KVキャッシュはコンテキスト長に比例してRAMを消費します。手元の `qwen3.6:latest` は**約23GB**なので:

| num_ctx | KVキャッシュ目安 | 合計常駐メモリ | 36GBでの可否 |
|---|---|---|---|
| 8K | 〜1-2 GB | 〜25 GB | 動くがClineには不足気味 |
| 16K | 〜2-4 GB | 〜26 GB | 可(短いタスク向け) |
| **32K** | 〜4-8 GB | 〜28-31 GB | **推奨(既定値)。ただしギリギリ — 他の重いアプリは閉じる** |
| 64K | 〜8-16 GB | 〜34 GB超 | 不可またはスワップ発生 |

**Qwen3 Coder 30B 4-bit(約18GB)に乗り換えると32Kでも約5GBの余裕が生まれます** — 精度・安定性の面でも下記の通り推奨。

さらにKVキャッシュ自体を圧縮する手もあります(出力品質への影響は軽微):

```bash
# Ollamaの起動環境に設定(launchctl setenv または Ollama.app の環境設定)
OLLAMA_FLASH_ATTENTION=1
OLLAMA_KV_CACHE_TYPE=q8_0   # KVキャッシュが約半分に — 32Kの「ギリギリ」に余裕ができる
```

32Kで運用し、コンテキストが伸びたら `/newtask` / `/smol` で区切るのが正解です(このルールセットの `02-edit-discipline.md` がモデル自身にもそれを促します)。

### RAM別の目安(Apple Silicon汎用 — 使うMacに合わせて読み替える)

本書の数値は36GB機+qwen3.6基準だが、他の一般的なMacでは以下が目安:

| 搭載RAM | 編集用(Act)モデル | 現実的な num_ctx | 備考 |
|---|---|---|---|
| 16GB | ✕ 27〜30B級は載らない | — | **コード編集は非推奨**(7〜14Bはツール呼び出しが不安定)。documentsパック+14B級の軽作業なら試す価値あり — 必ずevalで採点してから |
| 24GB | 30B 4-bit(約18GB) | 16〜32K | 実用ライン。他の重いアプリは閉じる |
| 32GB | 30B 4-bit | 32K | 快適ライン |
| 36GB(本書の基準) | 30〜35B 4-bit | 32K | qwen3.6(23GB)はギリギリ、qwen3-coder(18GB)なら余裕 |
| 48GB以上 | 30B 8-bit も視野 | 64K | KVキャッシュ圧縮と併用で長いタスクも可 |

どの構成でも導入後に `packs/<パック>/eval/golden-prompts.md` で採点し、実用ライン未満のモデルは使わないこと。

## 4. モデル選定

- **Act(実装)モード**: `qwen3.6-cline`(手元の `qwen3.6:latest` ベース)
  - Cline 公式ブログは 32GB 級 RAM の最低ラインとして **Qwen3 Coder 30B 4-bit** を推奨しています。ツール呼び出しの安定性が明確に上なので、`ollama pull qwen3-coder:30b` して Modelfile の `FROM` を差し替える価値があります。
- **Plan(設計)モード**: `gemma4-cline`(手元の `gemma4:latest` ベース)。読み・相談用途なら十分。
- **30B 未満のモデル(gemma4:12b 等)は非推奨**: ツール呼び出しの書式崩れ・`replace_in_file` の diff 失敗ループが多発するという報告が公式 issue に多数あります。編集させるモデルは 27B 以上に。
- サンプリングは各モデルの**公式推奨値**をModelfileに焼き込み済み(Qwen: temperature 0.7 / top_p 0.8 / top_k 20 / repeat_penalty 1.05、Gemma: 1.0 / 0.95 / 64)。「正確性のために低temperature」は直感に反してQwen系では**繰り返しループ**を誘発するため避けてください。

## 5. Cline 設定

VS Code の Cline 設定で:

1. **API Provider**: `Ollama`、Base URL `http://localhost:11434`
2. **Model**: `qwen3.6-cline`(Modelfileで作った名前)
3. **Context Window**: Modelfile の `num_ctx` と同じ **32768** を設定(不一致だと切り詰めが起きる)
4. **Use Compact Prompt(Settings → Features)を ON** — システムプロンプトが約10%に縮み、ローカルモデルでは事実上必須。
   - 代償: **MCPツールと Focus Chain が無効化**されます。ローカル運用ではオフで困る場面は少ないはず。
5. **Plan/Act のモデル分離**: Plan モードに `gemma4-cline`、Act モードに `qwen3.6-cline` を割り当て可能。
6. **Auto-approve は読み取り系のみ**(Read files / List files)。書き込み・コマンド実行は目視確認を推奨 — 弱いモデルの編集ミスを人間が最後に止める層です。

## 6. このルールセットの導入

```bash
./install.sh /path/to/your-project --with-templates      # フロントエンド開発(推奨構成)
./install.sh /path/to/docs-folder --pack documents       # 機密文書の編集
```

core(共通の編集規律)+ 指定パックが対象の `.clinerules/` と `.cline/skills/` に合成配置されます。
導入後、`memory/project.md` をそのリポジトリの実情報で埋めてください。

## 7. 動作確認(スモークテスト)

1. Cline のチャット下の **Rules パネル**(天秤アイコン)に `01-core` 〜 `14-sensitive-config` が並び、トグルできる
2. チャットで `/` を打つと `/pre-ship` `/new-component` などのワークフローが候補に出る
3. 「Buttonコンポーネントを作って」→ 規約準拠(named export / tokens / data-variant)の出力になり、最後に tsc/lint を実行する
4. 「コメント保存APIを追加して」→ 指示しなくても zod 検証と認可チェックが入る
5. `/pre-ship` → ゲート表(PASS/FAIL)が verbatim の出力付きで出る
6. **Compact Prompt ON の状態で 3〜4 を再実行** — スキルの自動発火が生きているか確認する。発火しない場合は、タスク開始時に `/skill-name`(例 `/security`)で手動読み込みする運用に切り替える
7. 本格運用の前に [packs/frontend/eval/golden-prompts.md](packs/frontend/eval/golden-prompts.md) で採点し、モデルが実用ライン(18/23以上)か確認する

## 8. トラブルシュート

| 症状 | 原因と対処 |
|---|---|
| ルールが効いていない | Rules パネルでトグルON確認。効いていた指示が急に消える→コンテキスト溢れ。`/newtask` で仕切り直し |
| 「You did not use a tool…」ループ | num_ctx 不足が最有力。`ollama ps` で 32768 を確認。Compact Prompt ON も確認 |
| replace_in_file が失敗し続ける | 小型モデルの既知問題。ルール(02)が2回失敗→全文置換へ誘導する。頻発するならモデルを Qwen3 Coder 30B へ |
| 生成が極端に遅い/Macが固まる | スワップ発生。num_ctx を 16K に下げるか、他のアプリを閉じる |
| ワークフローが `/` に出ない | `.clinerules/workflows/` の配置を確認。Cline を再読み込み |
