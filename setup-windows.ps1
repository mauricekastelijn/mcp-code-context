# Claude Context MCP - Windows Setup Script
# This script sets up MILVUS and Ollama locally using Docker

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Claude Context MCP - Local Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerInstalled) {
    Write-Host "❌ Docker is not installed!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

$dockerComposeInstalled = Get-Command docker-compose -ErrorAction SilentlyContinue
if (-not $dockerComposeInstalled) {
    # Try docker compose (v2 syntax)
    docker compose version 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker Compose is not installed!" -ForegroundColor Red
        Write-Host "Please install Docker Compose" -ForegroundColor Red
        exit 1
    }
    $composeCommand = "docker compose"
} else {
    $composeCommand = "docker-compose"
}

# Check if Node.js is installed
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeInstalled) {
    Write-Host "⚠️  Node.js is not installed!" -ForegroundColor Yellow
    Write-Host "Please install Node.js (version 20.x or 22.x) from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "You can continue with Docker setup, but you'll need Node.js for the MCP server." -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
} else {
    $nodeVersion = node --version
    Write-Host "✅ Node.js $nodeVersion detected" -ForegroundColor Green
}

Write-Host "✅ Docker detected" -ForegroundColor Green
Write-Host ""

# Check if containers are already running
Write-Host "[2/6] Checking existing containers..." -ForegroundColor Yellow
$existingContainers = docker ps -a --filter "name=milvus" --filter "name=ollama" --format "{{.Names}}"
if ($existingContainers) {
    Write-Host "⚠️  Found existing containers:" -ForegroundColor Yellow
    $existingContainers | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    $cleanup = Read-Host "Remove existing containers? (y/n)"
    if ($cleanup -eq "y") {
        Write-Host "Stopping and removing existing containers..." -ForegroundColor Yellow
        Invoke-Expression "$composeCommand down -v"
    }
}

# Start Docker containers
Write-Host ""
Write-Host "[3/6] Starting Docker containers..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first run..." -ForegroundColor Gray
Write-Host ""
Write-Host "⏳ Building custom Ollama container (if needed)..." -ForegroundColor Gray
Write-Host "   This includes corporate CA certificates if present in ollama/res/" -ForegroundColor Gray
Write-Host ""

Invoke-Expression "$composeCommand up -d --build"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start Docker containers!" -ForegroundColor Red
    Write-Host ""
    Write-Host "If you're behind a corporate proxy and see certificate errors:" -ForegroundColor Yellow
    Write-Host "  1. Place your CA certificate in: ollama/res/Cisco_Umbrella_Root_CA.cer" -ForegroundColor Yellow
    Write-Host "  2. See ollama/README.md for instructions" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker containers started" -ForegroundColor Green
Write-Host ""

# Wait for services to be healthy
Write-Host "[4/6] Waiting for services to be ready..." -ForegroundColor Yellow
Write-Host "⏳ This may take 30-60 seconds..." -ForegroundColor Gray

$maxWait = 120
$waited = 0
$interval = 5

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $waited += $interval
    
    # Check MILVUS
    $milvusHealthy = docker inspect --format='{{.State.Health.Status}}' milvus-standalone 2>$null
    
    # Check Ollama
    $ollamaHealthy = docker inspect --format='{{.State.Health.Status}}' ollama 2>$null
    
    Write-Host "⏳ [$waited/$maxWait seconds] MILVUS: $milvusHealthy | Ollama: $ollamaHealthy" -ForegroundColor Gray
    
    if ($milvusHealthy -eq "healthy" -and $ollamaHealthy -eq "healthy") {
        Write-Host "✅ All services are healthy!" -ForegroundColor Green
        break
    }
}

if ($waited -ge $maxWait) {
    Write-Host "⚠️  Services took longer than expected to start" -ForegroundColor Yellow
    Write-Host "Check logs with: $composeCommand logs -f" -ForegroundColor Yellow
}

Write-Host ""

# Download Ollama model
Write-Host "[5/6] Downloading nomic-embed-text model..." -ForegroundColor Yellow
Write-Host "⏳ This will download ~274MB..." -ForegroundColor Gray

docker exec ollama ollama pull nomic-embed-text
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to download model!" -ForegroundColor Red
    Write-Host "You can try manually later with: docker exec ollama ollama pull nomic-embed-text" -ForegroundColor Yellow
} else {
    Write-Host "✅ Model downloaded successfully" -ForegroundColor Green
}

Write-Host ""

# Verify setup
Write-Host "[6/6] Verifying setup..." -ForegroundColor Yellow

# Test MILVUS
try {
    $milvusResponse = Invoke-WebRequest -Uri "http://127.0.0.1:9091/healthz" -TimeoutSec 5 -UseBasicParsing 2>$null
    if ($milvusResponse.StatusCode -eq 200) {
        Write-Host "✅ MILVUS is accessible at 127.0.0.1:19530" -ForegroundColor Green
    } else {
        Write-Host "⚠️  MILVUS responded with status: $($milvusResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  MILVUS health check failed (this might be okay if it just started)" -ForegroundColor Yellow
}

# Test Ollama
try {
    $ollamaResponse = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 5
    $modelFound = $ollamaResponse.models | Where-Object { $_.name -like "nomic-embed-text*" }
    if ($modelFound) {
        Write-Host "✅ Ollama is accessible at http://127.0.0.1:11434 with nomic-embed-text model" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Ollama is running but nomic-embed-text model not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Ollama health check failed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Configure VS Code - See VSCODE_SETUP.md" -ForegroundColor White
Write-Host "2. Start using the MCP - See USAGE.md" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  View logs:       $composeCommand logs -f" -ForegroundColor White
Write-Host "  Stop services:   $composeCommand down" -ForegroundColor White
Write-Host "  Restart:         $composeCommand restart" -ForegroundColor White
Write-Host ""
Write-Host "Services running at:" -ForegroundColor Cyan
Write-Host "  MILVUS:  127.0.0.1:19530" -ForegroundColor White
Write-Host "  Ollama:  http://127.0.0.1:11434" -ForegroundColor White
Write-Host "  MinIO:   http://127.0.0.1:9001 (minioadmin/minioadmin)" -ForegroundColor White
Write-Host ""
