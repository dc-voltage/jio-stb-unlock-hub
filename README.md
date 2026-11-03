# 🚀 Jio STB Universal Unlock & Modding Hub

[![Android](https://img.shields.io/badge/Android_TV-9%20%7C%2010%20%7C%2011-3DDC84?logo=android&logoColor=white)](#)
[![TR-069](https://img.shields.io/badge/Exploit-TR--069%20%2F%20CWMP-orange)](#)
[![Status](https://img.shields.io/badge/Status-Active%20%26%20Verified-brightgreen)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive, production-grade guide and automation toolkit for unlocking, debloating, and transforming locked **Reliance Jio Set-Top Boxes (STB)** into clean, high-performance Android TV powerhouses.

---

## 📑 Supported Hardware & Compatibility Matrix

| STB Model | SoC / Chipset | Android Version | ADB Unlock Method | Custom Launcher | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **JMSB200Av2** | Amlogic S905-series | **Android 11** | TR-069 / GenieACS RPC | Projectivy Launcher | 🟢 **Verified & Stable** |
| **JHSD200** | Amlogic S905X2 | Android 9 Pie | TR-069 / ADB over Wi-Fi | Leanback / Projectivy | 🟢 **Supported** |
| **JHS200** | Amlogic | Android 9 Pie | TR-069 / Fastboot | ATV Launcher | 🟢 **Supported** |
| **JMB200** | Marvell / Amlogic | Android 9 Pie | CWMP Injection | Projectivy Launcher | 🟡 **Community Tested** |
| **JHT200** | Broadcom / Amlogic | Android 9 / 10 | TR-069 / Serial UART | Custom | ⏳ **WIP** |

---

## 🌟 What This Toolkit Achieves
- 🔓 **TR-069 / CWMP ACS Exploitation:** Enable ADB debugging wirelessly on production locked firmware without hardware disassembly.
- 📺 **Ad-Free Custom TV Experience:** Replace intrusive default operator launchers with lightweight, customizable **Projectivy Launcher**.
- 🛒 **True Alternative App Stores:** Direct integration with **Aurora Store** (official Google Play Store API without GMS/certification locks) and **Aptoide TV**.
- 🔊 **Cinematic Audio Unlock:** Force-enable hidden hardware decoding for **Dolby Atmos**, **DTS-HD Master Audio**, and disable dynamic range compression (DRC).
- 🧹 **Deep Debloating:** Remove 22+ background telemetry trackers, ad services, and background CPU hogs while preserving critical account services.
- ⚙️ **Hidden Android TV Settings:** Directly expose Stock Android TV Settings and Developer Options.

---

## 📂 Repository Architecture (Pro Monorepo Structure)

```text
jio-stb-unlock-hub/
├── README.md                          # Main repository landing page & matrix
├── docs/                              # Universal technical documentation
│   ├── tr069_exploit_guide.md         # TR-069 / GenieACS setup walkthrough
│   ├── safe_debloat_guide.md          # Bloatware vs critical service index
│   └── audio_enhancements.md          # Dolby Atmos / DTS-HD activation guide
├── models/                            # Model-specific deep guides & firmware notes
│   ├── JMSB200Av2/                    # Jio STB JMSB200Av2 (Android 11)
│   │   ├── README.md                  # Complete step-by-step model guide
│   │   └── screenshots/               # High-res 1080p UI screenshots
│   ├── JHSD200/
│   │   └── README.md
│   └── JHS200/
│       └── README.md
└── scripts/                           # Reusable automation tools
    ├── monitor_and_unlock.py          # Automated TR-069 ACS RPC listener & unlocker
    ├── debloat.sh                     # One-click safe debloating script
    └── setup_stb.sh                   # Automated launcher & settings provisioner
```

---

## ⚡ Quick Start: Unlocking Your Device

1. **Select Your Model:**
   Head directly to your specific model folder in [`models/`](models/):
   - For **JMSB200Av2 (Android 11)**, see [**JMSB200Av2 Guide**](models/JMSB200Av2/README.md).

2. **Network Setup:**
   Direct your STB's CWMP traffic to your local GenieACS instance (via DNS redirection, ARP spoofing, or router iptables).

3. **Run Automation Scripts:**
   ```bash
   cd scripts
   python3 monitor_and_unlock.py
   ```

---

## 🤝 Contributing
Have you tested or unlocked another model? PRs and issues for new models, firmware revisions, and scripts are warmly welcomed!

## ⚠️ Disclaimer
*This repository is for educational and interoperability research purposes only. All trademarks belong to their respective owners.*
