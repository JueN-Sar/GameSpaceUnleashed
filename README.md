# Game Space Unleashed by MsysteM

Magisk/Zygisk module to unlock Super Resolution and Game Space features for **all** games on RedMagic devices. **No LSPosed required** — powered by Zygisk + LSPlant.

## Features

- ⚡ **Super Resolution / Superior Pic Quality** for ALL games
- 🎮 **Global Game Mode** — treat any app as a game
- 🛡️ **No Kill** — prevent background app cleanup
- 🔲 **Hide Energy Cube** overlay
- 📐 **Small Window** for all apps
- ✍️ **Extended watermark** text length

## Requirements

- Magisk with Zygisk **or** ReZygisk
- RedMagic device with Game Space
- [KsuWebUI](https://github.com/5ec1cff/KsuWebUIStandalone) for settings interface

## Installation

1. Flash the zip in Magisk/KernelSU
2. Reboot
3. Open KsuWebUI → Game Space Unleashed
4. Toggle features and tap **"Apply & Restart Games"**

## Architecture

```
native/src/main.cpp     — Zygisk module: DEX loader + LSPlant init
native/src/zygisk.hpp   — Zygisk API v5 header
java/                   — Java hooks (compiled to DEX by CI)
module/                 — Magisk module files + KsuWebUI interface
```

- **Zygisk** injects into `cn.nubia.gamelauncher` and `cn.nubia.gameassist`
- **LSPlant** (with Dobby inline hooking) replaces Java methods at runtime
- **No LSPosed** — the module handles ART hooking directly, keeping root less detectable

## Building

Builds run automatically via GitHub Actions. To build locally:

```bash
# Clone dependencies
git clone --depth=1 https://github.com/LSPosed/Dobby.git external/dobby
git clone --depth=1 --branch v6.4 https://github.com/LSPosed/LSPlant.git external/lsplant
cd external/lsplant && git submodule update --init --recursive --depth=1 lsplant/src/main/jni/external/dex_builder && cd ../..

# Build native (requires Android NDK 27)
cd native && mkdir build
cmake -B build \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-26 \
  -DANDROID_STL=c++_static -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

## License

ISC (Zygisk API header) — see individual file headers for details.
