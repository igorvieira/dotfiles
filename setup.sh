#!/bin/bash

set -euo pipefail

# Check if Oh My Zsh is already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        echo "Error installing Oh My Zsh. Exiting..."
        exit 1
    }
    echo "Oh My Zsh installed successfully!"
else
    echo "Oh My Zsh is already installed!"
fi

# Clone the repository if it doesn't exist
REPO_DIR="$HOME/powerlevel10k"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning the powerlevel10k repository into $REPO_DIR..."
    git clone git@github.com:romkatv/powerlevel10k.git "$REPO_DIR" || {
        echo "Error cloning powerlevel10k repository. Exiting..."
        exit 1
    }
    echo "powerlevel10k repository cloned successfully!"
else
    echo "powerlevel10k repository already exists. Skipping cloning."
fi

# Copy nvim to .config
mkdir -p ~/.config
cp -r nvim ~/.config/ || {
    echo "Error copying nvim to ~/.config. Exiting..."
    exit 1
}
echo "nvim copied to ~/.config successfully!"

# Copy .vim folder to Mac root
cp -r .vim ~/ || {
    echo "Error copying .vim folder to Mac root. Exiting..."
    exit 1
}
echo ".vim folder copied to Mac root successfully!"

# Copy git folder to Mac root
cp -r git ~/ || {
    echo "Error copying git folder to Mac root. Exiting..."
    exit 1
}
echo "git folder copied to Mac root successfully!"

# Always overwrite .zshrc or .bashrc file to Mac root
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/ || [ $? -eq 1 ] || [ $? -eq 2 ] || {
        echo ".zshrc copied to Mac root successfully!"
    }
fi

if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/ || [ $? -eq 1 ] || [ $? -eq 2 ] || {
        echo ".bashrc copied to Mac root successfully!"
    }
fi


echo "All configurations copied successfully!"
