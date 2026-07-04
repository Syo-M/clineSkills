#!/usr/bin/env bash
# かんたんセットアップ — このMacのスペックを検出し、適切なローカルLLM環境を対話式で構築する
# macOS標準の bash 3.2 で動作すること
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [--check]

  (引数なし)  対話式セットアップ: スペック検出 → モデル提案 → Ollamaモデル作成 → Cline設定値の表示
  --check     検出と推奨の表示のみ(何も作成・変更しない)

このスクリプトが自動でやること: RAM/チップ検出、RAM階層に応じたモデルとnum_ctxの提案、
Modelfile生成と ollama create。Clineの設定画面だけは手動です(最後に入力値を表示します)。
USAGE
}

CHECK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " cline_local_skills かんたんセットアップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ---------- 1. スペック検出 ----------
RAM_GB=$(( $(sysctl -n hw.memsize) / 1073741824 ))
CHIP="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "不明")"
echo ""
echo "検出結果:"
echo "  チップ : $CHIP"
echo "  RAM    : ${RAM_GB} GB"

if ! command -v ollama >/dev/null 2>&1; then
  echo ""
  echo "❌ Ollama が見つかりません。https://ollama.com からインストールしてから再実行してください。"
  exit 1
fi
echo "  Ollama : $(ollama --version 2>/dev/null | head -1 || echo 検出)"

OLLAMA_LIST="$(ollama list 2>/dev/null | tail -n +2 || true)"

# ---------- 2. RAM階層の判定 ----------
if   [ "$RAM_GB" -ge 48 ]; then NUM_CTX=65536; TIER="48GB以上(余裕あり)"
elif [ "$RAM_GB" -ge 32 ]; then NUM_CTX=32768; TIER="32GB以上(快適ライン)"
elif [ "$RAM_GB" -ge 24 ]; then NUM_CTX=16384; TIER="24GB(実用ライン)"
else                            NUM_CTX=8192;  TIER="16GB級(コード編集は非推奨)"
fi
echo "  階層   : $TIER → 推奨 num_ctx = $NUM_CTX"

LOW_RAM=0
if [ "$RAM_GB" -lt 24 ]; then
  LOW_RAM=1
  echo ""
  echo "⚠️  このMacのRAMでは 27〜30Bクラスのモデルが載らず、"
  echo "   小さいモデルはツール呼び出しが不安定なため、コード編集用途は非推奨です。"
  echo "   documentsパック(文書編集)の軽作業なら試す価値があります — 導入後は必ず"
  echo "   packs/documents/eval/golden-prompts.md で採点してから本番文書に使ってください。"
fi

# ---------- 3. Act(実作業)モデルの候補 ----------
MAX_MODEL=$(( RAM_GB - 6 ))   # モデル常駐 + KV + macOS の余白
CANDIDATES=""                  # 行形式: "name sizeGB"
while read -r name _id size unit _rest; do
  [ -n "${name:-}" ] || continue
  [ "${unit:-}" = "GB" ] || continue
  case "$name" in *-cline*) continue ;; esac   # 生成済みCline用モデルは候補から除外
  int="${size%%.*}"
  if [ "$int" -le "$MAX_MODEL" ]; then
    if [ "$LOW_RAM" = 1 ] || [ "$int" -ge 15 ]; then   # 24GB+では27B級(≒15GB以上)のみ
      CANDIDATES="${CANDIDATES}${name} ${int}
"
    fi
  fi
done <<EOF_LIST
$OLLAMA_LIST
EOF_LIST

echo ""
echo "── Act(実作業)用モデルの選択 ──"
# bash3.2: パイプ内で変数が失われるため、走査はforループで行う
IFS='
'
i=0
for line in $CANDIDATES; do
  i=$((i+1))
  echo "  $i) ${line%% *} (${line##* }GB, インストール済み)"
done
unset IFS
N=$i
DL_OPT=$((N+1))
if [ "$LOW_RAM" = 0 ]; then
  echo "  $DL_OPT) qwen3-coder:30b を新規ダウンロード(約18GB — Cline公式推奨の最低ライン)"
fi

if [ "$CHECK_ONLY" = 1 ]; then
  PICK_NAME=""
  IFS='
'
  for line in $CANDIDATES; do PICK_NAME="${line%% *}"; break; done
  unset IFS
  [ -n "$PICK_NAME" ] || PICK_NAME="qwen3-coder:30b(要ダウンロード)"
  echo ""
  echo "[--check] 推奨: Act=$PICK_NAME / num_ctx=$NUM_CTX(作成は行いません)"
  exit 0
fi

if [ "$N" -eq 0 ] && [ "$LOW_RAM" = 1 ]; then
  echo "❌ このRAMに収まるモデルがありません。まず軽量モデルを ollama pull してから再実行してください。"
  exit 1
fi

printf "番号を選んでください [1]: "
read -r choice || choice=""
[ -n "$choice" ] || choice=1

ACT_BASE=""
if [ "$choice" = "$DL_OPT" ] && [ "$LOW_RAM" = 0 ]; then
  printf "qwen3-coder:30b(約18GB)をダウンロードします。よろしいですか? [y/N]: "
  read -r yn || yn=""
  case "$yn" in [yY]*) ollama pull qwen3-coder:30b; ACT_BASE="qwen3-coder:30b" ;; *) echo "中止しました"; exit 0 ;; esac
else
  IFS='
'
  i=0
  for line in $CANDIDATES; do
    i=$((i+1))
    if [ "$i" = "$choice" ]; then ACT_BASE="${line%% *}"; fi
  done
  unset IFS
fi
[ -n "$ACT_BASE" ] || { echo "❌ 無効な選択です"; exit 1; }

# ---------- 4. Plan(設計・相談)モデル ----------
# RAMに収まる中で最大のgemmaを選ぶ(相談用途は大きいほど良い)
PLAN_BASE=""
GEMMA="$(printf '%s\n' "$OLLAMA_LIST" | awk -v max="$MAX_MODEL" '$1 ~ /gemma/ && $1 !~ /-cline/ && $4 == "GB" && int($3) <= max {print int($3), $1}' | sort -rn | head -1 | awk '{print $2}')"
if [ -n "$GEMMA" ]; then
  printf "Planモード用に %s を使いますか?(Actと分けると相談が軽くなります)[Y/n]: " "$GEMMA"
  read -r yn || yn=""
  case "$yn" in [nN]*) : ;; *) PLAN_BASE="$GEMMA" ;; esac
fi

# ---------- 5. Modelfile生成 → ollama create ----------
make_model() { # $1=base name
  base="$1"
  noext="${base%:latest}"
  safe="$(printf '%s' "$noext" | tr ':/' '--')-cline"
  case "$base" in
    *qwen*)  samp="PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
PARAMETER repeat_penalty 1.05" ;;
    *gemma*) samp="PARAMETER temperature 1.0
PARAMETER top_p 0.95
PARAMETER top_k 64" ;;
    *)       samp="PARAMETER temperature 0.7" ;;
  esac
  mf="$(mktemp)"
  {
    echo "FROM $base"
    echo "PARAMETER num_ctx $NUM_CTX"
    echo "$samp"
  } > "$mf"
  echo "作成中: $safe (FROM $base / num_ctx $NUM_CTX)" >&2
  ollama create "$safe" -f "$mf" >/dev/null
  rm -f "$mf"
  printf '%s' "$safe"
}

ACT_MODEL="$(make_model "$ACT_BASE")"
PLAN_MODEL=""
[ -n "$PLAN_BASE" ] && PLAN_MODEL="$(make_model "$PLAN_BASE")"

# ---------- 6. 仕上げ: Clineに入力する値 ----------
echo ""
echo "━━━ ここから先はVS CodeのCline設定画面に手で入力してください ━━━"
echo "  API Provider   : Ollama"
echo "  Base URL       : http://localhost:11434"
echo "  Model (Act)    : $ACT_MODEL"
[ -n "$PLAN_MODEL" ] && echo "  Model (Plan)   : $PLAN_MODEL  (Plan/Actのモデル分離をONに)"
echo "  Context Window : $NUM_CTX  (Modelfileと同値にすること)"
echo "  Use Compact Prompt (Settings → Features): ON"
echo "  Auto-approve   : 読み取り系のみ推奨"
if [ "$RAM_GB" -lt 40 ]; then
  echo ""
  echo "💡 メモリがきつい場合はKVキャッシュ圧縮が効きます(SETUP.md §3):"
  echo "   launchctl setenv OLLAMA_FLASH_ATTENTION 1"
  echo "   launchctl setenv OLLAMA_KV_CACHE_TYPE q8_0   # 設定後Ollamaを再起動"
fi
echo ""
echo "次のステップ:"
echo "  1. ルールセットの導入: ./install.sh /path/to/your-project --with-templates"
if [ "$LOW_RAM" = 1 ]; then
  echo "     ※このRAMでは --pack documents(文書編集)を推奨"
fi
echo "  2. Cline内で /setup-check を実行して設定の整合を確認"
echo "  3. packs/<パック>/eval/golden-prompts.md で採点してから本番投入"
