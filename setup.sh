#!/bin/bash

# Error Handling
set -euo pipefail

# Check if Oh My Zsh is already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Oh My Zsh installed successfully!"
else
    echo "Oh My Zsh is already installed!"
fi

# Clone the repository if it doesn't exist
REPO_DIR="$HOME/powerlevel10k"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning the powerlevel10k repository into $REPO_DIR..."
    git clone git@github.com:romkatv/powerlevel10k.git "$REPO_DIR"
    echo "powerlevel10k repository cloned successfully!"
else
    echo "powerlevel10k repository already exists. Skipping cloning."
fi

# Copy git folder to $HOME directory
GIT_DIR="$REPO_DIR/git"
if [ -d "$GIT_DIR" ]; then
    echo "Copying git directory to $HOME..."
    cp -r "$GIT_DIR" "$HOME/"
    echo "git directory copied successfully!"
else
    echo "Error: git directory not found!"
fi

# Synchronize .vim, .zshrc, and .bashrc files
echo "Synchronizing .vim, .zshrc, and .bashrc files to the home directory..."
rsync -av .vim .zshrc .bashrc ~/
echo "Files synchronized successfully!"

# Sourcing .zshrc
echo "Sourcing .zshrc..."
source ~/.zshrc
echo ".zshrc sourced successfully!"

# Synchronize the nvim folder to the .config directory
NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
    mkdir -p "$NVIM_DIR"
fi

echo "Synchronizing nvim folder to the .config directory..."
rsync -av nvim/ "$NVIM_DIR/"
echo "nvim folder synchronized successfully!"

echo "Setup completed successfully! You're all set!"

