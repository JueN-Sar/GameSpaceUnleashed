#!/system/bin/sh
# Game Space Unleashed by MsysteM — Installation Script

SKIPUNZIP=0

ui_print "╔══════════════════════════════════════╗"
ui_print "║   Game Space Unleashed by MsysteM    ║"
ui_print "║            v2.0.1                     ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""
ui_print "→ Unlocking ALL Game Space features..."
ui_print "  ✓ Super Resolution for ALL games"
ui_print "  ✓ Frame Rate Boost for ALL games"
ui_print "  ✓ ALL plugins enabled for ALL games"
ui_print "  ✓ Aim helper for ALL games"
ui_print "  ✓ 55 feature flags unlocked"
ui_print ""

# Check if this is a RedMagic device
if ! getprop ro.product.brand | grep -iq "nubia"; then
    ui_print "⚠ Warning: This module is designed for RedMagic devices."
    ui_print "  Your device brand: $(getprop ro.product.brand)"
    ui_print "  Continuing anyway..."
    ui_print ""
fi

# Check if GameAssist exists
if [ ! -d "/system/app/GameAssist" ]; then
    ui_print "⚠ Warning: GameAssist not found at /system/app/GameAssist"
    ui_print "  Game Space overlay features may not work."
fi

# Check if GameSpace exists
if [ ! -d "/system/priv-app/GameSpace" ]; then
    ui_print "⚠ Warning: GameSpace not found at /system/priv-app/GameSpace"
    ui_print "  Game launcher features may not work."
fi

# === Critical: Clear cached pre-compiled code (OAT/VDEX) ===
# Android caches ahead-of-time compiled native code from the original DEX.
# If we don't clear this, Android loads the OLD unpatched code from cache
# instead of our patched DEX files.
ui_print "→ Clearing OAT/VDEX cache for GameAssist..."
rm -rf /data/dalvik-cache/arm64/system@app@GameAssist@GameAssist.apk@classes*
rm -rf /data/dalvik-cache/arm/system@app@GameAssist@GameAssist.apk@classes*
rm -rf /data/dalvik-cache/*/system@app@GameAssist@*

ui_print "→ Clearing OAT/VDEX cache for GameSpace..."
rm -rf /data/dalvik-cache/arm64/system@priv-app@GameSpace@GameSpace.apk@classes*
rm -rf /data/dalvik-cache/arm/system@priv-app@GameSpace@GameSpace.apk@classes*
rm -rf /data/dalvik-cache/*/system@priv-app@GameSpace@*

# Also handle oat/ directories next to the APKs
# Create .replace markers so Magisk mounts empty dirs over the original oat/ folders
# This forces Android to recompile from our patched DEX
ui_print "→ Replacing OAT directories..."
mkdir -p "$MODPATH/system/app/GameAssist/oat"
touch "$MODPATH/system/app/GameAssist/oat/.replace"
mkdir -p "$MODPATH/system/priv-app/GameSpace/oat"
touch "$MODPATH/system/priv-app/GameSpace/oat/.replace"

# Clear PackageManager cache so it re-evaluates our APKs
ui_print "→ Clearing package manager cache..."
rm -rf /data/system/package_cache/*

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/system 0 0 0755 0644

ui_print ""
ui_print "✓ Installation complete!"
ui_print "→ Reboot to activate."
ui_print "→ After reboot, open any game in Game Space"
ui_print "  and ALL features will be available!"
ui_print ""
