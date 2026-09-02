# ==============================
# GROQ AI AUTOCOMPLETE WIDGET
# ==============================
# This uses your Groq API key to provide real-time command suggestions.
# Press Ctrl+G to trigger it on whatever you have typed so far.

function _groq_suggest_command() {
  # Capture what the user has typed so far
  local prompt_text="$BUFFER"
  if [[ -z "$prompt_text" ]]; then
    return
  fi
  
  # Display a temporary loading message below the prompt
  zle -M "Groq is thinking..."

  # Make the API call to Groq and parse the JSON using Python
  local suggestion=$(curl -s "https://api.groq.com/openai/v1/chat/completions" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(python3 -c '
import json, sys
prompt = sys.argv[1]
print(json.dumps({
    "model": "qwen/qwen3.8-27b",
    "messages": [
        {"role": "system", "content": "You are a command-line autocomplete assistant for a macOS zsh terminal. The user will provide a partial command, or an English description of what they want to do. Output ONLY the raw executable bash/zsh command that fulfills their request. DO NOT include markdown formatting, backticks, quotes, or any explanations. Just the command itself."},
        {"role": "user", "content": prompt}
    ],
    "temperature": 0.1,
    "max_tokens": 150
}))
' "$prompt_text")" | python3 -c '
import json, sys
try:
    resp = json.load(sys.stdin)
    content = resp["choices"][0]["message"]["content"]
    # Strip markdown backticks in case the model adds them anyway
    print(content.strip("` \n"))
except Exception as e:
    pass
')

  # If we got a valid response, replace the terminal buffer with it
  if [[ -n "$suggestion" ]]; then
    BUFFER="$suggestion"
    CURSOR=${#BUFFER}
  fi
  
  # Clear the loading message and redraw the prompt
  zle -M ""
  zle reset-prompt
}

# Register the function as a Zsh Line Editor (ZLE) widget
zle -N _groq_suggest_command

# Bind the widget to Ctrl+G
bindkey '^g' _groq_suggest_command
