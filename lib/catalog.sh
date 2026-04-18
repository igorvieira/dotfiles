#!/usr/bin/env bash
# Shared catalog for setup.sh and test-installation.sh.
#
# Entry format (pipe-delimited, 6 fields):
#   key | display | kind | target | default | check
#
# kind    — brew | cask | custom
# target  — brew/cask package name, OR function name for `custom`
# default — 1 (preselected) | 0
# check   — verification spec used by test-installation.sh:
#             cmd:<name>        command -v <name> must succeed
#             app:<path>        directory must exist (typically /Applications/*.app)
#             dir:<path>        directory must exist ($HOME/... allowed)
#             file:<path>       file must exist
#             fn:<name>         run bash function <name>, exit 0 == pass
#             none              no check (skip in tests)

GROUP_NAMES=(
  "Shell & Prompt"
  "Fonts"
  "Terminals"
  "Editors"
  "Languages & Runtimes"
  "Go / gRPC tooling"
  "Cloud & DevOps"
  "CLI Essentials"
  "AI tooling"
  "Apps — Browsers"
  "Apps — Productivity"
  "Apps — Communication"
  "Apps — Databases"
  "Apps — Media"
  "Apps — VPN / Networking"
  "Apps — Virtualization"
)

GROUP_0_ITEMS=(
  "zsh|Zsh shell|brew|zsh|1|cmd:zsh"
  "ohmyzsh|Oh My Zsh|custom|install_ohmyzsh|1|dir:$HOME/.oh-my-zsh"
  "p10k|Powerlevel10k prompt|custom|install_p10k|1|dir:$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  "zsh-plugins|zsh-autosuggestions + syntax-highlighting|custom|install_zsh_plugins|1|dir:$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
)

GROUP_1_ITEMS=(
  "font-fira|FiraCode Nerd Font|cask|font-fira-code-nerd-font|1|fn:check_font_fira"
  "font-jb|JetBrains Mono Nerd Font|cask|font-jetbrains-mono-nerd-font|1|fn:check_font_jb"
  "font-hack|Hack Nerd Font|cask|font-hack-nerd-font|0|fn:check_font_hack"
)

GROUP_2_ITEMS=(
  "ghostty|Ghostty terminal|cask|ghostty|1|app:/Applications/Ghostty.app"
  "rio|Rio terminal|cask|rio|0|app:/Applications/rio.app"
  "iterm2|iTerm2|cask|iterm2|0|app:/Applications/iTerm.app"
)

GROUP_3_ITEMS=(
  "neovim|Neovim (+ clone igorvieira/nvim)|custom|install_neovim|1|fn:check_neovim"
  "vscode|Visual Studio Code|cask|visual-studio-code|0|app:/Applications/Visual Studio Code.app"
  "cursor|Cursor|cask|cursor|0|app:/Applications/Cursor.app"
)

GROUP_4_ITEMS=(
  "go|Go|brew|go|1|cmd:go"
  "rust|Rust (via rustup)|custom|install_rust|1|cmd:rustc"
  "node|Node.js|brew|node|1|cmd:node"
  "bun|Bun|custom|install_bun|1|cmd:bun"
  "pnpm|pnpm|brew|pnpm|1|cmd:pnpm"
  "elixir|Elixir (+ Erlang)|brew|elixir|1|cmd:elixir"
  "python|Python + uv|custom|install_python|1|cmd:uv"
  "rbenv|rbenv (Ruby)|brew|rbenv|0|cmd:rbenv"
  "deno|Deno|brew|deno|0|cmd:deno"
)

GROUP_5_ITEMS=(
  "protobuf|protobuf compiler|brew|protobuf|1|cmd:protoc"
  "protoc-go|protoc-gen-go|brew|protoc-gen-go|1|cmd:protoc-gen-go"
  "protoc-grpc|protoc-gen-go-grpc|brew|protoc-gen-go-grpc|1|cmd:protoc-gen-go-grpc"
  "grpcurl|grpcurl|brew|grpcurl|1|cmd:grpcurl"
  "migrate|golang-migrate|brew|golang-migrate|1|cmd:migrate"
  "buf|buf (proto linter)|brew|buf|0|cmd:buf"
)

GROUP_6_ITEMS=(
  "docker|Docker Desktop|cask|docker|1|app:/Applications/Docker.app"
  "kubectl|kubectl|brew|kubernetes-cli|1|cmd:kubectl"
  "kind|kind (K8s in Docker)|brew|kind|1|cmd:kind"
  "tilt|Tilt|brew|tilt|1|cmd:tilt"
  "ctlptl|ctlptl|custom|install_ctlptl|1|cmd:ctlptl"
  "helm|Helm|brew|helm|1|cmd:helm"
  "k9s|k9s|brew|k9s|1|cmd:k9s"
  "awscli|AWS CLI|brew|awscli|1|cmd:aws"
  "doppler|Doppler CLI|custom|install_doppler|0|cmd:doppler"
  "terraform|Terraform|brew|terraform|0|cmd:terraform"
)

GROUP_7_ITEMS=(
  "git|git|brew|git|1|cmd:git"
  "gh|GitHub CLI|brew|gh|1|cmd:gh"
  "ripgrep|ripgrep|brew|ripgrep|1|cmd:rg"
  "fzf|fzf|brew|fzf|1|cmd:fzf"
  "bat|bat|brew|bat|1|cmd:bat"
  "eza|eza (ls replacement)|brew|eza|1|cmd:eza"
  "jq|jq|brew|jq|1|cmd:jq"
  "yq|yq|brew|yq|1|cmd:yq"
  "lazygit|lazygit|brew|lazygit|1|cmd:lazygit"
  "tmux|tmux|brew|tmux|1|cmd:tmux"
  "htop|htop|brew|htop|1|cmd:htop"
  "wget|wget|brew|wget|1|cmd:wget"
  "gnupg|gnupg|brew|gnupg|0|cmd:gpg"
  "tree|tree|brew|tree|0|cmd:tree"
)

GROUP_8_ITEMS=(
  "claude|Claude Code CLI (maverick + skills)|custom|install_claude|1|cmd:claude"
)

GROUP_9_ITEMS=(
  "brave|Brave Browser|cask|brave-browser|1|app:/Applications/Brave Browser.app"
  "chrome|Google Chrome|cask|google-chrome|0|app:/Applications/Google Chrome.app"
)

GROUP_10_ITEMS=(
  "raycast|Raycast|cask|raycast|1|app:/Applications/Raycast.app"
  "obsidian|Obsidian|cask|obsidian|1|app:/Applications/Obsidian.app"
  "loom|Loom|cask|loom|0|app:/Applications/Loom.app"
)

GROUP_11_ITEMS=(
  "slack|Slack|cask|slack|1|app:/Applications/Slack.app"
  "discord|Discord|cask|discord|1|app:/Applications/Discord.app"
  "zoom|Zoom|cask|zoom|0|app:/Applications/zoom.us.app"
)

GROUP_12_ITEMS=(
  "beekeeper|Beekeeper Studio|cask|beekeeper-studio|1|app:/Applications/Beekeeper Studio.app"
  "dbeaver|DBeaver Community|cask|dbeaver-community|0|app:/Applications/DBeaver.app"
)

GROUP_13_ITEMS=(
  "spotify|Spotify|cask|spotify|1|app:/Applications/Spotify.app"
)

GROUP_14_ITEMS=(
  "nordvpn|NordVPN|cask|nordvpn|0|app:/Applications/NordVPN.app"
)

GROUP_15_ITEMS=(
  "virtualbox|VirtualBox|cask|virtualbox|0|app:/Applications/VirtualBox.app"
)

# Bash 3.2-compatible iterator over GROUP_<n>_ITEMS
group_items() {
  eval "printf '%s\n' \"\${GROUP_${1}_ITEMS[@]}\""
}

# Emit every catalog entry across every group.
all_items() {
  local gidx
  for gidx in "${!GROUP_NAMES[@]}"; do
    group_items "$gidx"
  done
}

# Lookup a full entry by key.
find_item_by_key() {
  local key="$1" entry k rest
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    k="${entry%%|*}"
    if [[ "$k" == "$key" ]]; then
      printf '%s\n' "$entry"
      return 0
    fi
  done < <(all_items)
  return 1
}

# ─── Check helpers (used by check specs of kind fn:*) ──────────────────────
check_font_fira() { ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "FiraCode"; }
check_font_jb()   { ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "JetBrainsMono"; }
check_font_hack() { ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "Hack"; }

check_neovim() {
  command -v nvim >/dev/null 2>&1 && [[ -d "$HOME/.config/nvim" ]]
}

# Evaluate a check spec. Returns 0 on pass, 1 on fail, 2 on skip.
evaluate_check() {
  local spec="$1"
  case "$spec" in
    none) return 2 ;;
    cmd:*)  command -v "${spec#cmd:}" >/dev/null 2>&1 ;;
    app:*)  [[ -d "${spec#app:}" ]] ;;
    dir:*)  [[ -d "${spec#dir:}" ]] ;;
    file:*) [[ -f "${spec#file:}" ]] ;;
    fn:*)   "${spec#fn:}" ;;
    *)      return 2 ;;
  esac
}
