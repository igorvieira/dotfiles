#!/usr/bin/env bash
#
# Mac Setup Script — igorvieira/dotfiles
#
# Interactive installer: pick what you want, confirm at the end, install.
# Usage:
#   chmod +x setup.sh && ./setup.sh
#
# Flags:
#   --all        install everything non-interactively
#   --minimal    install only the "core" group (shell + fonts)
#   --dry-run    print planned actions without executing
#

set -euo pipefail

# ─── Colors / logging ───────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step() { echo -e "\n${BLUE}${BOLD}▶ $*${NC}"; }

# ─── Flags ──────────────────────────────────────────────────────────────────
MODE="interactive"
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --all)     MODE="all" ;;
    --minimal) MODE="minimal" ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,14p' "$0"; exit 0 ;;
    *) err "Unknown flag: $arg"; exit 1 ;;
  esac
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "${DIM}DRY: $*${NC}"
  else
    eval "$@"
  fi
}

# ─── OS check ───────────────────────────────────────────────────────────────
if [[ "$OSTYPE" != "darwin"* ]]; then
  err "This script is only for macOS"; exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Catalog ────────────────────────────────────────────────────────────────
# shellcheck source=lib/catalog.sh
source "$DOTFILES_DIR/lib/catalog.sh"

# ─── Selection logic ────────────────────────────────────────────────────────
declare -a SELECTED=()    # each element: "key|kind|target|display"

apply_default_for_mode() {
  local mode="$1" gidx="$2" entry="$3"
  IFS='|' read -r key display kind target def _ <<<"$entry"
  case "$mode" in
    all)     SELECTED+=("$key|$kind|$target|$display") ;;
    minimal) if [[ $gidx -le 1 && "$def" == "1" ]]; then SELECTED+=("$key|$kind|$target|$display"); fi ;;
  esac
  return 0
}

ask_item() {
  local entry="$1"
  IFS='|' read -r key display kind target def _ <<<"$entry"
  local prompt_def="Y/n"; [[ "$def" == "0" ]] && prompt_def="y/N"
  local reply
  read -rp "  $(printf '%-55s' "$display") [$prompt_def] " reply
  reply="${reply:-}"
  if [[ -z "$reply" ]]; then
    [[ "$def" == "1" ]] && SELECTED+=("$key|$kind|$target|$display")
  elif [[ "$reply" =~ ^[YySs]$ ]]; then
    SELECTED+=("$key|$kind|$target|$display")
  fi
}

ask_group_policy() {
  local gidx="$1"
  local name="${GROUP_NAMES[$gidx]}"
  echo
  echo -e "${BOLD}${BLUE}── ${name} ──${NC}"
  local reply
  read -rp "  [A]ll defaults, [s]elect per-item, [N]one? [A/s/n] " reply
  reply="${reply:-A}"
  case "$reply" in
    [Aa]*|"")
      while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        IFS='|' read -r k d kind target def <<<"$entry"
        [[ "$def" == "1" ]] && SELECTED+=("$kind|$target|$d")
      done < <(group_items "$gidx") ;;
    [Ss]*)
      while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        ask_item "$entry"
      done < <(group_items "$gidx") ;;
    [Nn]*) : ;;
  esac
}

collect_selections() {
  if [[ "$MODE" == "all" || "$MODE" == "minimal" ]]; then
    for gidx in "${!GROUP_NAMES[@]}"; do
      while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        apply_default_for_mode "$MODE" "$gidx" "$entry"
      done < <(group_items "$gidx")
    done
    return
  fi

  echo -e "${BOLD}🛠  Interactive setup${NC}"
  echo "For each group, choose [A]ll defaults, [s]elect per-item, or [N]one."
  echo "Defaults are marked Y/n (on) or y/N (off)."
  for gidx in "${!GROUP_NAMES[@]}"; do
    ask_group_policy "$gidx"
  done
}

confirm_selections() {
  echo
  echo -e "${BOLD}━━━ Summary ━━━${NC}"
  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    warn "Nothing selected. Exiting."; exit 0
  fi
  for entry in "${SELECTED[@]}"; do
    IFS='|' read -r key kind target display <<<"$entry"
    printf "  • %-50s  (%s)\n" "$display" "$kind:$target"
  done
  echo
  local reply
  read -rp "Proceed with installation? [y/N] " reply
  [[ "$reply" =~ ^[YySs]$ ]] || { warn "Aborted."; exit 0; }
}

# ─── Installation primitives ────────────────────────────────────────────────
ensure_homebrew() {
  step "Homebrew"
  if ! command -v brew &>/dev/null; then
    run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    if [[ $(uname -m) == 'arm64' ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    log "Homebrew present"
  fi
  run "brew update"
}

install_brew()  { run "brew install $1"; }
install_cask()  { run "brew install --cask $1"; }

install_ohmyzsh() {
  [[ -d "$HOME/.oh-my-zsh" ]] && { log "Oh My Zsh present"; return; }
  run 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
}

install_p10k() {
  local path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  [[ -d "$path" ]] || run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$path'"
  [[ -d "$HOME/powerlevel10k" ]] || run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$HOME/powerlevel10k'"
}

install_zsh_plugins() {
  local base="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  [[ -d "$base/zsh-syntax-highlighting" ]] || run "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '$base/zsh-syntax-highlighting'"
  [[ -d "$base/zsh-autosuggestions" ]]      || run "git clone https://github.com/zsh-users/zsh-autosuggestions '$base/zsh-autosuggestions'"
}

install_neovim() {
  install_brew neovim
  mkdir -p "$HOME/.config"
  if [[ -d "$HOME/.config/nvim/.git" ]]; then
    log "nvim config exists — pulling latest"
    run "git -C '$HOME/.config/nvim' pull --ff-only"
  elif [[ -d "$HOME/.config/nvim" ]]; then
    warn "~/.config/nvim exists but is not a git repo — backing up to ~/.config/nvim.bak"
    run "mv '$HOME/.config/nvim' '$HOME/.config/nvim.bak.$(date +%s)'"
    run "git clone https://github.com/igorvieira/nvim '$HOME/.config/nvim'"
  else
    run "git clone https://github.com/igorvieira/nvim '$HOME/.config/nvim'"
  fi
}

install_rust() {
  command -v rustc &>/dev/null && { log "Rust present"; return; }
  run 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
}

install_bun() {
  command -v bun &>/dev/null && { log "Bun present"; return; }
  run 'curl -fsSL https://bun.sh/install | bash'
}

install_python() {
  install_brew python
  command -v uv &>/dev/null || install_brew uv
}

install_ctlptl() { run "brew install tilt-dev/tap/ctlptl"; }
install_doppler() { run "brew install dopplerhq/cli/doppler"; }

install_claude() {
  if ! command -v node &>/dev/null; then install_brew node; fi
  if command -v claude &>/dev/null; then
    log "Claude Code CLI present"
  else
    run "npm install -g @anthropic-ai/claude-code"
  fi
  log "After install, run: claude — skills like maverick live under ~/.claude/"
}

install_one() {
  local kind="$1" target="$2" display="$3"
  step "$display"
  case "$kind" in
    brew)   install_brew "$target" ;;
    cask)   install_cask "$target" ;;
    custom) "$target" ;;
    *) err "Unknown kind: $kind" ;;
  esac
}

# ─── Config linking ─────────────────────────────────────────────────────────
link_configs() {
  step "Linking config files"
  mkdir -p "$HOME/.config"

  local files=(".zshrc" ".bashrc" ".p10k.zsh")
  for f in "${files[@]}"; do
    [[ -f "$DOTFILES_DIR/$f" ]] || continue
    if [[ -e "$HOME/$f" && ! -L "$HOME/$f" ]]; then
      run "mv '$HOME/$f' '$HOME/$f.bak.$(date +%s)'"
    fi
    run "ln -sfn '$DOTFILES_DIR/$f' '$HOME/$f'"
  done

  # ghostty
  if [[ -d "$DOTFILES_DIR/ghostty" ]]; then
    run "mkdir -p '$HOME/.config/ghostty'"
    run "ln -sfn '$DOTFILES_DIR/ghostty/config' '$HOME/.config/ghostty/config'"
  fi

  # git
  if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
    [[ -e "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]] && run "mv '$HOME/.gitconfig' '$HOME/.gitconfig.bak.$(date +%s)'"
    run "ln -sfn '$DOTFILES_DIR/git/.gitconfig' '$HOME/.gitconfig'"
  fi
  if [[ -f "$DOTFILES_DIR/git/.gitignore_global" ]]; then
    run "ln -sfn '$DOTFILES_DIR/git/.gitignore_global' '$HOME/.gitignore_global'"
  fi

  # .vim
  if [[ -d "$DOTFILES_DIR/.vim" ]]; then
    run "ln -sfn '$DOTFILES_DIR/.vim' '$HOME/.vim'"
  fi
}

# ─── Flow ───────────────────────────────────────────────────────────────────
collect_selections
confirm_selections

ensure_homebrew

RECEIPT="$HOME/.dotfiles-installed"
[[ $DRY_RUN -eq 0 ]] && : > "$RECEIPT.tmp"
for entry in "${SELECTED[@]}"; do
  IFS='|' read -r key kind target display <<<"$entry"
  install_one "$kind" "$target" "$display"
  [[ $DRY_RUN -eq 0 ]] && echo "$key" >> "$RECEIPT.tmp"
done
if [[ $DRY_RUN -eq 0 ]]; then
  mv "$RECEIPT.tmp" "$RECEIPT"
  log "Install receipt written to $RECEIPT"
fi

link_configs

run "brew cleanup || true"

echo
echo -e "${GREEN}${BOLD}✅ Setup complete.${NC}"
echo
echo "Next steps:"
echo "  1. Restart your terminal (or: source ~/.zshrc)"
echo '  2. Set zsh as default shell:  chsh -s "$(which zsh)"'
echo "  3. Configure Powerlevel10k:   p10k configure"
echo "  4. Open Docker Desktop once to finish its install"
echo -e "  5. Run ${BOLD}claude${NC} to set up Claude Code + maverick"
echo "  6. Open Neovim — plugins bootstrap via Lazy on first run"
echo
echo "Configs linked from: $DOTFILES_DIR"
