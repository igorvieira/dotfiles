#!/usr/bin/env bash
#
# Verify installed items from the dotfiles catalog.
#
# - Reads $HOME/.dotfiles-installed (receipt written by setup.sh) to know
#   which items to check. If no receipt exists, falls back to checking all
#   default-on items.
# - Runs the `check` spec defined in lib/catalog.sh for each item.
# - Also checks that the expected config symlinks are in place.
#
# Flags:
#   --all        verify every catalog item (ignore receipt)
#   --receipt    force reading the receipt (the default)
#   --defaults   check every default-on item
#

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

TOTAL=0; PASS=0; FAIL=0; SKIP=0
FAILED_NAMES=()

pass() { echo -e "  ${GREEN}✅${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}❌${NC} $1"; FAIL=$((FAIL+1)); FAILED_NAMES+=("$1"); }
skip() { echo -e "  ${DIM}—${NC}  $1 ${DIM}(no check)${NC}"; SKIP=$((SKIP+1)); }
head_() { echo -e "\n${BOLD}${BLUE}▶ $1${NC}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/catalog.sh
source "$DOTFILES_DIR/lib/catalog.sh"

MODE="receipt"
for arg in "$@"; do
  case "$arg" in
    --all)      MODE="all" ;;
    --defaults) MODE="defaults" ;;
    --receipt)  MODE="receipt" ;;
    -h|--help)
      sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

RECEIPT_FILE="$HOME/.dotfiles-installed"

# Build the set of keys to test into KEYS_TO_TEST.
KEYS_TO_TEST=()
case "$MODE" in
  all)
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      KEYS_TO_TEST+=("${entry%%|*}")
    done < <(all_items) ;;
  defaults)
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      IFS='|' read -r key display kind target def _ <<<"$entry"
      [[ "$def" == "1" ]] && KEYS_TO_TEST+=("$key")
    done < <(all_items) ;;
  receipt)
    if [[ -f "$RECEIPT_FILE" ]]; then
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        KEYS_TO_TEST+=("$line")
      done < "$RECEIPT_FILE"
    else
      echo -e "${YELLOW}No receipt at $RECEIPT_FILE. Falling back to default-on items.${NC}"
      while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        IFS='|' read -r key display kind target def _ <<<"$entry"
        [[ "$def" == "1" ]] && KEYS_TO_TEST+=("$key")
      done < <(all_items)
    fi ;;
esac

echo -e "${BOLD}Dotfiles verification${NC}"
echo -e "${DIM}Mode: $MODE  •  Items to check: ${#KEYS_TO_TEST[@]}${NC}"

# Catalog items — grouped in the output
declare -a current_group_label=()

for gidx in "${!GROUP_NAMES[@]}"; do
  local_printed=0
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r key display kind target def check <<<"$entry"

    # is this key in the test set?
    in_set=0
    for k in "${KEYS_TO_TEST[@]}"; do
      if [[ "$k" == "$key" ]]; then in_set=1; break; fi
    done
    [[ $in_set -eq 0 ]] && continue

    if [[ $local_printed -eq 0 ]]; then
      head_ "${GROUP_NAMES[$gidx]}"
      local_printed=1
    fi

    TOTAL=$((TOTAL+1))
    if evaluate_check "$check"; then
      pass "$display"
    else
      rc=$?
      if [[ $rc -eq 2 ]]; then
        skip "$display"; TOTAL=$((TOTAL-1))
      else
        fail "$display"
      fi
    fi
  done < <(group_items "$gidx")
done

# Config symlink checks — only if setup.sh linked them (best-effort).
head_ "Config symlinks"
check_link() {
  local label="$1" target_path="$2" want="$3"
  TOTAL=$((TOTAL+1))
  if [[ -L "$target_path" ]]; then
    local resolved; resolved=$(readlink "$target_path")
    if [[ "$resolved" == "$want" ]]; then
      pass "$label → $want"
    else
      fail "$label points to $resolved (want $want)"
    fi
  elif [[ -e "$target_path" ]]; then
    pass "$label (exists, not a symlink)"
  else
    fail "$label missing at $target_path"
  fi
}

check_link ".zshrc"            "$HOME/.zshrc"                         "$DOTFILES_DIR/.zshrc"
check_link ".p10k.zsh"         "$HOME/.p10k.zsh"                      "$DOTFILES_DIR/.p10k.zsh"
check_link "ghostty/config"    "$HOME/.config/ghostty/config"         "$DOTFILES_DIR/ghostty/config"
check_link ".gitconfig"        "$HOME/.gitconfig"                     "$DOTFILES_DIR/git/.gitconfig"
check_link ".gitignore_global" "$HOME/.gitignore_global"              "$DOTFILES_DIR/git/.gitignore_global"

# ─── Summary ────────────────────────────────────────────────────────────────
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Results${NC}  total=$TOTAL  ${GREEN}pass=$PASS${NC}  ${RED}fail=$FAIL${NC}  ${DIM}skip=$SKIP${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ $FAIL -gt 0 ]]; then
  echo -e "${RED}Failed:${NC}"
  for n in "${FAILED_NAMES[@]}"; do echo "  • $n"; done
  exit 1
fi

echo -e "${GREEN}All checks passed.${NC}"
