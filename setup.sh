#!/bin/bash

# Mac Setup Script - Dotfiles
# To run: chmod +x setup-mac.sh && ./setup-mac.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is only for macOS"
    exit 1
fi

log "🚀 Starting Mac setup..."

# 1. Install Homebrew
log "📦 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        error "Error installing Homebrew. Exiting..."
        exit 1
    }
    
    # Add brew to PATH
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    log "Homebrew installed successfully!"
else
    log "Homebrew already installed"
fi

# 2. Update Homebrew
log "🔄 Updating Homebrew..."
brew update

# 3. Install Zsh
log "🐚 Installing Zsh..."
if ! command -v zsh &> /dev/null; then
    brew install zsh
fi

# Set zsh as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
    log "Zsh set as default shell"
fi

# 4. Install Oh My Zsh
log "🎨 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        error "Error installing Oh My Zsh. Exiting..."
        exit 1
    }
    echo "Oh My Zsh installed successfully!"
else
    echo "Oh My Zsh is already installed!"
fi

# 5. Clone Powerlevel10k repository
log "⚡ Setting up Powerlevel10k..."
REPO_DIR="$HOME/powerlevel10k"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning the powerlevel10k repository into $REPO_DIR..."
    git clone https://github.com/romkatv/powerlevel10k.git "$REPO_DIR" || {
        error "Error cloning powerlevel10k repository. Exiting..."
        exit 1
    }
    echo "powerlevel10k repository cloned successfully!"
else
    echo "powerlevel10k repository already exists. Skipping cloning."
fi

# 6. Install development tools
log "🛠️  Installing development tools..."

# Docker
log "🐳 Installing Docker..."
brew install --cask docker

# Neovim
log "📝 Installing Neovim..."
brew install neovim

# Node.js
log "📦 Installing Node.js..."
brew install node

# Rust
log "🦀 Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    log "Rust installed successfully!"
else
    log "Rust already installed"
fi

# Bun
log "🍞 Installing Bun..."
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    log "Bun installed successfully!"
else
    log "Bun already installed"
fi

# 7. Install applications
log "📱 Installing applications..."

# Spotify
log "🎵 Installing Spotify..."
brew install --cask spotify

# Brave Browser
log "🦁 Installing Brave Browser..."
brew install --cask brave-browser

# Obsidian
log "📓 Installing Obsidian..."
brew install --cask obsidian

# Beekeeper Studio
log "🐝 Installing Beekeeper Studio..."
brew install --cask beekeeper-studio

# NordVPN
log "🛡️  Installing NordVPN..."
brew install --cask nordvpn

# Discord
log "💬 Installing Discord..."
brew install --cask discord

# 8. Copy configuration files and folders
log "⚙️  Copying configuration files and folders..."

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Copy nvim to .config
if [ -d "nvim" ]; then
    cp -r nvim ~/.config/ || {
        error "Error copying nvim to ~/.config. Exiting..."
        exit 1
    }
    echo "nvim copied to ~/.config successfully!"
else
    warn "nvim folder not found in current directory"
fi

# Copy .vim folder to Mac root
if [ -d ".vim" ]; then
    cp -r .vim ~/ || {
        error "Error copying .vim folder to Mac root. Exiting..."
        exit 1
    }
    echo ".vim folder copied to Mac root successfully!"
else
    warn ".vim folder not found in current directory"
fi

# Copy git folder to Mac root
if [ -d "git" ]; then
    cp -r git ~/ || {
        error "Error copying git folder to Mac root. Exiting..."
        exit 1
    }
    echo "git folder copied to Mac root successfully!"
else
    warn "git folder not found in current directory"
fi

# Always overwrite .zshrc or .bashrc file to Mac root
if [ -f ".zshrc" ]; then
    cp .zshrc ~/ || {
        warn "Could not copy .zshrc to Mac root"
    }
    echo ".zshrc copied to Mac root successfully!"
else
    warn ".zshrc file not found in current directory"
fi

if [ -f ".bashrc" ]; then
    cp .bashrc ~/ || {
        warn "Could not copy .bashrc to Mac root"
    }
    echo ".bashrc copied to Mac root successfully!"
else
    warn ".bashrc file not found in current directory"
fi

# 9. Install useful Zsh plugins
log "🔌 Installing Zsh plugins..."

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    log "zsh-syntax-highlighting installed"
fi

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    log "zsh-autosuggestions installed"
fi

# 10. Final configurations
log "🎯 Final configurations..."

# Add useful aliases and PATH to .zshrc if not already present
if ! grep -q "# Custom configurations" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'

# ===========================================
# Custom configurations
# ===========================================

# PATH for tools
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

# Useful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Node/npm aliases
alias ni='npm install'
alias nr='npm run'
alias ns='npm start'
alias nd='npm run dev'

# Neovim alias
alias v='nvim'
alias vim='nvim'

EOF
    log "Custom configurations added to .zshrc"
fi

# Clean Homebrew cache
brew cleanup

log "✅ Setup completed!"
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}           SETUP COMPLETED! 🎉            ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo "Installed tools:"
echo "• Homebrew"
echo "• Zsh + Oh My Zsh + Powerlevel10k"
echo "• Docker"
echo "• Neovim"
echo "• Node.js"
echo "• Rust"
echo "• Bun"
echo "• Spotify"
echo "• Brave Browser"
echo "• Obsidian"
echo "• Beekeeper Studio"
echo "• NordVPN"
echo "• Discord"
echo ""
echo "Copied configurations:"
echo "• nvim → ~/.config/nvim"
echo "• .vim → ~/.vim"
echo "• git → ~/git"
echo "• .zshrc → ~/.zshrc"
echo "• .bashrc → ~/.bashrc (if exists)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Restart terminal or run: source ~/.zshrc"
echo "2. Open Docker and complete initial setup"
echo "3. Configure your accounts in installed applications"
echo "4. Run 'p10k configure' to setup Powerlevel10k theme"
echo ""
echo -e "${GREEN}All configurations copied successfully! Happy coding! 🚀${NC}"
