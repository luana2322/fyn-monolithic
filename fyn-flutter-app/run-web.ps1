# Script to run Flutter app on web
# Ensure we're in the correct directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Green
Write-Host "Checking for pubspec.yaml..." -ForegroundColor Yellow

if (Test-Path "pubspec.yaml") {
    Write-Host "✓ pubspec.yaml found!" -ForegroundColor Green
    Write-Host "Running Flutter app on Chrome..." -ForegroundColor Yellow
    flutter run -d chrome
} else {
    Write-Host "✗ ERROR: pubspec.yaml not found!" -ForegroundColor Red
    Write-Host "Please ensure you're in the Flutter project directory." -ForegroundColor Red
    exit 1
}

