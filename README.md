# ⚡️ Blazing Fast AI Terminal Toolkit

Turn your terminal into a contextual, lightning-fast AI assistant. 
This toolkit injects **Groq's high-speed inference** directly into your Zsh environment, without the bloated dependencies of other CLI tools.

---

## 🌟 Features

*   ⌨️ **`Ctrl+G` (Autocomplete)**: Press `Ctrl+G` to turn plain English into an executable bash command instantly.
*   👻 **`auto-fix` (Invisible Assistant)**: Toggle this on, and the AI will silently catch your bad commands and magically inject the correct fix right into your prompt!
*   👨‍💻 **`code-review`**: Instantly runs a strict Senior Engineer code review on your uncommitted `git diff` before you open a PR.
*   🧹 **`tidy`**: The magical folder cleaner. Run `tidy ~/Downloads` to let the AI organize your messy files into smart subfolders. (Use `tidy --undo` to revert!)
*   🔮 **`tp` (Teleport)**: Never type long paths again. Run `tp "react frontend"` and it instantly jumps to the matching directory.
*   📖 **`explain`**: Replaces the boring Linux `man` command with the beautiful, AI-powered SmartMan TUI.
*   🚑 **`fix`**: Grabs your last failed command and tells you exactly how to fix it.
*   ⚙️ **`gac`**: Git Auto-Commit. Reads your `git diff` and generates a semantic commit message.
*   ☠️ **`toxic-shell`**: Turn this on to have the AI ruthlessly roast your intelligence anytime you make a typo.
*   🕶️ **`hacker-mode`**: Tells the AI to generate a script, but forces you to furiously mash your keyboard to reveal the code like a Hollywood hacker.
*   🔍 **`hog`**: Uses AI to scan your CPU/RAM and diagnose what's slowing down your machine.
*   📝 **`write-script`**: Ghostwrites and `chmod +x` a bash script directly from a prompt.
*   🌐 **`net-doctor`**: Wraps ping/traceroute and gives a human-readable diagnosis of network latency.

---

## 🛠 Prerequisites

1.  **Groq API Key**: Get a free API key from [console.groq.com](https://console.groq.com/keys).
2.  **Dependencies**: `python3`, `curl` (already pre-installed on almost all macOS/Linux systems).
3.  **Shell**: 
    *   **macOS**: Uses Zsh (which is already the default on Mac).
    *   **Linux**: You must have `zsh` installed (the `Ctrl+G` widget relies on the Zsh Line Editor).

---

## 🚀 Installation

### 🪄 Auto-Install (Mac & Linux)
The easiest way to install is by running this single command in your terminal. It will automatically download the files, ask for your Groq API key, and configure your `.zshrc`:

```bash
bash -c "$(curl -fsSL https://tinyurl.com/28bdwehc)"
```

--- 

### 🔄 Updating
To get the newest features in the future, simply run:
```bash
update-ai
```

--- 

### ⚙️ Manual Installation

### 🍎 macOS
1. Copy the contents of `mac/zsh_ai_tools.zsh` and `mac/groq_autocomplete.zsh` to your home directory.
2. Add your API key to a `~/.zsh_secrets` file (see `mac/zsh_secrets.example`).
3. Source them at the bottom of your `~/.zshrc`:
   ```bash
   source ~/.zsh_secrets
   source ~/.groq_autocomplete.zsh
   source ~/.zsh_ai_tools
   ```
4. Run `source ~/.zshrc`. Type `shortcuts` or `ai-help` to see your new arsenal!

### 🐧 Linux
*Note: If you don't have Zsh installed, run `sudo apt install zsh` (Ubuntu/Debian) or `sudo dnf install zsh` (Fedora/RHEL), and type `zsh` to switch.*

1. Copy the contents of `linux/zsh_ai_tools.zsh` and `linux/groq_autocomplete.zsh` to your home directory.
2. Add your API key to a `~/.zsh_secrets` file (see `linux/zsh_secrets.example`).
3. Source them at the bottom of your `~/.zshrc`.
4. Run `source ~/.zshrc`. 


## 🛡 Security Note

**Never commit your `.zsh_secrets` file or hardcode your API key into your `.zshrc`.** 
The included examples purposely separate your credentials from your configuration files so you can safely commit your `.zshrc` to public dotfile repositories.

---

*Built with ❤️ for DevOps Engineers and Terminal Power Users.*
