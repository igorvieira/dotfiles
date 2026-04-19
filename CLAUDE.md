# Agent guide

This file tells an AI coding agent (Claude Code or similar) how to read and
modify this repo. Read it first before editing anything here.

## Purpose

macOS dev-machine bootstrap. `setup.sh` presents a catalog of tools/apps,
the user picks what to install, and a **receipt** of installed keys is
written to `~/.dotfiles-installed`. `test-installation.sh` reads that
receipt and verifies everything is actually present.

## Layout (entry points)

```
setup.sh                  # the installer. Flags: --all --minimal --only K,… --yes --dry-run
test-installation.sh      # the verifier. Flags: (none)=receipt, --defaults, --all
lib/catalog.sh            # single source of truth: what can be installed and how to verify it
.github/workflows/test.yml  # macOS-only CI: lint + dry-run + minimal install+verify
.zshrc .bashrc .p10k.zsh    # shell configs, symlinked into $HOME by setup.sh
ghostty/config              # terminal config, symlinked to ~/.config/ghostty/config
git/.gitconfig              # git config, symlinked to ~/.gitconfig
git/.gitignore_global       # global gitignore, symlinked to ~/.gitignore_global
.vim/                       # vim data dir, symlinked to ~/.vim
```

There is **no bundled neovim config**. `setup.sh` clones
[igorvieira/nvim](https://github.com/igorvieira/nvim) to `~/.config/nvim`.
Don't add a `nvim/` directory here.

## Catalog format (`lib/catalog.sh`)

One array per group: `GROUP_0_ITEMS` … `GROUP_15_ITEMS`, names in
`GROUP_NAMES`. Each entry is pipe-delimited with **6 fields**:

```
key | display | kind | target | default | check
```

| Field | Values |
|------|--------|
| `key`     | stable short id (lowercase, hyphens). Used in the receipt and with `--only`. |
| `display` | human label shown in prompts and test output. |
| `kind`    | `brew` \| `cask` \| `custom` |
| `target`  | brew/cask package name, **or** bash function name for `kind=custom`. |
| `default` | `1` = preselected in interactive/`--all`, `0` = opt-in. |
| `check`   | verification spec (see below). |

### Check specs

Evaluated by `evaluate_check` in `lib/catalog.sh`:

| Spec | Pass condition |
|------|---------------|
| `cmd:foo`    | `command -v foo` succeeds |
| `app:/Applications/Foo.app` | directory exists |
| `dir:/some/path`  | directory exists (may reference `$HOME`) |
| `file:/some/file` | file exists |
| `fn:check_foo`    | bash function returns 0 |
| `none`            | skipped in tests |

## Adding a new item

1. Pick the right group (or add a new `GROUP_<n>_ITEMS` array and append its
   label to `GROUP_NAMES` at the **same index**).
2. Append an entry. Examples:

   ```
   "ripgrep|ripgrep|brew|ripgrep|1|cmd:rg"
   "cursor|Cursor|cask|cursor|0|app:/Applications/Cursor.app"
   "claude|Claude Code CLI (maverick + skills)|custom|install_claude|1|cmd:claude"
   ```

3. For `kind=custom`, define the installer function in `setup.sh` below
   the `# ─── Installation primitives ───` marker. It should be idempotent.
4. If the item needs a verification no existing spec can express, write a
   `check_*` function in `lib/catalog.sh` and reference it as `fn:check_foo`.
5. Run `./setup.sh --only <new-key> --dry-run --yes` to smoke-test.

## Removing / renaming an item

- Remove its entry from the group array.
- If it had a `custom` install function, delete it from `setup.sh`.
- If it had a `fn:` check, delete that function from `lib/catalog.sh`.
- Receipts on users' machines may still reference old keys — verify:
  old keys silently fail (that's fine; no code path depends on them).

## Modes

| Mode             | How it builds SELECTED |
|------------------|------------------------|
| *(default)*      | every catalog item — same as `--all` |
| `--all`          | every catalog item, regardless of `default` |
| `--minimal`      | every default-on item in groups 0–1 (shell + fonts) |
| `--only K1,K2,…` | exactly the listed keys, in given order |
| `--interactive`  | per-group [A]ll/[s]elect/[N]one prompts |

`--dry-run` prints every action prefixed with `DRY:` and suppresses
receipt writing. `--yes` is the default except in `--interactive` mode,
where it re-enables the final confirm prompt (`--yes` skips it).

## Conventions

- **bash 3.2-compatible.** macOS ships 3.2; don't use namerefs (`local -n`),
  associative arrays, or `readarray`. Iterate indirect arrays via
  `group_items` (which uses `eval "printf … \${GROUP_${1}_ITEMS[@]}"`).
- **`set -euo pipefail`** is on in `setup.sh`. A function ending in
  a short-circuited `&&` can trigger `set -e` in the caller; end such
  functions with `return 0`.
- **Symlinks, not copies.** `link_configs` symlinks repo files into
  `$HOME`, backing up any pre-existing non-symlink originals.
- **No side effects on dry-run.** Anything that writes to disk goes through
  `run "…"`, which short-circuits when `DRY_RUN=1`. The receipt write is
  also guarded.
- **Receipts are authoritative for test scope.** `test-installation.sh`
  defaults to receipt mode. Override with `--all` or `--defaults`.
- **No `Co-Authored-By` in commits.** Plain commit messages only.

## CI (`.github/workflows/test.yml`)

macOS runners only. Three jobs:

- `lint`            — `bash -n` + `shellcheck -S warning`
- `dry-run`         — `setup.sh --all/--minimal/--only … --dry-run --yes`
- `install-minimal` — real install of `jq,ripgrep,fzf,gh,bat,eza,tmux,htop`
  then `test-installation.sh` against the receipt.

If you add a new `custom` installer, consider adding its key to
`install-minimal` (only if it's cheap and brew-only; don't add casks).

## Quick sanity check before committing

```bash
bash -n setup.sh test-installation.sh lib/catalog.sh
shellcheck -S warning setup.sh test-installation.sh lib/catalog.sh
./setup.sh --all --dry-run --yes | tail
./setup.sh --only <your-new-key> --dry-run --yes
```
