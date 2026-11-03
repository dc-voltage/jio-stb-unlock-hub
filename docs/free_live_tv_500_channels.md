# 🛰️ JioFreeView-IPTV: 500+ Zero-Subscription Live Channels on Jio STB

[![IPTV](https://img.shields.io/badge/Live_TV-500%2B_Channels-red?logo=youtube&logoColor=white)](#)
[![No JioFiber Lock](https://img.shields.io/badge/ISP_Lock-Bypassed-brightgreen)](#)
[![EPG Supported](https://img.shields.io/badge/EPG-Included-blue)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

> **Transform your locked or ISP-restricted Jio Set-Top Box into a Universal 500+ Channel Free Satellite DTH Receiver — No JioFiber Connection, No Monthly Subscriptions, No Hidden Fees!**

---

## 🌟 Why JioFreeView-IPTV?

The default **JioTV+** app on Jio Set-Top Boxes has strict server-side locks: it forces an active JioFiber/AirFiber connection and refuses playback over other internet providers (Asianet, Airtel, BSNL, Railwire, or 4G/5G mobile hotspots).

**JioFreeView-IPTV** completely eliminates this restriction by utilizing **TiviMate IPTV Player** paired with legally broadcast public M3U streams and EPG guides.

### ✨ Highlights
- 🆓 **100% Free & Legal:** Streams publicly accessible and open-access broadcast feeds (including Prasar Bharati DD Free Dish, major Indian news networks, and regional broadcasters).
- 🌐 **ISP Freedom:** Works flawlessly over **ANY** internet provider (Airtel, Asianet, BSNL, ACT, or mobile hotspot).
- 📡 **True Satellite DTH Experience:** Full-screen TV remote navigation with channel flipping, volume rocker control, and interactive TV Guide (EPG).
- ⚡ **Zero Lag & Hardware Accelerated:** Native decoding utilizing the Amlogic video hardware with support for 1080p Full HD streams.

---

## 📺 Channel Lineup Breakdown (500+ Channels)

### 🌴 Malayalam Channels (35+ Channels)
* **News 24x7:** 24 News, Asianet News, Manorama News, MediaOne, Mathrubhumi News, Janam TV, News18 Kerala
* **Entertainment & General:** Amrita TV, DD Malayalam, Jaihind TV, Jeevan TV, Darshana TV, CCV
* **Movies & Specials:** Asianet Movies, Flowers TV (USA), Big TV 24x7, C Malayalam TV
* **Kids & Infotainment:** Cartoon Network, Discovery Channel, Discovery Kids
* **Devotional & Religious:** Goodness TV, Harvest TV, Harvest TV Keralam, Shalom TV

### 🇮🇳 National & Hindi Channels (150+ Channels)
* **DD Network:** DD National, DD News, DD Sports, DD Kisan, DD Bharati, DD Retro, Sansad TV
* **Hindi News:** Aaj Tak, NDTV India, ABP News, Zee News, India TV, News18 India, Republic Bharat, Times Now Navbharat
* **Music & Youth:** 9XM, Mastiii, B4U Music, MTV Beats (web feeds)

### 🏏 Sports & Action (25+ Channels)
* **Live Sports:** DD Sports 1.0 & 2.0 (Live Cricket, National Sports), Red Bull TV, Olympic Channel, FIFA+, Stadium, Motorsport TV, Eurosport Free

### 🌍 Regional Indian Languages (200+ Channels)
* **Tamil (40+):** Sun News, Polimer News, Thanthi TV, Puthiya Thalaimurai, DD Podhigai, Kalaignar TV
* **Telugu (40+):** TV9 Telugu, NTV, ABN Andhra Jyothi, DD Yadagiri, DD Saptagiri
* **Kannada (25+):** TV9 Kannada, Suvarna News, Public TV, DD Chandana
* **Bengali, Marathi, Punjabi, Gujarati & Odia:** 100+ channels including DD Sahyadri, DD Bangla, Zee 24 Taas, ABP Majha.

### 🌐 Global & English News (30+ Channels)
* BBC News World, Al Jazeera English, DW News (Germany), France 24, Bloomberg TV, CNA (Singapore), Euronews, Sky News Free.

---

## 🛠️ Step-by-Step Setup Guide

### Step 1: Install TiviMate IPTV Player
TiviMate is the premier Android TV IPTV player with genuine DTH interface and remote support:

```bash
# Connect to your Jio STB via ADB
adb connect <STB_IP_ADDRESS>:5555

# Download and install the latest TiviMate APK
curl -sL -o /tmp/tivimate.apk "https://files.tivimate.com/tivimate.apk"
adb install -r /tmp/tivimate.apk
```

---

### Step 2: Push Pre-Bundled Playlists to STB Storage
To save yourself from typing long URLs on your TV remote, you can push the curated playlists directly to the STB's internal storage:

```bash
# 1. Download curated playlists
curl -sL "https://iptv-org.github.io/iptv/languages/mal.m3u" > /tmp/malayalam_tv.m3u
curl -sL "https://iptv-org.github.io/iptv/countries/in.m3u" > /tmp/india_tv.m3u

# 2. Push directly to STB storage
adb push /tmp/malayalam_tv.m3u /sdcard/malayalam_tv.m3u
adb push /tmp/india_tv.m3u /sdcard/india_tv.m3u
```

---

### Step 3: Configure TiviMate (2 Minutes Setup)

1. Grab your **Jio Remote** and open **TiviMate** from your launcher (Projectivy Launcher).
2. On the welcome screen, select **"Add Playlist"**.
3. Choose **"M3U playlist"**.
4. Select **"Select local playlist"** and browse to:
   * 📁 `/sdcard/malayalam_tv.m3u` *(for Malayalam Channels)*
   * 📁 `/sdcard/india_tv.m3u` *(for 500+ All-India Channels)*
   *(Alternatively, select "Enter URL" and type: `https://iptv-org.github.io/iptv/languages/mal.m3u`)*
5. Click **Next** -> Enter a playlist name (e.g., `JioFreeView`) -> Click **Done**.
6. **Enjoy!** All live channels will immediately populate with full categories.

---

### Step 4: Adding the Electronic Program Guide (EPG)
To see what show is currently playing and upcoming program schedules:

1. In TiviMate, go to **Settings ⚙️** -> **TV Guide (EPG)**.
2. Select **EPG Sources** -> **Add Source**.
3. Enter the URL:
   ```text
   https://iptv-org.github.io/epg/guides/in.xml
   ```
4. Click **Done** and toggle **"Update on app start"**. Program timelines will now sync automatically!

---

## 🎯 Pro Remote Control Shortcuts in TiviMate

| Remote Button | Action |
| :--- | :--- |
| **D-Pad UP / DOWN** | Change channels sequentially (DTH style) |
| **D-Pad CENTER (OK)** | Show channel quick list & preview screen |
| **D-Pad LEFT** | Open full categorized channel sidebar |
| **D-Pad RIGHT** | Open Interactive TV Guide (EPG Timeline) |
| **BACK Button** | Return to video or exit overlay |

---

## 📜 Legal & Attribution
* All M3U streams and broadcast feeds are sourced from [iptv-org](https://github.com/iptv-org/iptv) under the Unlicense / Public Domain.
* Streams point exclusively to freely accessible, public live feeds provided by respective network operators.
