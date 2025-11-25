# Script to start Flutter frontend locally
cd $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Flutter Frontend (Local)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "Checking Flutter..." -ForegroundColor Yellow
$flutterVersion = flutter --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Flutter not found!" -ForegroundColor Red
    Write-Host "Please install Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Flutter installed" -ForegroundColor Green
Write-Host ""

# Check .env file
Write-Host "Checking .env file..." -ForegroundColor Yellow
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    Set-Content -Path .env -Value "BASE_URL=http://localhost:8080"
    Write-Host "✓ Created .env file" -ForegroundColor Green
} else {
    Write-Host "✓ .env file exists" -ForegroundColor Green
}
Write-Host ""

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to install dependencies!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Generate code
Write-Host "Generating code..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs
Write-Host ""

# Check for Chrome
Write-Host "Checking available devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Start app
Write-Host "Starting Flutter app on Chrome..." -ForegroundColor Yellow
Write-Host "Frontend will be available at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Press 'q' to quit, 'r' for hot reload, 'R' for hot restart" -ForegroundColor Gray
Write-Host ""

flutter run -d chrome --web-port=3000

