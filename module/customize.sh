#!/system/bin/sh
# Game Space Unleashed by MsysteM — Installation Script

SKIPUNZIP=0

ui_print "╔══════════════════════════════════════╗"
ui_print "║   Game Space Unleashed by MsysteM    ║"
ui_print "║            v2.0.0                     ║"
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

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/system 0 0 0755 0644

ui_print ""
ui_print "✓ Installation complete!"
ui_print "→ Reboot to activate."
ui_print "→ After reboot, open any game in Game Space"
ui_print "  and ALL features will be available!"
ui_print ""
