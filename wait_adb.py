#!/usr/bin/env python3
import time
import subprocess
import urllib.request
import json

STB_IP = "192.168.28.36"
DEVICE_ID = "3C55DB-JMSB200A-RDXSBIKBE247854"
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
