# Script to start Spring Boot backend locally
cd $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Spring Boot Backend (Local)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Java
Write-Host "Checking Java..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Java not found!" -ForegroundColor Red
    Write-Host "Please install Java 21" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Java installed" -ForegroundColor Green
Write-Host $javaVersion[0] -ForegroundColor Gray
Write-Host ""

# Check Maven (use Maven wrapper if available, otherwise system Maven)
Write-Host "Checking Maven..." -ForegroundColor Yellow
$mvnCmd = "mvn"
if (Test-Path "mvnw.cmd") {
    $mvnCmd = ".\mvnw.cmd"
    Write-Host "✓ Using Maven wrapper" -ForegroundColor Green
} else {
    $mvnVersion = mvn -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Maven not found!" -ForegroundColor Red
        Write-Host "Please install Maven 3.8+ or use Maven wrapper" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✓ Maven installed" -ForegroundColor Green
}
Write-Host ""

# Check Docker services
Write-Host "Checking Docker services..." -ForegroundColor Yellow
$postgresRunning = docker ps --filter "name=fyn-postgres" --format "{{.Names}}" 2>$null
$minioRunning = docker ps --filter "name=fyn-minio" --format "{{.Names}}" 2>$null

if (-not $postgresRunning) {
    Write-Host "⚠ PostgreSQL not running. Starting..." -ForegroundColor Yellow
    docker-compose up -d fyn-postgres
    Start-Sleep -Seconds 5
}

if (-not $minioRunning) {
    Write-Host "⚠ MinIO not running. Starting..." -ForegroundColor Yellow
    docker-compose up -d fyn-minio
    Start-Sleep -Seconds 5
}

Write-Host "✓ Docker services ready" -ForegroundColor Green
Write-Host ""

# Build project
Write-Host "Building project..." -ForegroundColor Yellow
& $mvnCmd clean install -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build successful" -ForegroundColor Green
Write-Host ""

# Start backend
Write-Host "Starting Spring Boot backend..." -ForegroundColor Yellow
Write-Host "Backend will be available at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

& $mvnCmd spring-boot:run -Dspring-boot.run.profiles=dev

