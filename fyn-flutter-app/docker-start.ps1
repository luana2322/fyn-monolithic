# Script to start Flutter web app in Docker
# Ensure we're in the correct directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Green
Write-Host "Checking for required files..." -ForegroundColor Yellow

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
    Write-Host "Please ensure you're in the Flutter project directory." -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding Docker image..." -ForegroundColor Yellow
docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nStarting container..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Container started successfully!" -ForegroundColor Green
        Write-Host "App is running at: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "`nTo view logs: docker-compose logs -f" -ForegroundColor Yellow
        Write-Host "To stop: docker-compose down" -ForegroundColor Yellow
    } else {
        Write-Host "`n✗ Failed to start container!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
    exit 1
}

