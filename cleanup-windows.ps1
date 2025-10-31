# Claude Context MCP - Windows Cleanup Script
# This script removes all Docker containers, volumes, and optionally models

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Claude Context MCP - Cleanup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  WARNING: This will remove all data!" -ForegroundColor Yellow
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  - Stop all running containers" -ForegroundColor White
Write-Host "  - Remove containers" -ForegroundColor White
Write-Host "  - Remove Docker volumes (all indexed data)" -ForegroundColor White
Write-Host "  - Optionally remove downloaded models" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Green
    exit 0
}

# Detect compose command
$dockerComposeInstalled = Get-Command docker-compose -ErrorAction SilentlyContinue
if (-not $dockerComposeInstalled) {
    docker compose version 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker Compose not found!" -ForegroundColor Red
        exit 1
    }
    $composeCommand = "docker compose"
} else {
    $composeCommand = "docker-compose"
}

Write-Host ""
Write-Host "[1/3] Stopping containers..." -ForegroundColor Yellow
Invoke-Expression "$composeCommand down"

Write-Host ""
Write-Host "[2/3] Removing volumes..." -ForegroundColor Yellow
Invoke-Expression "$composeCommand down -v"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Containers and volumes removed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some resources may not have been removed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/3] Cleanup complete!" -ForegroundColor Green
Write-Host ""

Write-Host "To start fresh, run:" -ForegroundColor Cyan
Write-Host "  .\setup-windows.ps1" -ForegroundColor White
Write-Host ""
