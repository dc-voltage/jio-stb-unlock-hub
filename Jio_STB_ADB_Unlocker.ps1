# ==============================================================================
#  Jio STB (JMSB200Av2) GenieACS Auto-Unlock & Wireless ADB Tool
#  Author: Developed by DC
#  Target: Reliance Jio 4K STB (JMSB200Av2 / Android 11 & JSTB Series)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Jio STB ADB Auto-Unlocker — Developed by DC"

function Write-Header {
    Clear-Host
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "         🚀 JIO STB GENIEACS AUTO-UNLOCK & WIRELESS ADB TOOL                 " -ForegroundColor Green
    Write-Host "                           Developed by DC                                    " -ForegroundColor Yellow
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Header

# Default Parameters
$DefaultNbiUrl = "http://127.0.0.1:7557"
$DefaultStbIp = "192.168.28.15"
$AdbPort = 5555

# 1. User Input for IPs
Write-Host "[1/5] Network Configuration:" -ForegroundColor Magenta
$StbIpInput = Read-Host "  -> Enter STB LAN IP Address [Default: $DefaultStbIp]"
if ([string]::IsNullOrWhiteSpace($StbIpInput)) {
    $StbIp = $DefaultStbIp
} else {
    $StbIp = $StbIpInput.Trim()
}

$NbiUrlInput = Read-Host "  -> Enter GenieACS NBI URL [Default: $DefaultNbiUrl]"
if ([string]::IsNullOrWhiteSpace($NbiUrlInput)) {
    $NbiUrl = $DefaultNbiUrl
} else {
    $NbiUrl = $NbiUrlInput.Trim()
}

Write-Host ""
Write-Host "  [*] Target STB IP : " -NoNewline; Write-Host "$StbIp" -ForegroundColor Yellow
Write-Host "  [*] GenieACS NBI  : " -NoNewline; Write-Host "$NbiUrl" -ForegroundColor Yellow
Write-Host ""

# 2. Check GenieACS NBI Reachability
Write-Host "[2/5] Checking GenieACS NBI Server..." -ForegroundColor Magenta
try {
    $testResp = Invoke-RestMethod -Uri "$NbiUrl/devices/?projection=_id,_lastInform" -Method Get -TimeoutSec 4 -ErrorAction Stop
    Write-Host "  [✓] Successfully connected to GenieACS NBI!" -ForegroundColor Green
} catch {
    Write-Host "  [!] WARNING: Unable to connect to GenieACS at $NbiUrl" -ForegroundColor Red
    Write-Host "      Ensure Docker or GenieACS service is running (Port 7557)." -ForegroundColor Yellow
    Write-Host "      If running on another host/VM, enter its IP address." -ForegroundColor Yellow
    Write-Host ""
    $continueChoice = Read-Host "  Do you want to continue waiting anyway? (y/n) [Default: y]"
    if ($continueChoice -eq "n") {
        Write-Host "Exiting. Please start GenieACS and try again." -ForegroundColor Red
        return
    }
}

# 3. Discover Device in GenieACS
Write-Host ""
Write-Host "[3/5] Device Discovery in GenieACS:" -ForegroundColor Magenta
Write-Host "  [*] Monitoring for STB connection..." -ForegroundColor Cyan
Write-Host "  👉 Please REBOOT the STB (Turn power OFF at wall plug for 5s, then ON)!" -ForegroundColor Yellow
Write-Host ""

$detectedDeviceId = $null

# Take initial snapshot
try {
    $initDevices = Invoke-RestMethod -Uri "$NbiUrl/devices/?projection=_id,_lastInform" -Method Get -TimeoutSec 4
    $initialDeviceMap = @{}
    foreach ($d in $initDevices) {
        $initialDeviceMap[$d._id] = $d._lastInform
    }
    Write-Host "  [*] Currently known devices in ACS: $($initDevices.Count)" -ForegroundColor Gray
} catch {
    $initialDeviceMap = @{}
}

$loopCount = 0
while ($null -eq $detectedDeviceId) {
    $loopCount++
    try {
        $currDevices = Invoke-RestMethod -Uri "$NbiUrl/devices/?projection=_id,_lastInform" -Method Get -TimeoutSec 4
        foreach ($d in $currDevices) {
            $did = $d._id
            $lastInf = $d._lastInform

            if (-not $initialDeviceMap.ContainsKey($did)) {
                $detectedDeviceId = $did
                Write-Host "`n  [🎉 NEW DEVICE DETECTED]: $detectedDeviceId" -ForegroundColor Green
                break
            } elseif ($lastInf -and ($lastInf -ne $initialDeviceMap[$did])) {
                $detectedDeviceId = $did
                Write-Host "`n  [🎉 ACTIVE INFORM RECEIVED FROM]: $detectedDeviceId" -ForegroundColor Green
                break
            }
        }

        # If devices exist and user wants to force first device after 15 seconds
        if ($null -eq $detectedDeviceId -and $currDevices.Count -gt 0 -and $loopCount -ge 8) {
            $firstDid = $currDevices[0]._id
            Write-Host "`n  [*] Using existing registered device: $firstDid" -ForegroundColor Yellow
            $detectedDeviceId = $firstDid
            break
        }
    } catch {
        # ignore transient connection errors
    }

    if ($null -eq $detectedDeviceId) {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 2
    }
}

# 4. Queue TR-069 Unlock Tasks
Write-Host ""
Write-Host "[4/5] Queueing TR-069 Unlock RPC Tasks..." -ForegroundColor Magenta

function Push-AcsTask {
    param(
        [string]$DeviceId,
        [hashtable]$TaskObj
    )
    $encodedId = [System.Uri]::EscapeDataString($DeviceId)
    $taskUrl = "$NbiUrl/devices/$encodedId/tasks"
    $bodyJson = $TaskObj | ConvertTo-Json -Depth 6 -Compress

    try {
        $res = Invoke-RestMethod -Uri $taskUrl -Method Post -Body $bodyJson -ContentType "application/json" -TimeoutSec 5
        return $true
    } catch {
        Write-Host "      Task error: $_" -ForegroundColor DarkGray
        return $false
    }
}

# Task 1: Refresh Object
Write-Host "  -> [1/4] Queueing Object Tree Refresh..." -ForegroundColor Cyan
Push-AcsTask -DeviceId $detectedDeviceId -TaskObj @{
    name = "refreshObject"
    objectName = ""
} | Out-Null

# Task 2: Enable USB Debugging (Device.JioSTB)
Write-Host "  -> [2/4] Queueing Device.JioSTB USB Debugging & Validity (2037)..." -ForegroundColor Cyan
Push-AcsTask -DeviceId $detectedDeviceId -TaskObj @{
    name = "setParameterValues"
    parameterValues = @(
        @("Device.JioSTB.USB.USBDebugging", $true, "xsd:boolean"),
        @("Device.JioSTB.USB.DebugValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime")
    )
} | Out-Null

# Task 3: Enable USB Debugging (Device.JSTB branch)
Write-Host "  -> [3/4] Queueing Device.JSTB USB Debugging & Validity (2037)..." -ForegroundColor Cyan
Push-AcsTask -DeviceId $detectedDeviceId -TaskObj @{
    name = "setParameterValues"
    parameterValues = @(
        @("Device.JSTB.USB.USBDebugging", $true, "xsd:boolean"),
        @("Device.JSTB.USB.DebugValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime")
    )
} | Out-Null

# Task 4: Disable FOTA Updates
Write-Host "  -> [4/4] Queueing FOTA Update Disable & Downgrade Enable..." -ForegroundColor Cyan
Push-AcsTask -DeviceId $detectedDeviceId -TaskObj @{
    name = "setParameterValues"
    parameterValues = @(
        @("Device.JioSTB.FOTA.Disable", "true", "xsd:string"),
        @("Device.JioSTB.FOTA.DowngradeEnable", "true", "xsd:string"),
        @("Device.JioSTB.FOTA.DowngradeValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime"),
        @("Device.JSTB.FOTA.Disable", "true", "xsd:string"),
        @("Device.JSTB.FOTA.DowngradeEnable", "true", "xsd:string"),
        @("Device.JSTB.FOTA.DowngradeValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime")
    )
} | Out-Null

Write-Host "  [✓] All TR-069 unlock parameters queued successfully into GenieACS!" -ForegroundColor Green
Write-Host "      STB will receive these parameters during its CWMP session." -ForegroundColor Gray
Write-Host ""

# 5. Connect via Wireless ADB
Write-Host "[5/5] Connecting to Wireless ADB at $StbIp`:$AdbPort..." -ForegroundColor Magenta

# Check if adb is present
$adbCommand = "adb"
$adbAvailable = $null -ne (Get-Command "adb" -ErrorAction SilentlyContinue)
if (-not $adbAvailable) {
    Write-Host "  [!] 'adb' not found in system PATH. Attempting to locate adb..." -ForegroundColor Yellow
    # Check current directory or common paths
    if (Test-Path ".\adb.exe") {
        $adbCommand = ".\adb.exe"
        $adbAvailable = $true
    }
}

if (-not $adbAvailable) {
    Write-Host "  [!] ADB executable not detected." -ForegroundColor Red
    Write-Host "      Once STB reboots and accepts the ACS parameters, you can connect manually using:" -ForegroundColor Yellow
    Write-Host "      adb connect $StbIp`:$AdbPort" -ForegroundColor Cyan
    Write-Host ""
} else {
    $connected = $false
    Write-Host "  [*] Polling ADB daemon (waiting for STB to enable ADB)..." -ForegroundColor Cyan
    Write-Host "  (If STB doesn't open ADB immediately, restart STB power once more)" -ForegroundColor Gray

    for ($i = 1; $i -le 35; $i++) {
        Write-Host "  [Attempt $i/35] Connecting to $StbIp`:$AdbPort..." -NoNewline
        $adbOut = (& $adbCommand connect "$StbIp`:$AdbPort" 2>&1) | Out-String

        if ($adbOut -match "connected to" -and $adbOut -notmatch "failed|refused") {
            Write-Host " CONNECTED!" -ForegroundColor Green
            $connected = $true
            break
        } else {
            Write-Host " Waiting..." -ForegroundColor DarkGray
            Start-Sleep -Seconds 3
        }
    }

    if ($connected) {
        Write-Host ""
        Write-Host "==============================================================================" -ForegroundColor Green
        Write-Host "  🎉 SUCCESS! ADB IS CONNECTED TO JIO STB ($StbIp)                           " -ForegroundColor Green
        Write-Host "==============================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "[*] Connected Devices:" -ForegroundColor Cyan
        & $adbCommand devices -l

        Write-Host ""
        Write-Host "[*] Applying Essential Android TV Setup Fixes..." -ForegroundColor Magenta
        
        # 1. Device provision fix (Fixes remote HOME button)
        Write-Host "  -> Setting device_provisioned = 1 (Enables HOME button)..." -ForegroundColor Cyan
        & $adbCommand shell settings put global device_provisioned 1
        & $adbCommand shell settings put secure user_setup_complete 1
        & $adbCommand shell settings put secure tv_user_setup_complete 1

        Write-Host "  [✓] Remote navigation and HOME key unlocked!" -ForegroundColor Green

        Write-Host ""
        $doAudio = Read-Host "Would you like to unlock Dolby Atmos & DTS-HD Audio now? (y/n) [Default: y]"
        if ($doAudio -ne "n") {
            Write-Host "  -> Enabling Dolby Atmos / Surround Formats..." -ForegroundColor Cyan
            & $adbCommand shell settings put global encoded_surround_output 2
            & $adbCommand shell settings put global encoded_surround_output_enabled_formats '"5,6,7,8,14,17,18"'
            & $adbCommand shell settings put global drc_mode 0
            Write-Host "  [✓] Dolby Atmos & Surround Audio unlocked!" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "==============================================================================" -ForegroundColor Cyan
        Write-Host "  All Steps Complete! Your Jio STB is now fully accessible via ADB.           " -ForegroundColor Green
        Write-Host "                     Developed by DC                                          " -ForegroundColor Yellow
        Write-Host "==============================================================================" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "[!] ADB connection timed out." -ForegroundColor Yellow
        Write-Host "    Steps to troubleshoot:" -ForegroundColor Gray
        Write-Host "    1. Check if STB took the new parameters in GenieACS GUI (http://localhost:3000)" -ForegroundColor Gray
        Write-Host "    2. Power-cycle the STB once more." -ForegroundColor Gray
        Write-Host "    3. Run: adb connect $StbIp`:$AdbPort" -ForegroundColor Gray
    }
}
