#!/bin/bash
# Safe Debloating Script for Jio STB (JMSB200Av2 & Others)
# Keeps com.media.jio.sso.stb intact so JioTV+ doesn't crash!

set -e

PACKAGES_TO_REMOVE=(
    "com.jio.stbadservice"
    "com.jio.systemstats"
    "com.jio.stb.remotediagnose"
    "com.jio.appoptimizer"
    "com.jio.backgroundscheduler"
    "com.jio.bioscopecontentservice"
    "com.jio.stb.bot"
    "com.jio.stb.hotellauncher"
    "com.jiostb.fti"
    "com.jio.screensaver"
    "com.jio.stbwidget"
    "com.jio.controlcentre"
    "com.teamviewer.quicksupport.addon.jio_stb"
)

echo "[*] Starting safe debloat process..."
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    echo "[-] Disabling / uninstalling: $pkg"
    adb shell pm uninstall -k --user 0 "$pkg" 2>/dev/null || true
done

echo "[+] Safe debloat complete! Jio Account SSO has been preserved."
