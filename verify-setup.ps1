# Verification Script for Claude Context MCP Setup
# This script checks if everything is configured correctly

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Setup Verification" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Check 1: Docker
Write-Host "[1/8] Checking Docker..." -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker is installed" -ForegroundColor Green
    $dockerVersion = docker --version
    Write-Host "   $dockerVersion" -ForegroundColor Gray
} else {
    Write-Host "❌ Docker is not installed" -ForegroundColor Red
    $allPassed = $false
}

# Check 2: Docker Compose
Write-Host ""
Write-Host "[2/8] Checking Docker Compose..." -ForegroundColor Yellow
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker Compose is installed" -ForegroundColor Green
    $composeVersion = docker-compose --version
    Write-Host "   $composeVersion" -ForegroundColor Gray
} elseif ((docker compose version 2>&1 | Out-String) -match "version") {
    Write-Host "✅ Docker Compose (v2) is installed" -ForegroundColor Green
} else {
    Write-Host "❌ Docker Compose is not installed" -ForegroundColor Red
    $allPassed = $false
}

# Check 3: Node.js
Write-Host ""
Write-Host "[3/8] Checking Node.js..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    $versionNumber = $nodeVersion -replace 'v', ''
    $majorVersion = [int]($versionNumber.Split('.')[0])
    
    if ($majorVersion -ge 20 -and $majorVersion -lt 24) {
        Write-Host "✅ Node.js $nodeVersion is installed (compatible)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Node.js $nodeVersion is installed but may not be compatible" -ForegroundColor Yellow
        Write-Host "   Required: >= 20.0.0 and < 24.0.0" -ForegroundColor Gray
        $allPassed = $false
    }
} else {
    Write-Host "❌ Node.js is not installed" -ForegroundColor Red
    $allPassed = $false
}

# Check 4: Containers Running
Write-Host ""
Write-Host "[4/8] Checking Docker containers..." -ForegroundColor Yellow
$containers = docker ps --filter "name=milvus" --filter "name=ollama" --format "{{.Names}}" 2>$null

if ($containers) {
    Write-Host "✅ Containers are running:" -ForegroundColor Green
    $containers | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
} else {
    Write-Host "⚠️  No containers are running" -ForegroundColor Yellow
    Write-Host "   Run: .\setup-windows.ps1" -ForegroundColor Gray
}

# Check 5: MILVUS Health
Write-Host ""
Write-Host "[5/8] Checking MILVUS..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:9091/healthz" -TimeoutSec 5 -UseBasicParsing 2>$null
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ MILVUS is healthy and accessible" -ForegroundColor Green
        Write-Host "   Address: 127.0.0.1:19530" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  MILVUS responded with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ MILVUS is not accessible" -ForegroundColor Red
    Write-Host "   Ensure containers are running" -ForegroundColor Gray
}

# Check 6: Ollama Health
Write-Host ""
Write-Host "[6/8] Checking Ollama..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 5 2>$null
    Write-Host "✅ Ollama is healthy and accessible" -ForegroundColor Green
    Write-Host "   Address: http://127.0.0.1:11434" -ForegroundColor Gray
    
    # Check 7: Ollama Model
    Write-Host ""
    Write-Host "[7/8] Checking Ollama model..." -ForegroundColor Yellow
    $modelFound = $response.models | Where-Object { $_.name -like "nomic-embed-text*" }
    if ($modelFound) {
        Write-Host "✅ nomic-embed-text model is available" -ForegroundColor Green
        $modelInfo = $modelFound[0]
        Write-Host "   Model: $($modelInfo.name)" -ForegroundColor Gray
        Write-Host "   Size: $([math]::Round($modelInfo.size / 1MB, 2)) MB" -ForegroundColor Gray
    } else {
        Write-Host "❌ nomic-embed-text model not found" -ForegroundColor Red
        Write-Host "   Run: docker exec ollama ollama pull nomic-embed-text" -ForegroundColor Gray
        $allPassed = $false
    }
} catch {
    Write-Host "❌ Ollama is not accessible" -ForegroundColor Red
    Write-Host "   Ensure containers are running" -ForegroundColor Gray
    Write-Host ""
    Write-Host "[7/8] Checking Ollama model..." -ForegroundColor Yellow
    Write-Host "⊘  Skipped (Ollama not accessible)" -ForegroundColor Gray
}

# Check 8: VS Code Configuration
Write-Host ""
Write-Host "[8/8] Checking VS Code configuration..." -ForegroundColor Yellow
$vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"

if (Test-Path $vscodeSettingsPath) {
    Write-Host "✅ VS Code settings.json exists" -ForegroundColor Green
    Write-Host "   Path: $vscodeSettingsPath" -ForegroundColor Gray
    
    $settingsContent = Get-Content $vscodeSettingsPath -Raw
    if ($settingsContent -match "claude-context") {
        Write-Host "✅ MCP server configuration found" -ForegroundColor Green
    } else {
        Write-Host "⚠️  MCP server not configured in settings.json" -ForegroundColor Yellow
        Write-Host "   See: VSCODE_SETUP.md" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  VS Code settings.json not found" -ForegroundColor Yellow
    Write-Host "   Path: $vscodeSettingsPath" -ForegroundColor Gray
    Write-Host "   This is normal if you haven't configured VS Code yet" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✅ All Critical Checks Passed!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some Issues Found" -ForegroundColor Yellow
}
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not $allPassed) {
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Fix any issues marked with ❌" -ForegroundColor White
    Write-Host "2. Run this script again to verify" -ForegroundColor White
    Write-Host "3. See TROUBLESHOOTING.md for help" -ForegroundColor White
} else {
    Write-Host "Your setup looks good! Next steps:" -ForegroundColor Cyan
    Write-Host "1. Configure VS Code (if not done) - See VSCODE_SETUP.md" -ForegroundColor White
    Write-Host "2. Index your first codebase - See USAGE.md" -ForegroundColor White
    Write-Host "3. Start using semantic code search!" -ForegroundColor White
}

Write-Host ""
