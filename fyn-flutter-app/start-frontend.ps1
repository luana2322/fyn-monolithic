# Script to build and start Flutter frontend
cd E:\DACN\fyn-flutter-app

Write-Host "Building Flutter frontend Docker image..." -ForegroundColor Yellow
docker compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nStarting container..." -ForegroundColor Yellow
    docker compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Frontend container started!" -ForegroundColor Green
        Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "`nChecking container status..." -ForegroundColor Yellow
        docker ps | findstr flutter
    }
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
}

