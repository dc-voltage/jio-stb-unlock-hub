#!/bin/bash
# Jio STB Quick Provisioner: Audio & Navigation Fixes
# Compatible with JMSB200Av2 and similar Android 9/11 models

set -e

DEVICE_IP="${1}"
ADB_CMD="adb"

if [ -n "$DEVICE_IP" ]; then
    echo "[*] Connecting to $DEVICE_IP:5555..."
    adb connect "$DEVICE_IP:5555"
    ADB_CMD="adb -s $DEVICE_IP:5555"
fi

echo "[*] 1. Fixing Remote HOME Key (Setup Provisioning)..."
$ADB_CMD shell settings put secure tv_user_setup_complete 1
$ADB_CMD shell settings put secure user_setup_complete 1
$ADB_CMD shell settings put global device_provisioned 1

echo "[*] 2. Unlocking Dolby Atmos & DTS-HD Audio..."
$ADB_CMD shell settings put global encoded_surround_output 2
$ADB_CMD shell settings put global encoded_surround_output_enabled_formats "5,6,7,8,14,17,18"

echo "[*] 3. Disabling Dynamic Range Compression (DRC)..."
$ADB_CMD shell settings put global drc_mode 0

echo "[*] 4. Exposing Stock Android TV Settings..."
$ADB_CMD shell pm uninstall -k --user 0 com.rjil.jiostbsetting 2>/dev/null || true

echo "[+] Done! Device optimized successfully."
