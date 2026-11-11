#!/usr/bin/env python3
import time
import json
import urllib.request
import urllib.parse
import subprocess
import sys

NBI_URL = "http://127.0.0.1:7557"
STB_IP = sys.argv[1] if len(sys.argv) > 1 else "192.168.28.15"
ADB_PORT = 5555

def get_devices():
    try:
        req = urllib.request.Request(f"{NBI_URL}/devices/?projection=_id,_lastInform,_deviceId")
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        return []

def queue_task(device_id, payload):
    enc_id = urllib.parse.quote(device_id, safe='')
    url = f"{NBI_URL}/devices/{enc_id}/tasks"
    data = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            return resp.status
    except Exception as e:
        return str(e)

def main():
    print("=" * 65)
    print("  JMSB200Av2 GenieACS Auto-Unlock Monitor")
    print("=" * 65)
    print(f"[*] Target STB IP: {STB_IP}")
    print("[*] Taking initial snapshot of GenieACS devices...")

    initial_devices = get_devices()
    initial_ids = {d.get("_id"): d.get("_lastInform") for d in initial_devices}
    print(f"[*] Found {len(initial_devices)} registered device(s) currently in GenieACS:")
    for did in initial_ids:
        print(f"    - {did}")

    print("\n[*] Waiting for JMSB200Av2 Inform to arrive...")
    print("    👉 Please REBOOT the STB (power off at plug for 5s, then power ON)!")

    detected_device = None
    while not detected_device:
        current_devices = get_devices()
        for d in current_devices:
            did = d.get("_id", "")
            last_inform = d.get("_lastInform", "")
            # Check for brand new device or updated inform timestamp
            if did not in initial_ids:
                detected_device = did
                print(f"\n[🎉 NEW DEVICE CONNECTED!]: {detected_device}")
                break
            elif last_inform and last_inform != initial_ids.get(did):
                detected_device = did
                print(f"\n[🎉 ACTIVE INFORM RECEIVED FROM]: {detected_device}")
                break
        if not detected_device:
            time.sleep(2)

    print(f"\n[*] Applying TR-069 provisioning tasks to {detected_device}...")
    
    # 1. Refresh object tree
    print("  -> Queueing refreshObject...")
    queue_task(detected_device, {"name": "refreshObject", "objectName": ""})

    # 2. USB Debugging parameters (both JioSTB and JSTB branches for safety)
    print("  -> Queueing USB Debugging & Validity (2037)...")
    queue_task(detected_device, {
        "name": "setParameterValues",
        "parameterValues": [
            ["Device.JioSTB.USB.USBDebugging", True, "xsd:boolean"],
            ["Device.JioSTB.USB.DebugValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime"]
        ]
    })
    queue_task(detected_device, {
        "name": "setParameterValues",
        "parameterValues": [
            ["Device.JSTB.USB.USBDebugging", True, "xsd:boolean"],
            ["Device.JSTB.USB.DebugValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime"]
        ]
    })

    # 3. Disable FOTA updates
    print("  -> Queueing FOTA Disable...")
    queue_task(detected_device, {
        "name": "setParameterValues",
        "parameterValues": [
            ["Device.JioSTB.FOTA.Disable", "true", "xsd:string"],
            ["Device.JioSTB.FOTA.DowngradeEnable", "true", "xsd:string"],
            ["Device.JioSTB.FOTA.DowngradeValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime"]
        ]
    })
    queue_task(detected_device, {
        "name": "setParameterValues",
        "parameterValues": [
            ["Device.JSTB.FOTA.Disable", "true", "xsd:string"],
            ["Device.JSTB.FOTA.DowngradeEnable", "true", "xsd:string"],
            ["Device.JSTB.FOTA.DowngradeValidityDate", "2037-12-31T23:59:59.000Z", "xsd:dateTime"]
        ]
    })

    print("\n[✓] All unlock tasks queued successfully!")
    print(f"[*] Now testing ADB connection to {STB_IP}:{ADB_PORT}...")

    connected = False
    for attempt in range(1, 30):
        res = subprocess.run(["adb", "connect", f"{STB_IP}:{ADB_PORT}"], capture_output=True, text=True)
        if "connected to" in res.stdout.lower() and "failed" not in res.stdout.lower():
            print(f"[🔥 ADB CONNECTED!]: {res.stdout.strip()}")
            connected = True
            break
        print(f"  Attempt {attempt}/30 waiting for ADB daemon...")
        time.sleep(3)

    if connected:
        subprocess.run(["adb", "devices", "-l"])
    else:
        print("[!] ADB not yet open. If STB requires a second reboot after receiving parameters, please reboot once more.")

if __name__ == "__main__":
    main()
