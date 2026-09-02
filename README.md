# Blazing Fast AI Terminal Toolkit (Groq Powered) ⚡️

Turn your terminal into a contextual AI assistant that responds in milliseconds. 
This toolkit injects Groq's high-speed inference directly into your Zsh/PowerShell environment without the bloated dependencies of other CLI tools.

## Features
- **Ctrl+G Autocomplete**: Press `Ctrl+G` to turn plain English into a bash command instantly.
- **`fix`**: Grabs your last failed command and tells you how to fix it.
- **`gac`**: Auto-generates semantic git commit messages based on your `git diff`.
- **`hog`**: Uses AI to diagnose what's slowing down your Mac/Linux machine.
- **`write-script`**: Ghostwrites and `chmod +x` a bash/powershell script from a prompt.
- **Cross-Platform**: Supports macOS, Linux, and Windows PowerShell.

## Installation
See the directories (`mac/`, `linux/`, `windows/`) for the specific scripts and setup instructions. You just need to source them in your `.zshrc` or `$PROFILE`.

## Configuration
Requires a free [Groq API Key](https://console.groq.com/keys). Export it as `GROQ_API_KEY` in your environment.
