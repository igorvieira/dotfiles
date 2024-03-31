# Dotfiles

> Environment Configuration

This Bash script automates environment setup on macOS, including Oh My Zsh installation, theme configuration, and configuration file synchronization.

## Prerequisites

- macOS (tested on macOS Catalina and Big Sur)
- Git (for cloning repositories)
- Curl (for downloading files via URL)

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/<USERNAME>/<REPOSITORY_NAME>/main/setup.sh | bash
```

Follow the instructions displayed in the terminal. The script will perform the following:

    - Download and install Oh My Zsh.
    - Clone the powerlevel10k repository to the user's home directory, if not already present.
    - Synchronize `.vim`, `.zshrc`, and `.bashrc` files to the user's home directory.
    - Synchronize the `nvim` folder to the user's `.config` directory.
    - Source te `.zshrc` file to apply changes immediately.

Upon completion, your environment will be configured and ready to use.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request to improve this script.

## License

This project is licensed under the [MIT License](LICENSE).
