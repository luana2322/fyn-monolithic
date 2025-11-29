# Script to check backend connection and troubleshoot ERR_CONNECTION_TIMED_OUT

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Backend Connection Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "1. Checking if backend is running..." -ForegroundColor Yellow
$backendRunning = $false

# Check Docker container
Write-Host "   Checking Docker container..." -ForegroundColor Gray
$containerStatus = docker ps --filter "name=fyn-backend" --format "{{.Status}}" 2>&1
if ($containerStatus -match "Up") {
    Write-Host "   ✓ Backend container is running" -ForegroundColor Green
    $backendRunning = $true
} else {
    Write-Host "   ✗ Backend container is not running" -ForegroundColor Red
    Write-Host "   Try: cd ..\fyn-monolithic && docker compose up -d fyn-backend" -ForegroundColor Yellow
}

Write-Host ""

# Check if port 8080 is accessible
Write-Host "2. Checking if port 8080 is accessible..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Port 8080 is accessible" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Cannot connect to http://localhost:8080" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    
    if (-not $backendRunning) {
        Write-Host ""
        Write-Host "   Solution: Start the backend first" -ForegroundColor Yellow
        Write-Host "   cd ..\fyn-monolithic" -ForegroundColor Cyan
        Write-Host "   docker compose up -d fyn-backend" -ForegroundColor Cyan
    }
}

Write-Host ""

# Check BASE_URL in .env
Write-Host "3. Checking BASE_URL configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    if ($envContent -match "BASE_URL=(.+)") {
        $baseUrl = $matches[1].Trim()
        Write-Host "   Current BASE_URL: $baseUrl" -ForegroundColor Gray
        
        if ($baseUrl -eq "http://10.0.2.2:8080") {
            Write-Host "   ⚠ BASE_URL is set for Android emulator" -ForegroundColor Yellow
            Write-Host "   For web, it should be: http://localhost:8080" -ForegroundColor Yellow
        } elseif ($baseUrl -eq "http://localhost:8080") {
            Write-Host "   ✓ BASE_URL is correct for web" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ BASE_URL might not be correct for web" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✗ BASE_URL not found in .env" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ .env file not found" -ForegroundColor Red
    Write-Host "   Creating .env with default BASE_URL..." -ForegroundColor Yellow
    Set-Content -Path .env -Value "BASE_URL=http://localhost:8080"
    Write-Host "   ✓ Created .env file" -ForegroundColor Green
}

Write-Host ""

# Check Docker network
Write-Host "4. Checking Docker network..." -ForegroundColor Yellow
$networkExists = docker network ls --filter "name=fyn-monolithic_fyn-network" --format "{{.Name}}" 2>&1
if ($networkExists -match "fyn-monolithic_fyn-network") {
    Write-Host "   ✓ Network exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Network 'fyn-monolithic_fyn-network' not found" -ForegroundColor Red
    Write-Host "   Try: cd ..\fyn-monolithic && docker compose up -d" -ForegroundColor Yellow
}

Write-Host ""

# Summary and recommendations
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary & Recommendations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $backendRunning) {
    Write-Host "⚠ Backend is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To start backend:" -ForegroundColor Yellow
    Write-Host "  1. cd ..\fyn-monolithic" -ForegroundColor Cyan
    Write-Host "  2. docker compose up -d fyn-backend" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "To fix BASE_URL for web:" -ForegroundColor Yellow
Write-Host "  1. Edit .env file" -ForegroundColor Cyan
Write-Host "  2. Set BASE_URL=http://localhost:8080" -ForegroundColor Cyan
Write-Host "  3. Rebuild Docker image: docker compose build" -ForegroundColor Cyan
Write-Host "  4. Restart container: docker compose up -d" -ForegroundColor Cyan
Write-Host ""

Write-Host "To check backend logs:" -ForegroundColor Yellow
Write-Host "  docker logs fyn-backend" -ForegroundColor Cyan
Write-Host ""

Write-Host "To test backend API:" -ForegroundColor Yellow
Write-Host "  curl http://localhost:8080/api/auth/login" -ForegroundColor Cyan
Write-Host "  or open in browser: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""

