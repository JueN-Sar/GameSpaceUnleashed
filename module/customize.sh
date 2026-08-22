#!/system/bin/sh
# Game Space Unleashed v3.0.0 by MsysteM — Installation Script
# Property-only approach: no APK replacement, original apps stay intact

SKIPUNZIP=0

ui_print "╔══════════════════════════════════════╗"
ui_print "║   Game Space Unleashed by MsysteM    ║"
ui_print "║         v3.0.0 — GFRC Edition        ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""
ui_print "→ What's new in v3.0.0:"
ui_print "  ★ GFRC Super Resolution + Frame Interpolation"
ui_print "    for ALL games (vendor.gpp.allgame bypass)"
ui_print "  ★ KSU WebUI control panel"
ui_print "  ★ space_trigger fix for international ROMs"
ui_print "  ★ Config-driven — toggle features from WebUI"
ui_print "  ✓ ALL plugins unlocked for ALL games"
ui_print "  ✓ gamespace_config ALL flags enabled"
ui_print "  ✓ No APK replacement — original apps intact"
ui_print ""

# Check if this is a RedMagic device
if ! getprop ro.product.brand | grep -iq "nubia"; then
    ui_print "⚠ Warning: This module is designed for RedMagic devices."
    ui_print "  Your device brand: $(getprop ro.product.brand)"
    ui_print "  Continuing anyway..."
    ui_print ""
fi

# Check if GameAssist exists
if [ -d "/system/app/GameAssist" ]; then
    ui_print "  ✓ GameAssist found"
else
    ui_print "  ⚠ GameAssist not found — Game Space overlay may not work"
fi

# Check if GameSpace exists
if [ -d "/system/priv-app/GameSpace" ]; then
    ui_print "  ✓ GameSpace found"
else
    ui_print "  ⚠ GameSpace not found"
fi

# Remove any leftovers from previous versions
# v2.0.x used APK replacement which broke overlay permissions
rm -rf "$MODPATH/system/app/GameAssist" 2>/dev/null
rm -rf "$MODPATH/system/priv-app/GameSpace" 2>/dev/null
rm -rf "$MODPATH/system" 2>/dev/null
rm -rf "$MODPATH/zygisk" 2>/dev/null
rm -rf "$MODPATH/dex" 2>/dev/null

# ── Create config directory ────────────────────────────────────────
CONFDIR="/data/adb/game_space_unleashed"
mkdir -p "$CONFDIR"

# Write default config if it doesn't exist (preserve user settings on upgrade)
if [ ! -f "$CONFDIR/config.sh" ]; then
    cat > "$CONFDIR/config.sh" << 'EOF'
# Game Space Unleashed v3.0.0 — Configuration
# Edit via KSU WebUI or manually. Sourced by post-fs-data.sh and service.sh.

# GFRC: 1 = ALL games get Super Resolution + Frame Interpolation
# 0 = only games in /system/etc/gpp_app_list + custom_gpp_list
GFRC_ALL_GAMES=1

# Fix space_trigger for 6 plugins blocked on international ROMs
# (ai_tip, redmagic_broadcast, help, vibrate, game_prediction, chat_assit)
SPACE_TRIGGER_FIX=1

# Override plugin whitelists so ALL plugins show for ALL games
PLUGINS_ALL_GAMES=1
EOF
    ui_print "  ✓ Default config created"
else
    ui_print "  ✓ Existing config preserved (upgrade)"
fi

# Create empty custom game list if it doesn't exist
if [ ! -f "$CONFDIR/custom_gpp_list" ]; then
    cat > "$CONFDIR/custom_gpp_list" << 'EOF'
# Custom GFRC game list — one package per line
# Format: package_name,upscale(0/1/2),interp(0/1)
# Example: com.example.game,2,1
# Lines starting with # are ignored
EOF
fi

# Set permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
[ -d "$MODPATH/webroot" ] && set_perm_recursive "$MODPATH/webroot" 0 0 0755 0644

ui_print ""
ui_print "✓ Installation complete!"
ui_print ""
ui_print "→ Reboot to activate"
ui_print "→ KSU WebUI: open KernelSU → Modules → Game Space Unleashed"
ui_print "→ Diagnostic log: /sdcard/GSU_diagnostic.log"
ui_print "→ Config: /data/adb/game_space_unleashed/config.sh"
ui_print ""
