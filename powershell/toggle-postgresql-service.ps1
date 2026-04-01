# Toggle PostgreSQL Windows service
$serviceName = "postgresql-x64-18"   # <-- Change if your version differs
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "PostgreSQL service '$serviceName' not found."
    exit
}

if ($service.Status -eq "Running") {
    Write-Host "Stopping PostgreSQL..."
    Start-Process powershell -Verb RunAs -ArgumentList "Stop-Service -Name $serviceName -Force"
    Write-Host "PostgreSQL stopped."
} else {
    Write-Host "Starting PostgreSQL..."
    Start-Process powershell -Verb RunAs -ArgumentList "Start-Service -Name $serviceName"
    Write-Host "PostgreSQL started."
}
