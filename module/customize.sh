#!/system/bin/sh
# Game Space Unleashed by MsysteM — Installation Script
# Property-only approach: no APK replacement, original apps stay intact

SKIPUNZIP=0

ui_print "╔══════════════════════════════════════╗"
ui_print "║   Game Space Unleashed by MsysteM    ║"
ui_print "║            v2.3.0                     ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""
ui_print "→ Plugin whitelist override"
ui_print "  ✓ ALL plugins available for ALL games"
ui_print "  ✓ Plugin blacklists cleared"
ui_print "  ✓ GFRC runtime properties enabled"
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
    ui_print "  ✓ GameAssist found at /system/app/GameAssist"
else
    ui_print "  ⚠ GameAssist not found"
fi

# Check if GameSpace exists
if [ -d "/system/priv-app/GameSpace" ]; then
    ui_print "  ✓ GameSpace found at /system/priv-app/GameSpace"
else
    ui_print "  ⚠ GameSpace not found"
fi

# Remove any APK overlays from previous versions
# (v2.0.x used APK replacement which broke overlay permissions)
rm -rf "$MODPATH/system/app/GameAssist" 2>/dev/null
rm -rf "$MODPATH/system/priv-app/GameSpace" 2>/dev/null
rm -rf "$MODPATH/system" 2>/dev/null

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/post-fs-data.sh 0 0 0755

ui_print ""
ui_print "✓ Installation complete!"
ui_print "→ Reboot to activate."
ui_print "→ After reboot, open any game in Game Space"
ui_print "  and ALL features should be available!"
ui_print ""
ui_print "→ Diagnostic log: /sdcard/GSU_diagnostic.log"
ui_print "  (created after first boot with module active)"
ui_print ""
ui_print "v2.3.0: Plugin whitelists overridden for all games"
ui_print "  Fixed: sidebutton launcher (removed redundant props)"
ui_print "  Fixed: missing plugins in unsupported games"
ui_print ""
