# Script to build and run Flutter web app in Docker
# This script ensures we're in the correct directory

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Flutter Web Docker Build & Run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Check for required files
Write-Host "Checking required files..." -ForegroundColor Yellow
$requiredFiles = @("docker-compose.yml", "Dockerfile", "nginx.conf", "pubspec.yaml")
$allExist = $true

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file NOT FOUND!" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host "`nERROR: Missing required files!" -ForegroundColor Red
    Write-Host "Please ensure you're in the Flutter project directory: E:\DACN\fyn-flutter-app" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding Docker image..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes on first build..." -ForegroundColor Gray
Write-Host ""

docker compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    Write-Host "`nStarting container..." -ForegroundColor Yellow
    
    docker compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  ✓ Container started successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "Backend:  http://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Useful commands:" -ForegroundColor Yellow
        Write-Host "  View logs:    docker compose logs -f" -ForegroundColor Gray
        Write-Host "  Stop:         docker compose down" -ForegroundColor Gray
        Write-Host "  Restart:      docker compose restart" -ForegroundColor Gray
    } else {
        Write-Host "`n✗ Failed to start container!" -ForegroundColor Red
        Write-Host "Check logs with: docker compose logs" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    exit 1
}
