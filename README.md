# ⚡️ Blazing Fast AI Terminal Toolkit

Turn your terminal into a contextual, lightning-fast AI assistant. 
This toolkit injects **Groq's high-speed inference** directly into your Zsh (Mac/Linux) or PowerShell (Windows) environment, without the bloated dependencies of other CLI tools.

---

## 🌟 Features

*   ⌨️ **`Ctrl+G` (Autocomplete)**: Press `Ctrl+G` to turn plain English into an executable bash command instantly.
*   🚑 **`fix`**: Grabs your last failed command and tells you exactly how to fix it.
*   ⚙️ **`gac`**: Git Auto-Commit. Reads your `git diff` and generates a semantic commit message.
*   🔍 **`hog`**: Uses AI to scan your CPU/RAM and diagnose what's slowing down your machine.
*   📝 **`write-script`**: Ghostwrites and `chmod +x` a bash or powershell script directly from a prompt.
*   🌐 **`net-doctor`**: Wraps ping/traceroute and gives a human-readable diagnosis of network latency.
*   🎧 **`play-music` (Mac only)**: Uses AppleScript to open Apple Music and play a playlist based on your mood.

---

## 🛠 Prerequisites

1.  **Groq API Key**: Get a free API key from [console.groq.com](https://console.groq.com/keys).
2.  **Dependencies**: `python3`, `curl` (already pre-installed on almost all macOS/Linux systems).
3.  **Shell**: 
    *   **macOS**: Uses Zsh (which is already the default on Mac).
    *   **Linux**: You must have `zsh` installed (the `Ctrl+G` widget relies on the Zsh Line Editor).
    *   **Windows**: Uses standard PowerShell.

---

## 🚀 Installation

### 🪄 Auto-Install (Mac & Linux)
The easiest way to install is by running this single command in your terminal. It will automatically download the files, ask for your Groq API key, and configure your `.zshrc`:

```bash
curl -sL https://raw.githubusercontent.com/novitaswebworks/zsh-ai-toolkit/master/install.sh | bash
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

### 🪟 Windows (PowerShell)
1. Copy `windows/ai_tools.ps1` to a safe location (e.g., `C:\Scripts\ai_tools.ps1`).
2. Open your PowerShell profile (`notepad $PROFILE`).
3. Add your API key as an environment variable and dot-source the script:
   ```powershell
   $env:GROQ_API_KEY = "your_api_key_here"
   . C:\Scripts\ai_tools.ps1
   ```
4. Restart PowerShell. You can now use `Fix-Command` and `Write-AiScript`!

---

## 🛡 Security Note

**Never commit your `.zsh_secrets` file or hardcode your API key into your `.zshrc`.** 
The included examples purposely separate your credentials from your configuration files so you can safely commit your `.zshrc` to public dotfile repositories.

---

*Built with ❤️ for DevOps Engineers and Terminal Power Users.*
