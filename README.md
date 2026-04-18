# Dotfiles

> Interactive macOS development environment bootstrap

Opinionated setup for a macOS dev machine. Pick what you want, confirm at the end,
and let it install. Designed for polyglot work (Go + gRPC, Rust, Elixir, Node/Bun,
Python) on top of Docker + Kubernetes (kind + Tilt).

## Quick start

```bash
git clone git@github.com:igorvieira/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

Or one-shot via curl (clone-then-run so relative configs are linked correctly):

```bash
git clone https://github.com/igorvieira/dotfiles.git ~/dotfiles && ~/dotfiles/setup.sh
```

### Flags

| Flag         | Behavior                                           |
| ------------ | -------------------------------------------------- |
| *(none)*     | Interactive — per-group All / Select / None       |
| `--all`      | Install every catalog item non-interactively      |
| `--minimal`  | Only shell + fonts                                 |
| `--dry-run`  | Print what would be installed; change nothing      |

## What's in the catalog

Grouped so you can accept defaults per group or cherry-pick individual items.

- **Shell & Prompt** — zsh, Oh My Zsh, Powerlevel10k, autosuggestions, syntax highlighting
- **Fonts** — FiraCode / JetBrains Mono / Hack Nerd Fonts
- **Terminals** — Ghostty, Rio, iTerm2
- **Editors** — Neovim (+ clones [igorvieira/nvim](https://github.com/igorvieira/nvim) into `~/.config/nvim`), VS Code, Cursor
- **Languages** — Go, Rust, Node, Bun, pnpm, Elixir, Python+uv, rbenv, Deno
- **Go / gRPC** — protobuf, protoc-gen-go, protoc-gen-go-grpc, grpcurl, golang-migrate, buf
- **Cloud & DevOps** — Docker Desktop, kubectl, kind, Tilt, ctlptl, Helm, k9s, AWS CLI, Doppler, Terraform
- **CLI Essentials** — git, gh, ripgrep, fzf, bat, eza, jq, yq, lazygit, tmux, htop, wget, gnupg, tree
- **AI tooling** — Claude Code CLI (loads `maverick` + other skills from `~/.claude/`)
- **Apps** — Brave, Chrome, Raycast, Obsidian, Loom, Slack, Discord, Zoom, Beekeeper Studio, DBeaver, Spotify, NordVPN, VirtualBox

## Neovim config

The Neovim config is **not bundled here** — it lives in its own repo:
[igorvieira/nvim](https://github.com/igorvieira/nvim). `setup.sh` clones it to
`~/.config/nvim`; on subsequent runs it does `git pull --ff-only`.

## Linked configs

`setup.sh` symlinks these into place (backing up any non-symlink originals):

- `~/.zshrc`, `~/.bashrc`, `~/.p10k.zsh`
- `~/.config/ghostty/config`
- `~/.gitconfig`, `~/.gitignore_global`
- `~/.vim`

Editing the files in the repo updates your live config immediately.

## Adding new tools

Open `setup.sh`, find the right `GROUP_N_ITEMS` array, and add a line:

```
"key|Display name|brew|formula-name|1"     # brew formula, default on
"key|Display name|cask|cask-name|0"        # cask, default off
"key|Display name|custom|install_fn|1"     # calls bash function install_fn
```

## Testing

```bash
./test-installation.sh
```

## License

[MIT](LICENSE).
