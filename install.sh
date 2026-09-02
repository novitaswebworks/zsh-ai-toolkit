#!/usr/bin/env bash
set -e

# Colors
CYAN="\033[36;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
RED="\033[31;1m"
RESET="\033[0m"

echo -e "${CYAN}⚡️ Welcome to the Zsh AI Toolkit Installer ⚡️${RESET}\n"

# 0. Backup original .zshrc
if [ -f ~/.zshrc ]; then
    BACKUP_FILE="$HOME/.zshrc.backup_$(date +%s)"
    cp ~/.zshrc "$BACKUP_FILE"
    echo -e "${GREEN}✅ Backed up your original .zshrc to $BACKUP_FILE${RESET}"
fi

# 1. Check for Zsh and Auto-Install
if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}Zsh is not installed. Attempting to install automatically...${RESET}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        echo -e "${RED}Error: Could not detect package manager. Please install zsh manually.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✅ Zsh successfully installed!${RESET}"
else
    echo -e "${GREEN}✅ Zsh is already installed.${RESET}"
fi

# 2. Provider Selection
echo -e "\n${CYAN}Which AI Provider would you like to use?${RESET}"
echo "1) Groq (Blazing fast, Open-source models)"
echo "2) OpenAI (ChatGPT, GPT-4o)"
echo "3) OpenRouter (Access to Claude, Gemini, LLaMA)"
read -p "Select an option [1-3]: " PROVIDER_CHOICE

BASE_URL=""
MODEL=""
case $PROVIDER_CHOICE in
    1)
        BASE_URL="https://api.groq.com/openai/v1"
        MODEL="qwen/qwen3.8-27b"
        PROVIDER_NAME="Groq"
        URL_HINT="https://console.groq.com/keys"
        ;;
    2)
        BASE_URL="https://api.openai.com/v1"
        MODEL="gpt-4o-mini"
        PROVIDER_NAME="OpenAI"
        URL_HINT="https://platform.openai.com/api-keys"
        ;;
    3)
        BASE_URL="https://openrouter.ai/api/v1"
        MODEL="anthropic/claude-3.5-sonnet"
        PROVIDER_NAME="OpenRouter"
        URL_HINT="https://openrouter.ai/keys"
        ;;
    *)
        echo -e "${RED}Invalid choice. Defaulting to Groq.${RESET}"
        BASE_URL="https://api.groq.com/openai/v1"
        MODEL="qwen/qwen3.8-27b"
        PROVIDER_NAME="Groq"
        URL_HINT="https://console.groq.com/keys"
        ;;
esac

echo -e "\nTo power the AI, you need a free API key from ${YELLOW}$URL_HINT${RESET}"
read -p "Enter your $PROVIDER_NAME API Key (or press Enter to skip): " API_KEY

# 3. Download files
echo -e "\n${CYAN}Downloading core files...${RESET}"
OS_TYPE="linux"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
fi

REPO_URL="https://raw.githubusercontent.com/novitaswebworks/zsh-ai-toolkit/master/$OS_TYPE"

curl -sL "$REPO_URL/zsh_ai_tools.zsh" -o ~/.zsh_ai_tools
curl -sL "$REPO_URL/groq_autocomplete.zsh" -o ~/.groq_autocomplete.zsh
echo -e "${GREEN}✅ Downloaded AI tools.${RESET}"

# 4. Setup Secrets
if [ -n "$API_KEY" ]; then
    echo -e "${CYAN}Setting up ~/.zsh_secrets...${RESET}"
    cat << SECRETS > "$HOME/.zsh_secrets"
export OPENAI_BASE_URL="$BASE_URL"
export OPENAI_API_KEY="$API_KEY"
export GROQ_API_KEY="$API_KEY"
export OPENAI_MODEL="$MODEL"
SECRETS
    chmod 600 "$HOME/.zsh_secrets"
    echo -e "${GREEN}✅ Saved API key securely.${RESET}"
fi

# 5. Modify .zshrc
echo -e "${CYAN}Injecting source commands into ~/.zshrc...${RESET}"
if ! grep -q "zsh_ai_tools" ~/.zshrc; then
    cat << 'ZSHRC' >> ~/.zshrc

# ==============================
# ZSH AI TOOLKIT
# ==============================
if [[ -f "$HOME/.zsh_secrets" ]]; then
  source "$HOME/.zsh_secrets"
fi
if [[ -f "$HOME/.groq_autocomplete.zsh" ]]; then
  source "$HOME/.groq_autocomplete.zsh"
fi
if [[ -f "$HOME/.zsh_ai_tools" ]]; then
  source "$HOME/.zsh_ai_tools"
fi
ZSHRC
    echo -e "${GREEN}✅ Successfully added to ~/.zshrc!${RESET}"
else
    echo -e "${YELLOW}AI Toolkit is already sourced in ~/.zshrc. Skipping.${RESET}"
fi

echo -e "\n${GREEN}✅ Installation Complete!${RESET}"
echo -e "Please restart your terminal or run: ${YELLOW}source ~/.zshrc${RESET}"
echo -e "Then type ${YELLOW}ai-help${RESET} to see your new commands!"
