# Dotfiles

> Opinionated macOS dev-machine bootstrap — one command, everything installed.

Polyglot setup for Go + gRPC, Rust, Elixir, Node/Bun, Python work on top
of Docker + Kubernetes (kind + Tilt). Runs every item in the catalog by
default; flags available if you want a subset.

## Quick start (fresh Mac)

```bash
git clone git@github.com:igorvieira/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

or one-liner:

```bash
git clone https://github.com/igorvieira/dotfiles.git ~/dotfiles && ~/dotfiles/setup.sh
```

That's it — it installs Homebrew (if missing), every tool in the catalog,
and symlinks the shell / git / ghostty configs. Takes a while on a fresh
machine because of the cask apps; walk away and come back.

### Flags

| Flag              | Behavior                                        |
| ----------------- | ----------------------------------------------- |
| *(none)*          | Install everything                              |
| `--minimal`       | Only shell + fonts                              |
| `--only k1,k2,…`  | Install exactly the listed catalog keys         |
| `--interactive`   | Opt into per-group / per-item picker (advanced) |
| `--dry-run`       | Print what would happen; no side effects        |

## What's in the catalog

All of the below are installed by default. Use `--only` to cherry-pick.

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

Full, authoritative list: [`lib/catalog.sh`](lib/catalog.sh).

## Neovim config

Not bundled here — lives at [igorvieira/nvim](https://github.com/igorvieira/nvim).
`setup.sh` clones it to `~/.config/nvim`; on later runs it does `git pull --ff-only`.

## Linked configs

`setup.sh` symlinks these into place (backing up any non-symlink originals):

- `~/.zshrc`, `~/.bashrc`, `~/.p10k.zsh`
- `~/.config/ghostty/config`
- `~/.gitconfig`, `~/.gitignore_global`
- `~/.vim`

Editing the files in the repo updates your live config immediately.

## Verifying the install

`setup.sh` writes a receipt to `~/.dotfiles-installed`.
`test-installation.sh` reads it and only checks what was actually installed.

```bash
./test-installation.sh              # check items in the receipt
./test-installation.sh --defaults   # check every default-on catalog item
./test-installation.sh --all        # check every catalog item
```

Config symlinks are always verified.

## Adding new tools

Open [`lib/catalog.sh`](lib/catalog.sh), find the right `GROUP_N_ITEMS`
array, and append a line:

```
"key|Display name|brew|formula|1|cmd:<bin>"      # brew formula
"key|Display name|cask|cask-name|0|app:/Applications/Foo.app"
"key|Display name|custom|install_fn|1|fn:check_foo"
```

Schema and conventions are fully documented in [`CLAUDE.md`](CLAUDE.md).

## CI

macOS-only workflow in `.github/workflows/test.yml`:

- `lint` — `bash -n` + `shellcheck -S warning`
- `dry-run` — `setup.sh` exercised in `--all` / `--minimal` / `--only` modes
- `install-minimal` — real install of a cheap brew-only slice + verify

## License

[MIT](LICENSE).
