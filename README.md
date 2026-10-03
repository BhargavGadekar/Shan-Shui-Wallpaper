# 🏔️ Shan Shui Live Wallpaper for macOS

> **Infinite, procedurally generated Chinese landscape painting (*Shan Shui*, 山水) as a native live desktop wallpaper for macOS.**

Originally conceived as a generative algorithm by [Lingdong Huang](https://github.com/LingDong-/shan-shui-inf), this project packages the infinite landscape into a **100% standalone, native macOS live wallpaper application** optimized for Apple Silicon (M1/M2/M3/M4/M5).

---

## ✨ Features

* **♾️ 100% Non-Repeating & Infinite:** Not a looping video! Every mountain ridge, pine tree, misty ravine, arched bridge, and solitary fishing boat is mathematically generated on the fly as you drift across the canvas.
* **⚡ Ultra-Low Battery & CPU Usage:** Rewritten with a GPU-composited render pipeline. Uses only **~2% CPU** of a single core and sips virtually zero battery on MacBook Air/Pro.
* **🧘 Zen Drift Speed:** Defaults to a serene, meditative drift speed of **3 px/s** (takes ~7 minutes to travel across an entire screen).
* **🎛️ Dual Control Modes:**
  * **Menu Bar Icon (`🏔️ Shan Shui`):** Direct speed switcher (Zen, Calm, Gentle, Flow), Pause/Resume, and Random Seed generator.
  * **Native Control Panel Window:** Accessible anytime via Spotlight or Launchpad.
* **📦 100% Portable & Standalone:** Requires no terminal commands, no Node.js, no Homebrew, and no third-party utilities. Just open `ShanShuiWallpaper.app`.

---

## 🚀 Quick Start (No Coding Required)

1. Download or locate `ShanShuiWallpaper.app`.
2. Move it to your **`/Applications`** folder.
3. Double-click to open it!
4. The landscape will immediately begin drifting across your desktop behind your windows.

---

## 🎛️ Controls & Settings

### 1. From the Top Menu Bar (`🏔️ Shan Shui`)
Click **`🏔️ Shan Shui`** in your top macOS menu bar to:
* **Change Speed Directly:**
  * **🧘 Zen (3 px/s)** — Recommended (slow, meditative drift)
  * **🍃 Calm (6 px/s)** — Relaxed pace (~3.5 min per screen)
  * **🌊 Gentle (12 px/s)** — Subtle motion
  * **⚡ Flow (24 px/s)** — Active flow
* **⏸ Pause / Resume Scrolling**
* **🎲 New Landscape (Random Seed)** — Generate a new mountain range
* **⇄ Reverse Direction** — Drift left or right
* **⚙ Open Control Panel...**

### 2. From the Control Panel Window
Search **`Shan Shui`** in macOS Spotlight (`Cmd + Space`) or Launchpad to bring up the clean Control Panel window with clickable speed segments, play/pause, and a **"Launch automatically when Mac starts"** toggle.

---

## 🛠️ Building from Source

To compile the native app from source on any Mac:

```bash
git clone https://github.com/your-username/shan-shui-wallpaper.git
cd shan-shui-wallpaper
./build.sh
```

The script compiles `main.swift` with Apple's `swiftc` compiler, bundles `index.html` into `Contents/Resources`, and signs the `.app` bundle.

---

## 📜 Project Structure

```
wallpaper/
├── ShanShuiWallpaper.app/   # Ready-to-run macOS live wallpaper application
├── index.html               # Procedural landscape engine & GPU motion pipeline
├── index.original.html      # Original upstream repository reference
├── main.swift               # Native Swift AppKit/WebKit window & controller
├── build.sh                 # 1-click compiler script
├── start.sh                 # Terminal start helper
├── stop.sh                  # Terminal stop helper
├── enable_launch_at_login.sh # Auto-start helper
├── disable_launch_at_login.sh# Disable auto-start helper
├── LICENSE                  # MIT License
└── README.md                # Documentation
```

---

## 🎨 About the Art: Shan Shui (山水)

**Shan Shui** (Chinese: *山水*, literally *"Mountain-Water"*) is a traditional style of Chinese landscape painting that flourished during the Tang and Song Dynasties. Based on Taoist principles of balance (Yin and Yang), it contrasts the permanence of mountains with the impermanence of water and mist. 

In traditional Chinese culture, these masterpieces were painted on long horizontal **handscrolls (手卷)** meant to be unrolled slowly section by section, taking the viewer on an intimate, unfolding visual journey through nature.

---

## 📄 Credits & License

* Generative algorithms and original art: [Lingdong Huang](https://github.com/LingDong-) ([shan-shui-inf](https://github.com/LingDong-/shan-shui-inf)).
* macOS / Mac Native Live Wallpaper App & GPU Optimization: Open-source under the [MIT License](LICENSE).
* Credits: [districtlabs.in](https://districtlabs.in)
