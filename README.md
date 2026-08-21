# Game Space Unleashed by MsysteM

Magisk module that unlocks **ALL** Game Space features for **ALL** games on RedMagic devices.

**No LSPosed. No Xposed. No hooking frameworks.** Pure APK overlay — patched system apps replace the originals via Magisk's magic mount.

## What It Does

Opens every single gate in Game Space so that ALL features appear for ALL games, not just the officially supported ones.

### Unlocked Features

| Feature | What It Does |
|---------|-------------|
| ⚡ **Super Resolution / Superior Pic Quality** | R3 chip upscales lower resolution for better visuals |
| 🎮 **Frame Rate Boost / Frame Interpolation** | R3 chip inserts frames → forces 2K + 120FPS |
| 🎯 **Crosshair Overlay** | Custom crosshair for FPS games |
| 🔍 **Hunt Mode** | Visual filter to spot enemies easier |
| 📐 **Sight Assist / Auxiliary Line** | Shooting accuracy benchmarks |
| 🤖 **AI Trigger** | Automatic fire trigger |
| 🔊 **Sound Equalizer** | Directional audio (footsteps, gunfire) |
| 📳 **4D Vibrate** | Haptic feedback |
| 🎮 **Diablo Mode** | Maximum performance mode |
| 📊 **Game Prediction** | AI game prediction |
| 🎙️ **Voice Controller** | Voice commands in-game |
| 🖥️ **Screen Extraction** | Screen capture tools |
| 📡 **RedMagic Broadcast** | Streaming features |
| 🎮 **Combat Power** | Performance analysis |
| ⚙️ **55 ZTE Feature Flags** | Every hidden feature enabled |
| 🎯 **Aim Helper** | Aim assist for all games (was limited to 4 games) |
| 🏎️ **Touch Precision** | Enhanced touch response for all games |

### Patched Gate Methods (Technical)

**GameAssist (cn.nubia.gameassist):**
- `PluginUtils.getGfrcCapByPkg()` → returns 11 (SR + Frame Interp)
- `PluginConfig.isPluginEnable()` → always true
- `PluginConfig.isPluginEnabledForGame()` → always true  
- All 55 `ZteFeature.isSupport*()` → always true

**GameSpace (cn.nubia.gamelauncher):**
- `SuperResolutionHelper.supportSuperResolution()` → always true
- `SuperResolutionHelper.supportSuperResolutionByPkgName()` → always true
- `ControlPanelFeatureHelper.getZteFeatureMagicSuperResolution()` → TRUE
- `ControlPanelFeatureHelper.supportGames()` → always true
- `GameWhiteList.isSupportGame()` → always true
- All `getZteFeature*()` → TRUE

## Requirements

- **RedMagic device** with Game Space (tested on RM 10 Pro, RedMagicOS 11.0.5 MR1 EU)
- **Magisk** v20.4+ (or KernelSU with Magisk compatibility)
- GameAssist v16.5.000 / GameSpace v16.0.000

## Installation

1. Download `GameSpaceUnleashed-v2.0.0.zip` from [Releases](https://github.com/JueN-Sar/GameSpaceUnleashed/releases)
2. Open Magisk → Modules → Install from storage
3. Select the zip and flash
4. **Reboot**
5. Open any game in Game Space → all features available!

## Auto-Update

The module checks for updates automatically via Magisk. When a new version is available, you'll see "Update" in Magisk's module list.

## How It Works

Unlike Xposed/LSPosed modules that hook methods at runtime, this module **replaces the entire GameAssist and GameSpace APKs** with patched versions. Magisk's magic mount overlays our patched APKs over the originals at boot time.

The patcher script (`patches/apply_patches.py`) modifies the decompiled smali code to remove all game-specific restrictions, then recompiles the APKs.

## Compatibility Notice

This module is built for a specific ROM version. If RedMagic pushes an OTA that updates GameAssist or GameSpace, you may need to wait for an updated module version.

## Credits

- **MsysteM** — Module creator
- **apktool** — APK decompilation/recompilation
- **NubiaToolkit** — Reverse engineering research reference
