# Toggle MongoDB Windows service
$serviceName = "MongoDB"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "MongoDB service '$serviceName' not found."
    exit
}

if ($service.Status -eq "Running") {
    Write-Host "Stopping MongoDB..."
    Start-Process powershell -Verb RunAs -ArgumentList "Stop-Service -Name $serviceName -Force"
    Write-Host "MongoDB stopped (via elevated call)."
} else {
    Write-Host "Starting MongoDB..."
    Start-Process powershell -Verb RunAs -ArgumentList "Start-Service -Name $serviceName"
    Write-Host "MongoDB started (via elevated call)."
}