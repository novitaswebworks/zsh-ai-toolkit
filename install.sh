#!/usr/bin/env bash
set -e

echo -e "\033[36;1m⚡️ Welcome to the Zsh AI Toolkit Installer ⚡️\033[0m\n"

# 1. Check for Zsh
if [ -z "$(command -v zsh)" ]; then
    echo -e "\033[31mError: zsh is not installed. Please install zsh first.\033[0m"
    exit 1
fi

# 2. Get Groq API Key
echo "To power the AI, you need a free Groq API key from https://console.groq.com/keys"
read -p "Enter your Groq API Key (or press Enter to skip and add manually later): " API_KEY

# 3. Download files
echo -e "\n\033[36mDownloading core files...\033[0m"
OS_TYPE="linux"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
fi

BASE_URL="https://raw.githubusercontent.com/novitaswebworks/zsh-ai-toolkit/master/$OS_TYPE"

curl -sL "$BASE_URL/zsh_ai_tools.zsh" -o ~/.zsh_ai_tools
curl -sL "$BASE_URL/groq_autocomplete.zsh" -o ~/.groq_autocomplete.zsh

# 4. Setup Secrets
if [ -n "$API_KEY" ]; then
    echo -e "\033[36mSetting up ~/.zsh_secrets...\033[0m"
    cat << SECRETS > ~/.zsh_secrets
export OPENAI_BASE_URL="https://api.groq.com/openai/v1"
export OPENAI_API_KEY="$API_KEY"
export GROQ_API_KEY="$API_KEY"
export OPENAI_MODEL="qwen/qwen3.8-27b"
SECRETS
    chmod 600 ~/.zsh_secrets
fi

# 5. Modify .zshrc
echo -e "\033[36mInjecting source commands into ~/.zshrc...\033[0m"
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
    echo -e "\033[32mSuccessfully added to ~/.zshrc!\033[0m"
else
    echo -e "\033[33mAI Toolkit is already sourced in ~/.zshrc. Skipping.\033[0m"
fi

echo -e "\n\033[32;1m✅ Installation Complete!\033[0m"
echo -e "Please restart your terminal or run: \033[33msource ~/.zshrc\033[0m"
echo -e "Then type \033[33mai-help\033[0m to see your new commands!"
