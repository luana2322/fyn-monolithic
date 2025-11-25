# Script to run Docker container
param(
    [int]$Port = 3000
)

Write-Host "Starting Flutter web app container..." -ForegroundColor Yellow

# Stop and remove existing container if exists
docker stop fyn-flutter-web 2>$null
docker rm fyn-flutter-web 2>$null

# Run container
docker run -d `
    -p "${Port}:80" `
    --name fyn-flutter-web `
    --restart unless-stopped `
    fyn-flutter-web:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Container started successfully!" -ForegroundColor Green
    Write-Host "App is running at: http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "To view logs: docker logs -f fyn-flutter-web" -ForegroundColor Yellow
    Write-Host "To stop: docker stop fyn-flutter-web" -ForegroundColor Yellow
} else {
    Write-Host "✗ Failed to start container!" -ForegroundColor Red
    exit 1
}

