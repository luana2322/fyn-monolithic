# Script to start Flutter frontend with smart device detection
# Checks for Android emulator and runs on both emulator + web if available
# Otherwise only runs web

param(
    [string]$BASE_URL = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Flutter Frontend (Smart)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if Android emulator is running
function Test-AndroidEmulator {
    Write-Host "Checking for Android emulator..." -ForegroundColor Yellow
    
    # Try using adb first
    $adbPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbPath) {
        $adbDevices = adb devices 2>&1
        $emulatorLines = $adbDevices | Where-Object { $_ -match "emulator-\d+" }
        if ($emulatorLines) {
            Write-Host "Android emulator detected via adb" -ForegroundColor Green
            $deviceId = ($emulatorLines[0] -split "\s+")[0]
            Write-Host "  Device ID: $deviceId" -ForegroundColor Gray
            return $true, $deviceId
        }
    }
    
    # Try using flutter devices
    $flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterPath) {
        $flutterDevices = flutter devices 2>&1
        $emulatorFound = $flutterDevices | Where-Object { $_ -match "emulator|android" -and $_ -notmatch "No devices" }
        if ($emulatorFound) {
            Write-Host "Android emulator detected via flutter devices" -ForegroundColor Green
            # Extract device ID if possible
            $deviceMatch = $flutterDevices | Select-String -Pattern "emulator-\d+"
            if ($deviceMatch) {
                $deviceId = ($deviceMatch.Matches[0].Value)
                Write-Host "  Device ID: $deviceId" -ForegroundColor Gray
                return $true, $deviceId
            }
            return $true, $null
        }
    }
    
    Write-Host "No Android emulator detected" -ForegroundColor Yellow
    return $false, $null
}

# Check for Android emulator
$hasEmulator, $deviceId = Test-AndroidEmulator
Write-Host ""

# Always start web via Docker Compose
Write-Host "Starting Flutter web via Docker Compose..." -ForegroundColor Yellow

# Set BASE_URL environment variable
$env:BASE_URL = $BASE_URL

# Build and start Docker container
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker compose build --build-arg BASE_URL=$BASE_URL

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Docker container..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start Docker container!" -ForegroundColor Red
    exit 1
}

Write-Host "Flutter web started in Docker" -ForegroundColor Green
Write-Host "  Web URL: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""

# If emulator is available, also run on Android
if ($hasEmulator) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Starting Flutter on Android Emulator" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check Flutter
    $flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterPath) {
        Write-Host "Flutter not found! Skipping Android run." -ForegroundColor Red
        Write-Host "  Web is still running at http://localhost:3000" -ForegroundColor Yellow
        exit 0
    }
    
    # Check .env file
    if (-not (Test-Path .env)) {
        Write-Host "Creating .env file for Android..." -ForegroundColor Yellow
        # For Android emulator, use 10.0.2.2 to access host localhost
        Set-Content -Path .env -Value "BASE_URL=http://10.0.2.2:8080"
        Write-Host "Created .env file" -ForegroundColor Green
    } else {
        # Update .env for Android if needed
        $envContent = Get-Content .env -Raw
        if ($envContent -notmatch "BASE_URL=http://10.0.2.2:8080") {
            Write-Host "Updating .env for Android emulator..." -ForegroundColor Yellow
            Set-Content -Path .env -Value "BASE_URL=http://10.0.2.2:8080"
        }
    }
    
    # Install dependencies
    Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install dependencies!" -ForegroundColor Red
        Write-Host "  Web is still running at http://localhost:3000" -ForegroundColor Yellow
        exit 0
    }
    
    # Generate code
    Write-Host "Generating code..." -ForegroundColor Yellow
    flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | Out-Null
    
    # Run on Android emulator
    Write-Host ""
    Write-Host "Starting Flutter app on Android emulator..." -ForegroundColor Yellow
    if ($deviceId) {
        Write-Host "  Using device: $deviceId" -ForegroundColor Gray
        Write-Host "  Press 'q' to quit, 'r' for hot reload, 'R' for hot restart" -ForegroundColor Gray
        Write-Host ""
        flutter run -d $deviceId
    } else {
        Write-Host "  Press 'q' to quit, 'r' for hot reload, 'R' for hot restart" -ForegroundColor Gray
        Write-Host ""
        flutter run
    }
} else {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Flutter web running in Docker" -ForegroundColor Green
    Write-Host "  URL: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To start Android emulator:" -ForegroundColor Yellow
    Write-Host "  1. Open Android Studio" -ForegroundColor Gray
    Write-Host "  2. Tools -> Device Manager" -ForegroundColor Gray
    Write-Host "  3. Start an emulator" -ForegroundColor Gray
    Write-Host "  4. Run this script again" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To view logs:" -ForegroundColor Yellow
    Write-Host "  docker compose logs -f flutter-web" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To stop:" -ForegroundColor Yellow
    Write-Host "  docker compose down" -ForegroundColor Gray
}
