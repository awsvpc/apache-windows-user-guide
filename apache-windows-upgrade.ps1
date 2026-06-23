```powershell
# =====================================================================
# Apache Upgrade Script (Windows)
# =====================================================================

$ServiceName = "Apache24"

$ApacheRoot = "D:\Program Files\Apache24"
$ApacheOld  = "D:\Program Files\Apache24_OLD"

Write-Host ""
Write-Host "====================================================="
Write-Host "Apache Upgrade Utility"
Write-Host "====================================================="
Write-Host ""

# ---------------------------------------------------------------------
# Function
# ---------------------------------------------------------------------

function Confirm-Action {
    param([string]$Message)

    $response = Read-Host "$Message (Y/N)"

    if ($response -notin @("Y","y")) {
        Write-Host "Operation cancelled."
        exit
    }
}

# ---------------------------------------------------------------------
# Service Status Before
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Current Service Status"
Write-Host "----------------------"

$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($null -eq $svc) {
    Write-Host "Service [$ServiceName] not found."
    exit
}

$svc | Format-Table Name,Status

Confirm-Action "Continue with upgrade"

# ---------------------------------------------------------------------
# Stop Service
# ---------------------------------------------------------------------

if ($svc.Status -eq "Running") {

    Confirm-Action "Stop Apache service [$ServiceName]"

    Stop-Service $ServiceName

    Start-Sleep -Seconds 5

    Get-Service $ServiceName | Format-Table Name,Status
}

# ---------------------------------------------------------------------
# Rename Existing Installation
# ---------------------------------------------------------------------

if (Test-Path $ApacheOld) {

    Write-Host ""
    Write-Host "$ApacheOld already exists."
    Write-Host "Please remove or rename it first."

    exit
}

Confirm-Action "Rename current Apache installation to Apache24_OLD"

Rename-Item `
    -Path $ApacheRoot `
    -NewName "Apache24_OLD"

Write-Host "Renamed successfully."

# ---------------------------------------------------------------------
# Archive Backup
# ---------------------------------------------------------------------

$ZipDate = Get-Date -Format "MMddyyyy"

$ZipFile = "D:\Program Files\Apache24_OLD_$ZipDate.zip"

$archiveAnswer = Read-Host "Do you want to archive Apache24_OLD to ZIP? (Y/N)"

if ($archiveAnswer -in @("Y","y")) {

    if (Test-Path $ZipFile) {
        Remove-Item $ZipFile -Force
    }

    Write-Host ""
    Write-Host "Creating archive..."
    Write-Host $ZipFile

    Compress-Archive `
        -Path $ApacheOld `
        -DestinationPath $ZipFile

    Write-Host "Archive completed."
}

# ---------------------------------------------------------------------
# Manual Extraction Pause
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "====================================================="
Write-Host "MANUAL STEP REQUIRED"
Write-Host "====================================================="
Write-Host ""
Write-Host "Extract the NEW Apache ZIP into:"
Write-Host ""
Write-Host $ApacheRoot
Write-Host ""
Write-Host "Expected:"
Write-Host "$ApacheRoot\bin"
Write-Host "$ApacheRoot\conf"
Write-Host "$ApacheRoot\modules"

Confirm-Action "Have you completed extraction"

# ---------------------------------------------------------------------
# Copy Configuration
# ---------------------------------------------------------------------

Confirm-Action "Copy CONF folder from old installation"

robocopy `
"$ApacheOld\conf" `
"$ApacheRoot\conf" `
/E

# ---------------------------------------------------------------------
# Copy CGI
# ---------------------------------------------------------------------

if (Test-Path "$ApacheOld\cgi-bin") {

    Confirm-Action "Copy CGI-BIN"

    robocopy `
    "$ApacheOld\cgi-bin" `
    "$ApacheRoot\cgi-bin" `
    /E /XO
}

# ---------------------------------------------------------------------
# Copy HTDOCS
# ---------------------------------------------------------------------

if (Test-Path "$ApacheOld\htdocs") {

    Confirm-Action "Copy HTDOCS"

    robocopy `
    "$ApacheOld\htdocs" `
    "$ApacheRoot\htdocs" `
    /E /XO
}

# ---------------------------------------------------------------------
# Copy Missing Files From LIB
# ---------------------------------------------------------------------

if (Test-Path "$ApacheOld\lib") {

    Confirm-Action "Copy missing files from LIB"

    robocopy `
    "$ApacheOld\lib" `
    "$ApacheRoot\lib" `
    *.* `
    /E /XC /XN /XO
}

# ---------------------------------------------------------------------
# Copy Missing Files From MODULES
# ---------------------------------------------------------------------

if (Test-Path "$ApacheOld\modules") {

    Confirm-Action "Copy missing files from MODULES"

    robocopy `
    "$ApacheOld\modules" `
    "$ApacheRoot\modules" `
    *.* `
    /E /XC /XN /XO
}

# ---------------------------------------------------------------------
# Copy Missing Files From LOGS
# ---------------------------------------------------------------------

if (Test-Path "$ApacheOld\logs") {

    Confirm-Action "Copy NON-LOG files from LOGS"

    robocopy `
    "$ApacheOld\logs" `
    "$ApacheRoot\logs" `
    *.* `
    /E `
    /XC /XN /XO `
    /XF *.log
}

# ---------------------------------------------------------------------
# Validate Apache Configuration
# ---------------------------------------------------------------------

Confirm-Action "Validate Apache configuration"

& "$ApacheRoot\bin\httpd.exe" -t

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "Configuration validation failed."
    Write-Host "Review configuration before starting service."

    exit
}

# ---------------------------------------------------------------------
# Display Version
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Apache Version"
Write-Host "--------------"

& "$ApacheRoot\bin\httpd.exe" -v

# ---------------------------------------------------------------------
# Display VHosts
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Virtual Hosts"
Write-Host "-------------"

& "$ApacheRoot\bin\httpd.exe" -S

# ---------------------------------------------------------------------
# Start Service
# ---------------------------------------------------------------------

Confirm-Action "Start Apache service"

Start-Service $ServiceName

Start-Sleep -Seconds 5

# ---------------------------------------------------------------------
# Final Status
# ---------------------------------------------------------------------

Write-Host ""
Write-Host "Final Service Status"
Write-Host "--------------------"

Get-Service $ServiceName | Format-Table Name,Status

# ---------------------------------------------------------------------
# Error Log
# ---------------------------------------------------------------------

$ErrorLog = "$ApacheRoot\logs\error.log"

if (Test-Path $ErrorLog) {

    Write-Host ""
    Write-Host "Last 50 lines of error.log"
    Write-Host "-------------------------"

    Get-Content $ErrorLog -Tail 50
}

Write-Host ""
Write-Host "====================================================="
Write-Host "Upgrade Complete"
Write-Host "====================================================="
```
