#!/usr/bin/env bash
# cline_local_skills を対象リポジトリへ導入/アップグレードする
# macOS標準の bash 3.2 で動作すること(連想配列は使わない)
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./install.sh /path/to/target-repo [--pack <name>]... [--with-templates] [--global]

  --pack <name>     導入するドメインパック (frontend / documents)。複数指定可。
                    省略時は frontend(従来互換)
  --with-templates  パックの templates/ もコピー(既存は上書きしない。差分があれば通知)
  --global          編集規律ルール(core/02のみ)を ~/Documents/Cline/Rules にコピー

構成: core/(全パック共通の常時ルール・ワークフロー)+ packs/<name>/ が
ターゲットの .clinerules/ と .cline/skills/ に合成して配置される。

アップグレード時の挙動:
  - 前回インストールの記録(.cline/ruleset-manifest.txt)と照合し、
    ローカルで編集されたルールは .cline/rules-backup-<日時>/ に退避してから更新
  - 上流で削除/改名されたルールは(未編集なら)対象からも削除。編集済みなら残して毎回警告
  - 導入バージョンとパックを .cline/ruleset-version.txt に記録
USAGE
}

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET=""
WITH_TEMPLATES=0
GLOBAL=0
PACKS=""
EXPECT_PACK=0

for arg in "$@"; do
  if [ "$EXPECT_PACK" = 1 ]; then
    [ -d "$SRC/packs/$arg" ] || { echo "Error: 不明なパック '$arg'。利用可能: $(ls "$SRC/packs")" >&2; exit 1; }
    PACKS="$PACKS $arg"
    EXPECT_PACK=0
    continue
  fi
  case "$arg" in
    --pack) EXPECT_PACK=1 ;;
    --with-templates) WITH_TEMPLATES=1 ;;
    --global) GLOBAL=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "Error: 位置引数が複数あります ('$TARGET' と '$arg')。パスは1つだけ指定してください" >&2
        exit 1
      fi
      TARGET="$arg" ;;
  esac
done
[ "$EXPECT_PACK" = 0 ] || { echo "Error: --pack にパック名がありません" >&2; exit 1; }
[ -n "$PACKS" ] || PACKS=" frontend"

[ -n "$TARGET" ] || { usage >&2; exit 1; }
[ -d "$TARGET" ] || { echo "Error: target directory not found: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
if [ "$TARGET" = "$SRC" ]; then
  echo "Error: 対象がルールセットリポジトリ自身です。別のプロジェクトを指定してください" >&2
  exit 1
fi

VERSION="$(grep -m1 -o '\[[0-9][0-9.]*\]' "$SRC/CHANGELOG.md" | tr -d '[]')"
MANIFEST="$TARGET/.cline/ruleset-manifest.txt"
BACKUP_DIR="$TARGET/.cline/rules-backup-$(date +%Y%m%d-%H%M%S)"

sha_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
manifest_sha() { # $1 = relpath; 前回インストール時のsha(なければ空)
  [ -f "$MANIFEST" ] && awk -v p="$1" '$2==p{print $1}' "$MANIFEST" || true
}

# --- staging: core + 指定パックをターゲットのレイアウトに合成 ---
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/.clinerules/workflows" "$STAGE/.cline/skills"
cp "$SRC"/core/clinerules/*.md "$STAGE/.clinerules/"
cp "$SRC"/core/workflows/*.md "$STAGE/.clinerules/workflows/"
for pack in $PACKS; do
  [ -d "$SRC/packs/$pack/clinerules" ] && cp "$SRC/packs/$pack/clinerules/"*.md "$STAGE/.clinerules/"
  [ -d "$SRC/packs/$pack/workflows" ] && ls "$SRC/packs/$pack/workflows/"*.md >/dev/null 2>&1 && cp "$SRC/packs/$pack/workflows/"*.md "$STAGE/.clinerules/workflows/"
  [ -d "$SRC/packs/$pack/skills" ] && ls "$SRC/packs/$pack/skills" | grep -q . && cp -R "$SRC/packs/$pack/skills/." "$STAGE/.cline/skills/"
done

# 配布対象(相対パス)。ここに無いターゲット内ファイルには触らない
PAYLOAD="$(cd "$STAGE" && find .clinerules .cline -type f | sort)"

# --- prune: 上流で消えた/改名されたルールを対象から削除(未編集の場合のみ) ---
# ローカル編集があり残したもの(孤児)は新マニフェストに引き継ぎ、毎回警告し続ける
ORPHANS=""
if [ -f "$MANIFEST" ]; then
  while read -r old_sha old_path; do
    [ -n "$old_path" ] || continue
    if ! printf '%s\n' "$PAYLOAD" | grep -qxF "$old_path"; then
      if [ -f "$TARGET/$old_path" ]; then
        if [ "$(sha_of "$TARGET/$old_path")" = "$old_sha" ]; then
          rm "$TARGET/$old_path"
          echo "pruned (上流で削除/改名): $old_path"
        else
          echo "WARNING: $old_path は上流から消えましたがローカル編集があるため残しました。"
          echo "         Clineに読み込まれ続けます — 取り込むか削除するまで毎回警告します"
          ORPHANS="${ORPHANS}${old_sha}  ${old_path}
"
        fi
      fi
    fi
  done < "$MANIFEST"
fi

# --- install/upgrade: ローカル編集を退避してからコピー ---
BACKED_UP=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  mkdir -p "$TARGET/$(dirname "$p")"
  if [ -f "$TARGET/$p" ]; then
    cur="$(sha_of "$TARGET/$p")"
    new="$(sha_of "$STAGE/$p")"
    old="$(manifest_sha "$p")"
    # 既存がこれから入れるものとも前回配布分とも違う = ローカル編集 → 退避
    if [ "$cur" != "$new" ] && { [ -z "$old" ] || [ "$cur" != "$old" ]; }; then
      mkdir -p "$BACKUP_DIR/$(dirname "$p")"
      cp "$TARGET/$p" "$BACKUP_DIR/$p"
      if [ -z "$old" ]; then
        echo "backed up (配布記録なし — 旧版からの更新か手動配置。念のため退避): $p → ${BACKUP_DIR#"$TARGET"/}/$p"
      else
        echo "backed up (ローカル編集を検出): $p → ${BACKUP_DIR#"$TARGET"/}/$p"
      fi
      BACKED_UP=1
    fi
  fi
  cp "$STAGE/$p" "$TARGET/$p"
done <<EOF_PAYLOAD
$PAYLOAD
EOF_PAYLOAD

# --- マニフェストとバージョンを記録(孤児エントリは引き継いで追跡継続) ---
mkdir -p "$TARGET/.cline"
(cd "$TARGET" && printf '%s\n' "$PAYLOAD" | while IFS= read -r p; do shasum -a 256 "$p"; done) > "$MANIFEST"
[ -n "$ORPHANS" ] && printf '%s' "$ORPHANS" >> "$MANIFEST"
echo "cline_local_skills v$VERSION ($(date +%Y-%m-%d)) packs:$PACKS" > "$TARGET/.cline/ruleset-version.txt"

# --- memory: テンプレートから生成(既存は上書きしない) ---
mkdir -p "$TARGET/memory"
for f in project active; do
  if [ ! -f "$TARGET/memory/$f.md" ]; then
    cp "$SRC/memory/$f.template.md" "$TARGET/memory/$f.md"
    echo "created: memory/$f.md (テンプレート — 中身を埋めてください)"
  else
    echo "kept existing: memory/$f.md"
  fi
done

# --- templates(機械的強制レイヤー)— 既存ファイルは上書きしない ---
if [ "$WITH_TEMPLATES" = 1 ]; then
  copy_if_absent() { # src dest label — 既存は残すが、現行テンプレートとの差分は通知する
    if [ -f "$2" ]; then
      if [ "$(sha_of "$2")" != "$(sha_of "$1")" ]; then
        echo "kept existing: $3 (現行テンプレートと差分あり — 手動でdiffし、必要な修正を取り込んでください: diff \"$2\" \"$1\")"
      else
        echo "kept existing: $3"
      fi
    else
      mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "created: $3"
    fi
  }
  for pack in $PACKS; do
    TDIR="$SRC/packs/$pack/templates"
    [ -d "$TDIR" ] || continue
    case "$pack" in
      frontend)
        copy_if_absent "$TDIR/eslint.config.js"     "$TARGET/eslint.config.js"      "eslint.config.js"
        copy_if_absent "$TDIR/stylelint.config.mjs" "$TARGET/stylelint.config.mjs"  "stylelint.config.mjs"
        copy_if_absent "$TDIR/tokens.css"           "$TARGET/src/styles/tokens.css" "src/styles/tokens.css"
        echo "note: tsconfig.strict.json は自動マージしません — packs/frontend/templates/README.md を参照"
        ;;
      *)
        for t in "$TDIR"/*; do
          [ -f "$t" ] || continue
          base="$(basename "$t")"
          [ "$base" = "README.md" ] && continue
          copy_if_absent "$t" "$TARGET/$base" "$base"
        done
        ;;
    esac
  done
fi

# --- グローバルルール(プロジェクト非依存の編集規律のみ) ---
if [ "$GLOBAL" = 1 ]; then
  GLOBAL_DIR="$HOME/Documents/Cline/Rules"
  mkdir -p "$GLOBAL_DIR"
  cp "$SRC/core/clinerules/02-edit-discipline.md" "$GLOBAL_DIR/cline-local-edit-discipline.md"
  echo "installed global rule: $GLOBAL_DIR/cline-local-edit-discipline.md"
  echo "note: 本ルールセット導入済みのプロジェクトでは同内容が二重読込になるため、"
  echo "      RulesパネルでグローバルとワークスペースのどちらかをOFFにしてください"
fi

echo ""
echo "✅ 導入完了: $TARGET (ruleset v$VERSION / packs:$PACKS)"
if [ "$BACKED_UP" = 1 ]; then
  echo "⚠️  ローカル編集されたルールを ${BACKUP_DIR#"$TARGET"/} に退避しました。"
  echo "   残したい変更は diff を取り、ルールセット本体(cline_local_skills)へ持ち帰ってください"
fi
echo "次のステップ:"
echo "  1. memory/project.md をこのリポジトリの実情報で埋める"
echo "  2. SETUP.md に従って Ollama の Modelfile と Cline 設定を確認する"
echo "  3. VS Code で Cline を開き、Rules パネルにルールが並ぶことを確認する"
echo "  4. packs/<パック>/eval/golden-prompts.md でモデルが実用ラインに達しているか採点する"
