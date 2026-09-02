# Windows PowerShell AI Tools (Groq Powered)
# Add this to your $PROFILE: . C:\path\to\ai_tools.ps1

function Invoke-Groq {
    param([string]$SystemPrompt, [string]$UserPrompt)
    $apiKey = $env:GROQ_API_KEY
    if (-not $apiKey) { Write-Host "Please set $env:GROQ_API_KEY"; return }
    
    $headers = @{ "Authorization" = "Bearer $apiKey"; "Content-Type" = "application/json" }
    $body = @{
        model = "qwen/qwen3.8-27b"
        messages = @(
            @{ role = "system"; content = $SystemPrompt },
            @{ role = "user"; content = $UserPrompt }
        )
        temperature = 0.2
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content.Trim("`n ").Trim("``")
    } catch {
        Write-Host "API Error: $_"
    }
}

function Fix-Command {
    $lastCmd = (Get-History -Count 1).CommandLine
    Write-Host "🤖 Analyzing: $lastCmd" -ForegroundColor Cyan
    $sys = "You are a Windows PowerShell debugging assistant. Output the corrected command on line 1, and a 1-sentence explanation on line 2."
    $res = Invoke-Groq -SystemPrompt $sys -UserPrompt $lastCmd
    Write-Host "`n$res`n" -ForegroundColor Green
}

function Write-AiScript {
    param([Parameter(Mandatory=$true)][string]$Prompt)
    Write-Host "🤖 Generating PowerShell Script..." -ForegroundColor Cyan
    $sys = "You are an expert PowerShell scripter. Output ONLY the raw PowerShell script. No markdown formatting."
    $res = Invoke-Groq -SystemPrompt $sys -UserPrompt $Prompt
    $filename = "script_$(Get-Date -UFormat %s).ps1"
    $res | Out-File $filename
    Write-Host "Saved to $filename" -ForegroundColor Green
}
