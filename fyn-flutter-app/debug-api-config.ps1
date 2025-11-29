# Script to debug API configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  API Configuration Debug" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check .env file
Write-Host "1. Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    Write-Host "   ✓ .env file exists" -ForegroundColor Green
    
    if ($envContent -match "BASE_URL=(.+)") {
        $baseUrl = $matches[1].Trim()
        Write-Host "   BASE_URL: $baseUrl" -ForegroundColor Cyan
    } else {
        Write-Host "   ✗ BASE_URL not found in .env" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ .env file not found" -ForegroundColor Red
    Write-Host "   Creating default .env..." -ForegroundColor Yellow
    Set-Content -Path .env -Value "BASE_URL=http://localhost:8080"
    Write-Host "   ✓ Created .env with BASE_URL=http://localhost:8080" -ForegroundColor Green
}

Write-Host ""

# Check if backend is accessible
Write-Host "2. Testing backend connection..." -ForegroundColor Yellow
$baseUrl = "http://localhost:8080"
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    if ($envContent -match "BASE_URL=(.+)") {
        $baseUrl = $matches[1].Trim()
    }
}

Write-Host "   Testing: $baseUrl" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Backend is accessible" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Cannot connect to backend" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Make sure backend is running:" -ForegroundColor Yellow
    Write-Host "   cd ..\fyn-monolithic" -ForegroundColor Cyan
    Write-Host "   docker compose up -d fyn-backend" -ForegroundColor Cyan
}

Write-Host ""

# Check pubspec.yaml
Write-Host "3. Checking pubspec.yaml..." -ForegroundColor Yellow
if (Test-Path "pubspec.yaml") {
    $pubspecContent = Get-Content pubspec.yaml -Raw
    if ($pubspecContent -match "\.env") {
        Write-Host "   ✓ .env is included in assets" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ .env might not be in assets" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ pubspec.yaml not found" -ForegroundColor Red
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To rebuild with correct BASE_URL:" -ForegroundColor Yellow
Write-Host "  1. Ensure .env has correct BASE_URL" -ForegroundColor Cyan
Write-Host "  2. Rebuild: docker compose build --build-arg BASE_URL=http://localhost:8080" -ForegroundColor Cyan
Write-Host "  3. Restart: docker compose up -d" -ForegroundColor Cyan
Write-Host ""

