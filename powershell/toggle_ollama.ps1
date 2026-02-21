<#
.SYNOPSIS
    Toggle the Docker container named "ollama" between start and stop.

.DESCRIPTION
    • Checks that Docker is available and that the container exists.
    • If the container is stopped/exited → starts it.
    • If the container is running → stops it.
    • Emits color‑coded output for clarity.

.NOTES
    • Requires Docker Desktop (or Docker Engine) to be running.
    • Works from a normal PowerShell prompt; no admin required.
#>

# ─────────────────────────────────────────────────────────────────────
# Helper: Pretty output
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS')]$Level='INFO'
    )
    $color = switch ($Level) {
        'INFO'    { 'White'  }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red'    }
        'SUCCESS' { 'Green'  }
    }
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$ts] [$Level] $Message" -ForegroundColor $color
}

# ─────────────────────────────────────────────────────────────────────
# Helper: Verify Docker
function Test-Docker {
    Write-Log "Checking Docker availability..." 'INFO'
    try {
        docker version | Out-Null
        Write-Log "Docker is running." 'SUCCESS'
        return $true
    } catch {
        Write-Log "Docker is NOT running. Please start Docker Desktop." 'ERROR'
        return $false
    }
}

# ─────────────────────────────────────────────────────────────────────
# Core logic
$Container = "ollama"

# 1. Is Docker reachable?
if (-not (Test-Docker)) { exit 1 }

# 2. Does the container exist?
$status = docker inspect --format '{{.State.Status}}' $Container 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "Container '$Container' does not exist." 'ERROR'
    exit 1
}

# 3. Toggle based on current state
switch ($status) {
    'running' {
        Write-Log "Container '$Container' is running – stopping it now..." 'INFO'
        docker stop $Container | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Container stopped successfully." 'SUCCESS'
        } else {
            Write-Log "Failed to stop container." 'ERROR'
        }
    }
    'exited' {
        Write-Log "Container '$Container' is stopped – starting it now..." 'INFO'
        docker start $Container | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Container started successfully." 'SUCCESS'
        } else {
            Write-Log "Failed to start container." 'ERROR'
        }
    }
    default {
        Write-Log "Container '$Container' is in state '$status' – no action taken." 'WARN'
    }
}