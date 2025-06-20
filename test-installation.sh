#!/bin/bash

# Test Installation Script
# Tests if all tools and applications were installed correctly
# To run: chmod +x test-installation.sh && ./test-installation.sh

# Remove set -e to continue testing even if some tests fail
set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Logging functions
log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ PASS${NC} $1"
    ((PASSED_TESTS++))
}

fail() {
    echo -e "${RED}❌ FAIL${NC} $1"
    ((FAILED_TESTS++))
}

warn() {
    echo -e "${YELLOW}⚠️  WARN${NC} $1"
}

# Test function for commands
test_command() {
    local name="$1"
    local command="$2"
    ((TOTAL_TESTS++))
    
    echo -n "Testing $name... "
    
    if command -v "$command" &> /dev/null; then
        local version=""
        case "$command" in
            "brew") 
                version=$(brew --version 2>/dev/null | head -n1 | cut -d' ' -f2 2>/dev/null || echo "unknown") 
                ;;
            "zsh") 
                version=$(zsh --version 2>/dev/null | cut -d' ' -f2 2>/dev/null || echo "unknown") 
                ;;
            "git") 
                version=$(git --version 2>/dev/null | cut -d' ' -f3 2>/dev/null || echo "unknown") 
                ;;
            "node") 
                version=$(node --version 2>/dev/null || echo "unknown") 
                ;;
            "npm") 
                version=$(npm --version 2>/dev/null || echo "unknown") 
                ;;
            "rustc") 
                version=$(rustc --version 2>/dev/null | cut -d' ' -f2 2>/dev/null || echo "unknown") 
                ;;
            "bun") 
                version=$(bun --version 2>/dev/null || echo "unknown") 
                ;;
            "rbenv") 
                version=$(rbenv --version 2>/dev/null | cut -d' ' -f2 2>/dev/null || echo "unknown") 
                ;;
            "nvim") 
                version=$(nvim --version 2>/dev/null | head -n1 | cut -d' ' -f2 2>/dev/null || echo "unknown") 
                ;;
            "docker") 
                version=$(docker --version 2>/dev/null | cut -d' ' -f3 2>/dev/null | tr -d ',' || echo "unknown") 
                ;;
            *) 
                version="installed" 
                ;;
        esac
        success "$name - $version"
    else
        fail "$name - command not found"
    fi
}

# Test application installation
test_app() {
    local name="$1"
    local path="$2"
    ((TOTAL_TESTS++))
    
    echo -n "Testing $name... "
    
    if [ -d "$path" ]; then
        success "$name - installed"
    else
        fail "$name - not found"
    fi
}

# Test file/directory
test_file() {
    local name="$1"
    local path="$2"
    ((TOTAL_TESTS++))
    
    echo -n "Testing $name... "
    
    if [ -e "$path" ]; then
        success "$name - found"
    else
        fail "$name - not found"
    fi
}

# Test zsh plugin
test_zsh_plugin() {
    local name="$1"
    local path="$2"
    ((TOTAL_TESTS++))
    
    echo -n "Testing Zsh Plugin: $name... "
    
    if [ -d "$path" ]; then
        success "$name plugin - installed"
    else
        fail "$name plugin - not found"
    fi
}

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}        TESTING INSTALLATION 🧪           ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 1. Test Homebrew
log "Testing Homebrew..."
test_command "Homebrew" "brew"
echo ""

# 2. Test Shell and Terminal Tools
log "Testing Shell and Terminal Tools..."
test_command "Zsh" "zsh"
test_command "Git" "git"

# Test Oh My Zsh
test_file "Oh My Zsh" "$HOME/.oh-my-zsh"

# Test Powerlevel10k
test_file "Powerlevel10k (standalone)" "$HOME/powerlevel10k"
test_file "Powerlevel10k (Oh My Zsh theme)" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
echo ""

# 3. Test Development Tools
log "Testing Development Tools..."
test_command "Node.js" "node"
test_command "npm" "npm"
test_command "Rust" "rustc"
test_command "Cargo (Rust package manager)" "cargo"
test_command "Bun" "bun"
test_command "rbenv" "rbenv"
test_command "Neovim" "nvim"
test_command "Docker" "docker"
echo ""

# 4. Test Applications
log "Testing Applications..."
test_app "Docker Desktop" "/Applications/Docker.app"
test_app "Spotify" "/Applications/Spotify.app"
test_app "Brave Browser" "/Applications/Brave Browser.app"
test_app "Obsidian" "/Applications/Obsidian.app"
test_app "Beekeeper Studio" "/Applications/Beekeeper Studio.app"
test_app "NordVPN" "/Applications/NordVPN.app"
test_app "Discord" "/Applications/Discord.app"
test_app "Slack" "/Applications/Slack.app"
test_app "Ghostty" "/Applications/Ghostty.app"
test_app "Raycast" "/Applications/Raycast.app"
echo ""

# 5. Test Nerd Fonts
log "Testing Nerd Fonts..."

# Check if fontconfig is available for font testing
if command -v fc-list &> /dev/null; then
    # Test Fira Code Nerd Font
    ((TOTAL_TESTS++))
    echo -n "Testing Fira Code Nerd Font... "
    if fc-list 2>/dev/null | grep -i "fira.*code.*nerd" > /dev/null 2>&1; then
        success "Fira Code Nerd Font - found"
    else
        fail "Fira Code Nerd Font - not found"
    fi

    # Test Hack Nerd Font
    ((TOTAL_TESTS++))
    echo -n "Testing Hack Nerd Font... "
    if fc-list 2>/dev/null | grep -i "hack.*nerd" > /dev/null 2>&1; then
        success "Hack Nerd Font - found"
    else
        fail "Hack Nerd Font - not found"
    fi

    # Test JetBrains Mono Nerd Font
    ((TOTAL_TESTS++))
    echo -n "Testing JetBrains Mono Nerd Font... "
    if fc-list 2>/dev/null | grep -i "jetbrains.*mono.*nerd" > /dev/null 2>&1; then
        success "JetBrains Mono Nerd Font - found"
    else
        fail "JetBrains Mono Nerd Font - not found"
    fi
else
    # Alternative method for macOS without fc-list
    ((TOTAL_TESTS++))
    echo -n "Testing Fira Code Nerd Font... "
    if ls /System/Library/Fonts/ /Library/Fonts/ ~/Library/Fonts/ 2>/dev/null | grep -i "fira.*code.*nerd" > /dev/null 2>&1; then
        success "Fira Code Nerd Font - found"
    else
        warn "Cannot verify Fira Code Nerd Font (fontconfig not available)"
    fi

    ((TOTAL_TESTS++))
    echo -n "Testing Hack Nerd Font... "
    if ls /System/Library/Fonts/ /Library/Fonts/ ~/Library/Fonts/ 2>/dev/null | grep -i "hack.*nerd" > /dev/null 2>&1; then
        success "Hack Nerd Font - found"
    else
        warn "Cannot verify Hack Nerd Font (fontconfig not available)"
    fi

    ((TOTAL_TESTS++))
    echo -n "Testing JetBrains Mono Nerd Font... "
    if ls /System/Library/Fonts/ /Library/Fonts/ ~/Library/Fonts/ 2>/dev/null | grep -i "jetbrains.*mono.*nerd" > /dev/null 2>&1; then
        success "JetBrains Mono Nerd Font - found"
    else
        warn "Cannot verify JetBrains Mono Nerd Font (fontconfig not available)"
    fi
fi
echo ""

# 6. Test Configuration Files
log "Testing Configuration Files..."
test_file "Neovim config" "$HOME/.config/nvim"
test_file ".vim folder" "$HOME/.vim"
test_file "Git folder" "$HOME/git"
test_file ".zshrc" "$HOME/.zshrc"

# Check if .bashrc exists (optional)
if [ -f "$HOME/.bashrc" ]; then
    ((TOTAL_TESTS++))
    echo -n "Testing .bashrc file... "
    success ".bashrc file - found"
else
    warn ".bashrc file - not found (this is optional)"
fi
echo ""

# 7. Test Zsh Plugins
log "Testing Zsh Plugins..."
ZSH_CUSTOM_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
test_zsh_plugin "zsh-syntax-highlighting" "$ZSH_CUSTOM_PATH/plugins/zsh-syntax-highlighting"
test_zsh_plugin "zsh-autosuggestions" "$ZSH_CUSTOM_PATH/plugins/zsh-autosuggestions"
test_zsh_plugin "Dracula theme" "$ZSH_CUSTOM_PATH/themes/dracula"
echo ""

# 8. Test Environment Variables and PATH
log "Testing Environment Configuration..."

# Test if Rust is in PATH
((TOTAL_TESTS++))
echo -n "Testing Rust in PATH... "
if echo "$PATH" | grep -q "$HOME/.cargo/bin" || command -v rustc &> /dev/null; then
    success "Rust in PATH"
else
    fail "Rust not in PATH"
fi

# Test if Bun is in PATH
((TOTAL_TESTS++))
echo -n "Testing Bun in PATH... "
if echo "$PATH" | grep -q "$HOME/.bun/bin" || command -v bun &> /dev/null; then
    success "Bun in PATH"
else
    fail "Bun not in PATH"
fi

# Test if custom configurations are in .zshrc
((TOTAL_TESTS++))
echo -n "Testing custom configurations... "
if grep -q "# Custom configurations" "$HOME/.zshrc" 2>/dev/null; then
    success "Custom configurations in .zshrc"
else
    fail "Custom configurations not found in .zshrc"
fi
echo ""

# 9. Test Aliases (in current shell if possible)
log "Testing Aliases..."

# Common aliases to test
ALIASES_TO_TEST=("ll" "la" "g" "gs" "ga" "gc" "d" "dc" "ni" "nr" "v")
for alias_name in "${ALIASES_TO_TEST[@]}"; do
    ((TOTAL_TESTS++))
    echo -n "Testing alias: $alias_name... "
    # Check if alias exists in .zshrc file
    if grep -q "alias $alias_name=" "$HOME/.zshrc" 2>/dev/null; then
        success "Alias: $alias_name - defined"
    else
        warn "Alias: $alias_name - not found"
    fi
done
echo ""

# 10. Test Default Shell
log "Testing Default Shell..."
((TOTAL_TESTS++))
echo -n "Testing default shell... "
if [[ "$SHELL" == *"zsh"* ]]; then
    success "Default shell set to Zsh"
else
    fail "Default shell is not Zsh (current: $SHELL)"
fi

# 11. Test rbenv initialization
((TOTAL_TESTS++))
echo -n "Testing rbenv configuration... "
if grep -q "rbenv init" "$HOME/.zshrc" 2>/dev/null; then
    success "rbenv initialization configured"
else
    fail "rbenv initialization not found"
fi
echo ""

# Summary
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}           TEST RESULTS 📊                ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo ""

# Calculate success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
else
    SUCCESS_RATE=0
fi

# Display results
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Installation completed successfully!${NC}"
elif [ $SUCCESS_RATE -ge 90 ]; then
    echo -e "${YELLOW}⚠️  Most tests passed ($SUCCESS_RATE%). Check failed items above.${NC}"
elif [ $SUCCESS_RATE -ge 70 ]; then
    echo -e "${YELLOW}⚠️  Some issues found ($SUCCESS_RATE% success rate). Review failed tests.${NC}"
else
    echo -e "${RED}❌ Many tests failed ($SUCCESS_RATE% success rate). Installation may have issues.${NC}"
fi

echo ""
echo -e "${BLUE}Troubleshooting tips:${NC}"
echo "• If aliases are not working, restart your terminal or run: source ~/.zshrc"
echo "• If fonts are not detected, restart applications that use them"
echo "• If PATH issues exist, restart terminal or run: source ~/.zshrc"
echo "• For Docker, make sure Docker Desktop is running"
echo "• For applications, check if they need to be launched once for proper setup"
echo ""

# Exit with number of failed tests (0 = success)
exit $FAILED_TESTS
