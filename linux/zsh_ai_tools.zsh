# ==============================
# TERMINAL AI TOOLS LIBRARY
# ==============================
# This file contains the custom AI bash functions (fix, gac, etc.)
# powered by Groq and the Python urllib library.

# ---------------------------------------------------------
# CORE AI CALLER (PYTHON WRAPPER)
# ---------------------------------------------------------
_call_groq() {
  local system_prompt="$1"
  local user_prompt="$2"
  
  python3 -c '
import sys, json, urllib.request, os
sys_prompt = sys.argv[1]
user_prompt = sys.argv[2]
api_key = os.environ.get("GROQ_API_KEY")
model = os.environ.get("OPENAI_MODEL", "qwen/qwen3.8-27b")

if not api_key:
    print("Error: GROQ_API_KEY is not set.")
    sys.exit(1)

data = json.dumps({
    "model": model,
    "messages": [
        {"role": "system", "content": sys_prompt},
        {"role": "user", "content": user_prompt}
    ],
    "temperature": 0.2,
    "max_tokens": 2048
}).encode("utf-8")

req = urllib.request.Request("https://api.groq.com/openai/v1/chat/completions", data=data)
req.add_header("Authorization", f"Bearer {api_key}")
req.add_header("Content-Type", "application/json")
req.add_header("User-Agent", "curl/7.81.0")

try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode())
        content = res["choices"][0]["message"]["content"]
        # Strip potential markdown formatting that models sometimes stubbornly include
        content = content.strip().removeprefix("```bash").removeprefix("```sql").removeprefix("```").removesuffix("```").strip()
        print(content)
except Exception as e:
    print(f"API Error: {e}")
' "$system_prompt" "$user_prompt"
}

# ---------------------------------------------------------
# 1. THE "FIX" COMMAND
# ---------------------------------------------------------
fix() {
  # Get the last command from history
  local last_cmd=$(fc -ln -1 | sed 's/^[ \t]*//')
  echo -e "\033[36m🤖 Analyzing last command:\033[0m $last_cmd"
  
  local sys="You are a terminal debugging assistant for macOS. The user provides a command that failed or needs fixing. Output the corrected command on the very first line. On the second line, provide a brief 1-sentence explanation of what was wrong."
  local response=$(_call_groq "$sys" "$last_cmd")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 2. AI GIT AUTO-COMMIT (gac)
# ---------------------------------------------------------
gac() {
  local diff=$(git diff --cached)
  if [[ -z "$diff" ]]; then
    diff=$(git diff)
    if [[ -z "$diff" ]]; then
      echo "No changes found to commit."
      return
    fi
  fi
  echo -e "\033[36m🤖 Analyzing git diff...\033[0m"
  local sys="You are a senior developer. Given a git diff, output ONLY a conventional semantic commit message (e.g., feat: add login, fix: correct typo). Provide a title line, and a brief description body if necessary. Do not include quotes, markdown backticks, or any other explanations."
  
  # Truncate diff if it's too massive
  local truncated_diff=$(echo "$diff" | head -n 500)
  
  local msg=$(_call_groq "$sys" "$truncated_diff")
  echo -e "\n\033[32mSuggested Commit Message:\033[0m\n\n$msg\n"
  
  read -q "REPLY?Commit with this message? (y/n) "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add .
    git commit -m "$msg"
  fi
}

# ---------------------------------------------------------
# 3. BASH SCRIPT GHOSTWRITER (write-script)
# ---------------------------------------------------------
write-script() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: write-script <description>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating bash script...\033[0m"
  local sys="You are an expert Linux bash scripter. Write a bash script that fulfills the request. Output ONLY the raw script content starting with #!/bin/bash. Include inline comments. No markdown formatting, no backticks, no conversational text."
  local content=$(_call_groq "$sys" "$prompt")
  
  local filename="script_$(date +%s).sh"
  echo "$content" > "$filename"
  chmod +x "$filename"
  echo -e "\033[32mCreated and made executable: $filename\033[0m"
  echo "----------------------------------------"
  cat "$filename"
}

# ---------------------------------------------------------
# 4. TERMINAL TRANSLATOR (babel)
# ---------------------------------------------------------
babel() {
  local input
  if [ -t 0 ]; then
    input="$*"
  else
    # Read from pipe
    input=$(cat)
  fi
  
  if [[ -z "$input" ]]; then
    echo "Usage: cat file.log | babel   OR   babel 'text to translate'"
    return 1
  fi
  
  echo -e "\033[36m🤖 Translating...\033[0m"
  local sys="You are a polyglot translator. Detect the language of the input and translate it into English. Preserve all code formatting, logs, and technical terms intact. If it is already in English, output it as-is."
  _call_groq "$sys" "$input"
}

# ---------------------------------------------------------
# 5. SQL GENERATOR (sql-gen)
# ---------------------------------------------------------
sql-gen() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: sql-gen <description of query>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating SQL...\033[0m"
  local sys="You are a DBA. Generate a standard SQL query based on the request. Output ONLY the raw SQL query. No markdown, no explanations."
  _call_groq "$sys" "$prompt"
}

# ---------------------------------------------------------
# 6. DATA TRANSFORMER (morph)
# ---------------------------------------------------------
morph() {
  local prompt="$1"
  if [[ -z "$prompt" ]]; then
    echo "Usage: cat data.json | morph 'convert to yaml'"
    return 1
  fi
  local input=$(cat)
  echo -e "\033[36m🤖 Morphing data...\033[0m"
  local sys="You are a strict data transformation CLI tool. You receive data and an instruction. Transform the data exactly as requested. Output ONLY the resulting raw data. Do not use markdown code blocks or add conversational text."
  _call_groq "$sys" "Instruction: $prompt\n\nData:\n$input"
}

# ---------------------------------------------------------
# 7. MAC RESOURCE ASSISTANT (hog)
# ---------------------------------------------------------
hog() {
  echo -e "\033[36m🤖 Scanning system resources (CPU/Memory)...\033[0m"
  local top_output=$(top -l 1 -n 15 -s 0 | head -n 25)
  local sys="You are a Linux performance tuning expert. The user is providing the output of 'top'. Identify what is hogging the CPU or Memory. Explain the issue in 2-3 plain English sentences and suggest the exact 'kill' command the user can run to stop the offending process."
  local response=$(_call_groq "$sys" "$top_output")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 8. INFRASTRUCTURE AS CHAT (iac)
# ---------------------------------------------------------
iac() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: iac <description of cloud infrastructure>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating Terraform Infrastructure...\033[0m"
  local sys="You are a Senior Cloud Engineer. Generate ONLY the raw Terraform code (main.tf) to fulfill the user's request. Use AWS by default unless specified otherwise. Do not include markdown formatting or explanations."
  local content=$(_call_groq "$sys" "$prompt")
  echo "$content" > "main.tf"
  echo -e "\033[32mCreated main.tf in the current directory!\033[0m"
  echo "----------------------------------------"
  cat main.tf
}

# ---------------------------------------------------------
# 9. NETWORK TROUBLESHOOTER (net-doctor)
# ---------------------------------------------------------
net-doctor() {
  local target="$1"
  if [[ -z "$target" ]]; then
    echo "Usage: net-doctor <domain_or_ip>"
    return 1
  fi
  echo -e "\033[36m🤖 Running ping test to $target...\033[0m"
  local ping_res=$(ping -c 4 "$target" 2>&1)
  echo -e "\033[36m🤖 Analyzing network data...\033[0m"
  local sys="You are a Senior Network Engineer. Analyze the provided ping output. Explain in plain English whether the connection is healthy, or why the user might be having connectivity issues (packet loss, latency). Suggest next debugging steps."
  local response=$(_call_groq "$sys" "Target: $target\nPing Output:\n$ping_res")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 10. SEMANTIC FILE SEARCH (find-ai)
# ---------------------------------------------------------
find-ai() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: find-ai <what to look for>"
    return 1
  fi
  echo -e "\033[36m🤖 Building semantic search query...\033[0m"
  local sys="You are a macOS terminal expert. Output ONLY a safe bash command combining 'find' and/or 'grep -r' to search for this concept conceptually in the current directory. Do not use markdown, rm, or dangerous commands."
  local cmd=$(_call_groq "$sys" "$prompt")
  echo -e "\033[32mExecuting:\033[0m $cmd\n"
  eval "$cmd"
}

# ---------------------------------------------------------
# 12. LOG ANOMALY DETECTOR (audit-logs)
# ---------------------------------------------------------
audit-logs() {
  local input
  if [ -t 0 ]; then
    input=$(tail -n 250 "$1" 2>/dev/null)
  else
    input=$(cat | tail -n 250)
  fi
  if [[ -z "$input" ]]; then
    echo "Usage: cat server.log | audit-logs   OR   audit-logs server.log"
    return 1
  fi
  echo -e "\033[36m🤖 Auditing logs for anomalies (last 250 lines)...\033[0m"
  local sys="You are a DevOps auditing expert. Filter out all the normal operational noise from these logs. Output a clean, bulleted list of ONLY the anomalies, stack traces, errors, or suspicious behavior. If everything looks fine, just say 'Logs look healthy!'"
  local response=$(_call_groq "$sys" "$input")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 13. PORT SNIPER (snipe)
# ---------------------------------------------------------
snipe() {
  local port="$1"
  if [[ -z "$port" ]]; then
    echo "Usage: snipe <port_number>"
    return 1
  fi
  local output=$(lsof -i :$port)
  if [[ -z "$output" ]]; then
    echo "Nothing is running on port $port."
    return 0
  fi
  echo -e "\033[36m🤖 Sniping port $port...\033[0m"
  local sys="You are a system administrator. Explain exactly what process is running on this port based on the lsof output, what it likely is (e.g. Jenkins, Node.js), and give a 1 sentence summary."
  local response=$(_call_groq "$sys" "$output")
  echo -e "\n$response\n"
  
  local pid=$(echo "$output" | awk 'NR==2 {print $2}')
  if [[ -n "$pid" ]]; then
    read -q "REPLY?Kill process $pid? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      kill -9 $pid
      echo "Process $pid killed."
    fi
  fi
}

# ---------------------------------------------------------
# 14. CHEATSHEET (ai-help)
# ---------------------------------------------------------
ai-help() {
  echo -e "\n\033[35;1m🤖 ANTIGRAVITY AI TERMINAL TOOLS (CHEATSHEET)\033[0m"
  echo -e "================================================================"
  echo -e "\033[36mCtrl+G\033[0m       - Autocomplete any command based on what you typed."
  echo -e "\033[36mfix\033[0m          - Fixes the last failed command in your history."
  echo -e "\033[36mgac\033[0m          - Git Auto-Commit. Reads diff and suggests a message."
  echo -e "\033[36mhog\033[0m          - Scans CPU/RAM and finds what's slowing down your Mac."
  echo -e "\033[36msnipe\033[0m        - e.g. \033[33msnipe 3000\033[0m (Finds and kills process on port)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mwrite-script\033[0m - e.g. \033[33mwrite-script 'backup files'\033[0m"
  echo -e "\033[36miac\033[0m          - e.g. \033[33miac 's3 bucket'\033[0m (Generates Terraform main.tf)"
  echo -e "\033[36msql-gen\033[0m      - e.g. \033[33msql-gen 'find active users'\033[0m (Outputs raw SQL)"
  echo -e "\033[36mfind-ai\033[0m      - e.g. \033[33mfind-ai 'database passwords'\033[0m (Semantic file search)"
  echo -e "\033[36mexplain\033[0m      - e.g. \033[33mexplain tar\033[0m (AI Man Pages via SmartMan TUI)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mnet-doctor\033[0m   - e.g. \033[33mnet-doctor 8.8.8.8\033[0m (Diagnoses network issues)"
  echo -e "\033[36maudit-logs\033[0m   - e.g. \033[33maudit-logs error.log\033[0m (Finds anomalies in logs)"
  echo -e "\033[36mbabel\033[0m        - e.g. \033[33mcat log.txt | babel\033[0m (Translates output to English)"
  echo -e "\033[36mmorph\033[0m        - e.g. \033[33mcat data.json | morph 'to yaml'\033[0m (Transforms data)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mplay-music\033[0m   - e.g. \033[33mplay-music 'lo-fi chill'\033[0m (Plays via Spotify (Requires Linux integration))"
  echo -e "================================================================\n"
}

# ---------------------------------------------------------
# 14. AUTO-UPDATER (update-ai)

# ---------------------------------------------------------
# 17. MAGIC DIRECTORY JUMPER (tp)
# ---------------------------------------------------------
tp() {
  local query="$*"
  if [[ -z "$query" ]]; then
    echo "Usage: tp <where do you want to go>"
    return 1
  fi
  echo -e "\033[36m🔮 Teleporting...\033[0m"
  
  local sys="You are a smart terminal assistant. The user wants to cd into a directory matching: '$query'. Output ONLY a safe bash command using 'find ~ -type d -iname \"*something*\" 2>/dev/null | head -n 1' to find this directory. Use wildcards. Do not use markdown."
  local cmd=$(_call_groq "$sys" "$query")
  local target=$(eval "$cmd" 2>/dev/null)
  
  if [[ -n "$target" && -d "$target" ]]; then
    echo -e "\033[32m✨ Jumped to: $target\033[0m"
    cd "$target"
  else
    echo -e "\033[31mCould not find a matching directory.\033[0m"
  fi
}

# ---------------------------------------------------------
# 18. SEMANTIC FOLDER CLEANER (tidy)
# ---------------------------------------------------------
tidy() {
  local target_dir="${1:-.}"
  if [[ ! -d "$target_dir" ]]; then
    echo "Directory not found!"
    return 1
  fi
  
  echo -e "\033[36m🧹 Analyzing files in $target_dir...\033[0m"
  local files=$(ls -1 "$target_dir" | head -n 50)
  
  if [[ -z "$files" ]]; then
    echo "Directory is empty."
    return 0
  fi
  
  local sys="You are a smart file organizer. Analyze this list of files. Group them logically by purpose (e.g., 'Images', 'Invoices', 'Code'). Output ONLY a raw bash script (no markdown, no backticks) that creates these directories inside '$target_dir' and uses 'mv' to move the specific files into them. Do not explain."
  local script=$(_call_groq "$sys" "$files")
  
  echo -e "\033[33mProposed Cleanup Plan:\033[0m"
  echo "$script" | sed 's/^/  /'
  echo
  read -q "REPLY?Execute this cleanup? (y/n): " < /dev/tty
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$script"
    echo -e "\033[32mDirectory tidied!\033[0m"
  else
    echo "Aborted."
  fi
}

# ---------------------------------------------------------
# 19. HOLLYWOOD HACKER MODE (hacker-mode)
# ---------------------------------------------------------
hacker-mode() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: hacker-mode <what to hack>"
    return 1
  fi
  echo -e "\033[32m[ACCESSING MAINFRAME] Generating payload...\033[0m"
  
  local sys="You are a master hacker. Generate a complex, authentic-looking script (Python or C++) that accomplishes: $prompt. Output ONLY the raw code, no markdown, no explanations. Make it look incredibly advanced."
  local code=$(_call_groq "$sys" "$prompt")
  
  clear
  echo -e "\033[32m[CONNECTION ESTABLISHED] Mash keyboard to inject code.\033[0m\n"
  
  local i=0
  local code_len=${#code}
  
  while [[ $i -lt $code_len ]]; do
    read -r -s -k 1 < /dev/tty
    local chunk="${code:$i:6}"
    echo -n -e "\033[32m$chunk\033[0m"
    i=$((i + 6))
  done
  echo -e "\n\n\033[31m[ACCESS GRANTED] Payload injected.\033[0m"
}

# ---------------------------------------------------------
# 20. TOXIC SHELL (toxic-shell)
# ---------------------------------------------------------
toxic-shell() {
  if [[ "$TOXIC_SHELL_ENABLED" == "true" ]]; then
    export TOXIC_SHELL_ENABLED="false"
    echo -e "\033[32mToxic shell disabled. It's safe now.\033[0m"
  else
    export TOXIC_SHELL_ENABLED="true"
    echo -e "\033[31mToxic shell enabled. Don't make any mistakes.\033[0m"
  fi
}

_toxic_precmd() {
  local exit_code=$?
  if [[ "$TOXIC_SHELL_ENABLED" == "true" && $exit_code -ne 0 && $exit_code -ne 130 ]]; then
    local last_cmd=$(fc -ln -1 | xargs)
    local sys="You are a ruthless, arrogant, Gordon Ramsay-style senior developer. The user just ran a terminal command that failed. The command was: '$last_cmd'. Output a 1-2 sentence brutal insult about their intelligence. Be sarcastic, toxic, and mean. No markdown."
    local roast=$(_call_groq "$sys" "Roast me for this failed command: $last_cmd")
    echo -e "\n\033[31m☠️  $roast\033[0m\n"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _toxic_precmd

# ---------------------------------------------------------
update-ai() {
  echo -e "\033[36m🤖 Pulling latest AI tools from GitHub...\033[0m"
  local OS_TYPE="linux"
  if [[ "$OSTYPE" == "darwin"* ]]; then
      OS_TYPE="mac"
  fi
  local BASE_URL="https://raw.githubusercontent.com/novitaswebworks/zsh-ai-toolkit/master/$OS_TYPE"
  
  curl -sL "$BASE_URL/zsh_ai_tools.zsh" -o ~/.zsh_ai_tools
  curl -sL "$BASE_URL/groq_autocomplete.zsh" -o ~/.groq_autocomplete.zsh
  
  echo -e "\033[32m✅ Update complete! Reloading shell...\033[0m"
  exec zsh
}# 11. TERMINAL DJ (play-music)
# ---------------------------------------------------------
play-music() {
  local mood="$*"
  if [[ -z "$mood" ]]; then
    echo "Usage: play-music <mood or genre>"
    return 1
  fi
  
  if ! command -v mpv &> /dev/null; then
    echo -e "[31mError: mpv is not installed.[0m"
    echo "To use the music player, please install it:"
    echo "  Mac: brew install mpv yt-dlp"
    echo "  Linux: sudo apt install mpv yt-dlp"
    return 1
  fi

  echo -e "[36m🎵 Tuning in to YouTube for: $mood...[0m"
  echo -e "[33m(Press SPACE to pause, 9/0 for volume, Q to quit)[0m"
  
  # Run mpv natively in the foreground as an interactive TUI
  mpv --no-video "ytdl://ytsearch:$mood"
}# ==============================
# TERMINAL AI TOOLS LIBRARY
# ==============================
# This file contains the custom AI bash functions (fix, gac, etc.)
# powered by Groq and the Python urllib library.

# ---------------------------------------------------------
# CORE AI CALLER (PYTHON WRAPPER)
# ---------------------------------------------------------
_call_groq() {
  local system_prompt="$1"
  local user_prompt="$2"
  
  python3 -c '
import sys, json, urllib.request, os
sys_prompt = sys.argv[1]
user_prompt = sys.argv[2]
api_key = os.environ.get("GROQ_API_KEY")
model = os.environ.get("OPENAI_MODEL", "qwen/qwen3.8-27b")

if not api_key:
    print("Error: GROQ_API_KEY is not set.")
    sys.exit(1)

data = json.dumps({
    "model": model,
    "messages": [
        {"role": "system", "content": sys_prompt},
        {"role": "user", "content": user_prompt}
    ],
    "temperature": 0.2,
    "max_tokens": 2048
}).encode("utf-8")

req = urllib.request.Request("https://api.groq.com/openai/v1/chat/completions", data=data)
req.add_header("Authorization", f"Bearer {api_key}")
req.add_header("Content-Type", "application/json")
req.add_header("User-Agent", "curl/7.81.0")

try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode())
        content = res["choices"][0]["message"]["content"]
        # Strip potential markdown formatting that models sometimes stubbornly include
        content = content.strip().removeprefix("```bash").removeprefix("```sql").removeprefix("```").removesuffix("```").strip()
        print(content)
except Exception as e:
    print(f"API Error: {e}")
' "$system_prompt" "$user_prompt"
}

# ---------------------------------------------------------
# 1. THE "FIX" COMMAND
# ---------------------------------------------------------
fix() {
  # Get the last command from history
  local last_cmd=$(fc -ln -1 | sed 's/^[ \t]*//')
  echo -e "\033[36m🤖 Analyzing last command:\033[0m $last_cmd"
  
  local sys="You are a terminal debugging assistant for macOS. The user provides a command that failed or needs fixing. Output the corrected command on the very first line. On the second line, provide a brief 1-sentence explanation of what was wrong."
  local response=$(_call_groq "$sys" "$last_cmd")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 2. AI GIT AUTO-COMMIT (gac)
# ---------------------------------------------------------
gac() {
  local diff=$(git diff --cached)
  if [[ -z "$diff" ]]; then
    diff=$(git diff)
    if [[ -z "$diff" ]]; then
      echo "No changes found to commit."
      return
    fi
  fi
  echo -e "\033[36m🤖 Analyzing git diff...\033[0m"
  local sys="You are a senior developer. Given a git diff, output ONLY a conventional semantic commit message (e.g., feat: add login, fix: correct typo). Provide a title line, and a brief description body if necessary. Do not include quotes, markdown backticks, or any other explanations."
  
  # Truncate diff if it's too massive
  local truncated_diff=$(echo "$diff" | head -n 500)
  
  local msg=$(_call_groq "$sys" "$truncated_diff")
  echo -e "\n\033[32mSuggested Commit Message:\033[0m\n\n$msg\n"
  
  read -q "REPLY?Commit with this message? (y/n) "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add .
    git commit -m "$msg"
  fi
}

# ---------------------------------------------------------
# 3. BASH SCRIPT GHOSTWRITER (write-script)
# ---------------------------------------------------------
write-script() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: write-script <description>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating bash script...\033[0m"
  local sys="You are an expert Linux bash scripter. Write a bash script that fulfills the request. Output ONLY the raw script content starting with #!/bin/bash. Include inline comments. No markdown formatting, no backticks, no conversational text."
  local content=$(_call_groq "$sys" "$prompt")
  
  local filename="script_$(date +%s).sh"
  echo "$content" > "$filename"
  chmod +x "$filename"
  echo -e "\033[32mCreated and made executable: $filename\033[0m"
  echo "----------------------------------------"
  cat "$filename"
}

# ---------------------------------------------------------
# 4. TERMINAL TRANSLATOR (babel)
# ---------------------------------------------------------
babel() {
  local input
  if [ -t 0 ]; then
    input="$*"
  else
    # Read from pipe
    input=$(cat)
  fi
  
  if [[ -z "$input" ]]; then
    echo "Usage: cat file.log | babel   OR   babel 'text to translate'"
    return 1
  fi
  
  echo -e "\033[36m🤖 Translating...\033[0m"
  local sys="You are a polyglot translator. Detect the language of the input and translate it into English. Preserve all code formatting, logs, and technical terms intact. If it is already in English, output it as-is."
  _call_groq "$sys" "$input"
}

# ---------------------------------------------------------
# 5. SQL GENERATOR (sql-gen)
# ---------------------------------------------------------
sql-gen() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: sql-gen <description of query>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating SQL...\033[0m"
  local sys="You are a DBA. Generate a standard SQL query based on the request. Output ONLY the raw SQL query. No markdown, no explanations."
  _call_groq "$sys" "$prompt"
}

# ---------------------------------------------------------
# 6. DATA TRANSFORMER (morph)
# ---------------------------------------------------------
morph() {
  local prompt="$1"
  if [[ -z "$prompt" ]]; then
    echo "Usage: cat data.json | morph 'convert to yaml'"
    return 1
  fi
  local input=$(cat)
  echo -e "\033[36m🤖 Morphing data...\033[0m"
  local sys="You are a strict data transformation CLI tool. You receive data and an instruction. Transform the data exactly as requested. Output ONLY the resulting raw data. Do not use markdown code blocks or add conversational text."
  _call_groq "$sys" "Instruction: $prompt\n\nData:\n$input"
}

# ---------------------------------------------------------
# 7. MAC RESOURCE ASSISTANT (hog)
# ---------------------------------------------------------
hog() {
  echo -e "\033[36m🤖 Scanning system resources (CPU/Memory)...\033[0m"
  local top_output=$(top -l 1 -n 15 -s 0 | head -n 25)
  local sys="You are a Linux performance tuning expert. The user is providing the output of 'top'. Identify what is hogging the CPU or Memory. Explain the issue in 2-3 plain English sentences and suggest the exact 'kill' command the user can run to stop the offending process."
  local response=$(_call_groq "$sys" "$top_output")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 8. INFRASTRUCTURE AS CHAT (iac)
# ---------------------------------------------------------
iac() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: iac <description of cloud infrastructure>"
    return 1
  fi
  echo -e "\033[36m🤖 Generating Terraform Infrastructure...\033[0m"
  local sys="You are a Senior Cloud Engineer. Generate ONLY the raw Terraform code (main.tf) to fulfill the user's request. Use AWS by default unless specified otherwise. Do not include markdown formatting or explanations."
  local content=$(_call_groq "$sys" "$prompt")
  echo "$content" > "main.tf"
  echo -e "\033[32mCreated main.tf in the current directory!\033[0m"
  echo "----------------------------------------"
  cat main.tf
}

# ---------------------------------------------------------
# 9. NETWORK TROUBLESHOOTER (net-doctor)
# ---------------------------------------------------------
net-doctor() {
  local target="$1"
  if [[ -z "$target" ]]; then
    echo "Usage: net-doctor <domain_or_ip>"
    return 1
  fi
  echo -e "\033[36m🤖 Running ping test to $target...\033[0m"
  local ping_res=$(ping -c 4 "$target" 2>&1)
  echo -e "\033[36m🤖 Analyzing network data...\033[0m"
  local sys="You are a Senior Network Engineer. Analyze the provided ping output. Explain in plain English whether the connection is healthy, or why the user might be having connectivity issues (packet loss, latency). Suggest next debugging steps."
  local response=$(_call_groq "$sys" "Target: $target\nPing Output:\n$ping_res")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 10. SEMANTIC FILE SEARCH (find-ai)
# ---------------------------------------------------------
find-ai() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: find-ai <what to look for>"
    return 1
  fi
  echo -e "\033[36m🤖 Building semantic search query...\033[0m"
  local sys="You are a macOS terminal expert. Output ONLY a safe bash command combining 'find' and/or 'grep -r' to search for this concept conceptually in the current directory. Do not use markdown, rm, or dangerous commands."
  local cmd=$(_call_groq "$sys" "$prompt")
  echo -e "\033[32mExecuting:\033[0m $cmd\n"
  eval "$cmd"
}

# ---------------------------------------------------------
# 12. LOG ANOMALY DETECTOR (audit-logs)
# ---------------------------------------------------------
audit-logs() {
  local input
  if [ -t 0 ]; then
    input=$(tail -n 250 "$1" 2>/dev/null)
  else
    input=$(cat | tail -n 250)
  fi
  if [[ -z "$input" ]]; then
    echo "Usage: cat server.log | audit-logs   OR   audit-logs server.log"
    return 1
  fi
  echo -e "\033[36m🤖 Auditing logs for anomalies (last 250 lines)...\033[0m"
  local sys="You are a DevOps auditing expert. Filter out all the normal operational noise from these logs. Output a clean, bulleted list of ONLY the anomalies, stack traces, errors, or suspicious behavior. If everything looks fine, just say 'Logs look healthy!'"
  local response=$(_call_groq "$sys" "$input")
  echo -e "\n$response\n"
}

# ---------------------------------------------------------
# 13. PORT SNIPER (snipe)
# ---------------------------------------------------------
snipe() {
  local port="$1"
  if [[ -z "$port" ]]; then
    echo "Usage: snipe <port_number>"
    return 1
  fi
  local output=$(lsof -i :$port)
  if [[ -z "$output" ]]; then
    echo "Nothing is running on port $port."
    return 0
  fi
  echo -e "\033[36m🤖 Sniping port $port...\033[0m"
  local sys="You are a system administrator. Explain exactly what process is running on this port based on the lsof output, what it likely is (e.g. Jenkins, Node.js), and give a 1 sentence summary."
  local response=$(_call_groq "$sys" "$output")
  echo -e "\n$response\n"
  
  local pid=$(echo "$output" | awk 'NR==2 {print $2}')
  if [[ -n "$pid" ]]; then
    read -q "REPLY?Kill process $pid? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      kill -9 $pid
      echo "Process $pid killed."
    fi
  fi
}

# ---------------------------------------------------------
# 14. CHEATSHEET (ai-help)
# ---------------------------------------------------------
ai-help() {
  echo -e "\n\033[35;1m🤖 ANTIGRAVITY AI TERMINAL TOOLS (CHEATSHEET)\033[0m"
  echo -e "================================================================"
  echo -e "\033[36mCtrl+G\033[0m       - Autocomplete any command based on what you typed."
  echo -e "\033[36mfix\033[0m          - Fixes the last failed command in your history."
  echo -e "\033[36mgac\033[0m          - Git Auto-Commit. Reads diff and suggests a message."
  echo -e "\033[36mhog\033[0m          - Scans CPU/RAM and finds what's slowing down your Mac."
  echo -e "\033[36msnipe\033[0m        - e.g. \033[33msnipe 3000\033[0m (Finds and kills process on port)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mwrite-script\033[0m - e.g. \033[33mwrite-script 'backup files'\033[0m"
  echo -e "\033[36miac\033[0m          - e.g. \033[33miac 's3 bucket'\033[0m (Generates Terraform main.tf)"
  echo -e "\033[36msql-gen\033[0m      - e.g. \033[33msql-gen 'find active users'\033[0m (Outputs raw SQL)"
  echo -e "\033[36mfind-ai\033[0m      - e.g. \033[33mfind-ai 'database passwords'\033[0m (Semantic file search)"
  echo -e "\033[36mexplain\033[0m      - e.g. \033[33mexplain tar\033[0m (AI Man Pages via SmartMan TUI)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mnet-doctor\033[0m   - e.g. \033[33mnet-doctor 8.8.8.8\033[0m (Diagnoses network issues)"
  echo -e "\033[36maudit-logs\033[0m   - e.g. \033[33maudit-logs error.log\033[0m (Finds anomalies in logs)"
  echo -e "\033[36mbabel\033[0m        - e.g. \033[33mcat log.txt | babel\033[0m (Translates output to English)"
  echo -e "\033[36mmorph\033[0m        - e.g. \033[33mcat data.json | morph 'to yaml'\033[0m (Transforms data)"
  echo -e "----------------------------------------------------------------"
  echo -e "\033[36mplay-music\033[0m   - e.g. \033[33mplay-music 'lo-fi chill'\033[0m (Plays via Spotify (Requires Linux integration))"
  echo -e "================================================================\n"
}

# ---------------------------------------------------------
# 14. AUTO-UPDATER (update-ai)
# ---------------------------------------------------------
update-ai() {
  echo -e "\033[36m🤖 Pulling latest AI tools from GitHub...\033[0m"
  local OS_TYPE="linux"
  if [[ "$OSTYPE" == "darwin"* ]]; then
      OS_TYPE="mac"
  fi
  local BASE_URL="https://raw.githubusercontent.com/novitaswebworks/zsh-ai-toolkit/master/$OS_TYPE"
  
  curl -sL "$BASE_URL/zsh_ai_tools.zsh" -o ~/.zsh_ai_tools
  curl -sL "$BASE_URL/groq_autocomplete.zsh" -o ~/.groq_autocomplete.zsh
  
  echo -e "\033[32m✅ Update complete! Reloading shell...\033[0m"
  exec zsh
}

# ---------------------------------------------------------
# 15. AI MAN PAGES (explain)
# ---------------------------------------------------------
explain() {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "Usage: explain <command>"
    echo "Example: explain tar"
    return 1
  fi
  
  if command -v smartman &> /dev/null; then
    smartman "$cmd"
  else
    echo -e "[31mError: smartman is not installed.[0m"
    echo -e "The [36mexplain[0m command is powered by the brilliant [33msmartman-cli[0m TUI tool."
    read -q "REPLY?Would you like to automatically install it right now? (y/n): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo -e "[36m
Installing smartman-cli...[0m"
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/novitaswebworks/smartman-cli/main/install.sh)"
      echo -e "
[32mInstallation complete! Launching smartman...[0m"
      # Ensure PATH is updated if installer added it
      export PATH="$HOME/.local/bin:$PATH"
      smartman "$cmd"
    else
      echo -e "
Installation aborted."
    fi
  fi
}
