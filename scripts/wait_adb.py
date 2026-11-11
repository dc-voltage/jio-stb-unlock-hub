#!/usr/bin/env python3
import time
import subprocess
import urllib.request
import json

import sys

STB_IP = sys.argv[1] if len(sys.argv) > 1 else "192.168.28.15"
DEVICE_ID = sys.argv[2] if len(sys.argv) > 2 else "3C55DB-JMSB200A-RDXSBEKB0039104"
NBI_URL = "http://127.0.0.1:7557"

print(f"[*] Monitoring GenieACS tasks & ADB for {DEVICE_ID} ({STB_IP})...")

while True:
    try:
        # Check remaining tasks in GenieACS
        req = urllib.request.Request(f"{NBI_URL}/tasks?query=%7B%22device%22%3A%22{DEVICE_ID}%22%7D")
        with urllib.request.urlopen(req, timeout=3) as resp:
            tasks = json.loads(resp.read().decode())
            print(f"[*] Tasks pending in GenieACS: {len(tasks)}")
    except Exception as e:
        pass

    # Try adb connect
    res = subprocess.run(["adb", "connect", f"{STB_IP}:5555"], capture_output=True, text=True)
    out = res.stdout.strip()
    if "connected to" in out.lower() and "failed" not in out.lower():
        print(f"\n[🔥 ADB CONNECTED SUCCESSFULLY!]: {out}")
        subprocess.run(["adb", "devices", "-l"])
        break
    time.sleep(2)
