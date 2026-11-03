#!/bin/bash
# 🛰️ One-Click Live TV Setup for Jio STB (JioFreeView-IPTV)
# Downloads TiviMate & pushes curated 500+ Indian & Malayalam Live TV playlists

set -e

STB_IP="${1:-192.168.28.36}"
ADB_CMD="adb -s $STB_IP:5555"

echo "=========================================================="
echo "  🛰️ JioFreeView-IPTV: Live TV Provisioning Tool"
echo "=========================================================="

echo "[*] Connecting to STB at $STB_IP:5555..."
adb connect "$STB_IP:5555" || true

echo "[*] 1. Checking / Installing TiviMate IPTV Player..."
if ! $ADB_CMD shell pm list packages | grep -q 'ar.tvplayer.tv'; then
    echo "[-] Downloading latest TiviMate APK..."
    curl -sL -o /tmp/tivimate.apk "https://files.tivimate.com/tivimate.apk"
    echo "[-] Installing TiviMate on STB..."
    $ADB_CMD install -r /tmp/tivimate.apk
else
    echo "[+] TiviMate is already installed."
fi

echo "[*] 2. Downloading Curated Free TV Playlists..."
curl -sL "https://iptv-org.github.io/iptv/languages/mal.m3u" > /tmp/malayalam_tv.m3u
curl -sL "https://iptv-org.github.io/iptv/countries/in.m3u" > /tmp/india_tv.m3u

echo "[*] 3. Pushing Playlists to STB Storage (/sdcard/)..."
$ADB_CMD push /tmp/malayalam_tv.m3u /sdcard/malayalam_tv.m3u
$ADB_CMD push /tmp/india_tv.m3u /sdcard/india_tv.m3u

echo "=========================================================="
echo "  [+] SUCCESS! Live TV Provisioning Complete."
echo "  Open TiviMate -> Add Playlist -> Local Playlist:"
echo "    - /sdcard/malayalam_tv.m3u (Malayalam Live TV)"
echo "    - /sdcard/india_tv.m3u     (500+ All-India Channels)"
echo "=========================================================="
