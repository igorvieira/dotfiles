# Dotfiles

> Automated macOS development environment setup

This script automates environment setup on macOS, including development tools, applications, shell configuration, and dotfiles synchronization.

## What Gets Installed

**Development Tools:** Homebrew, Node.js, Bun, Rust, Docker, Neovim, rbenv

**Applications:** Brave Browser, Discord, Slack, Spotify, Ghostty, Raycast, Obsidian, Beekeeper Studio, NordVPN

**Shell Setup:** Zsh + Oh My Zsh + Powerlevel10k + Dracula theme + Nerd Fonts

**Configuration:** `.zshrc`, `.bashrc`, `nvim/`, `.vim/`, Git configuration

## Prerequisites

- macOS (tested on macOS 12.0+)
- Git and curl (usually pre-installed)

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/igorvieira/dotfiles/main/setup.sh | bash
```

Or manually:
```bash
git clone https://github.com/igorvieira/dotfiles.git
cd dotfiles
./setup.sh
```

The script will automatically:
- Install development tools and applications
- Configure Zsh with Oh My Zsh and Powerlevel10k
- Sync configuration files to your home directory
- Set up terminal with Dracula theme

## Testing

```bash
./test-installation.sh
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
