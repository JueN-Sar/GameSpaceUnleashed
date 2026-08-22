#!/system/bin/sh
# Game Space Unleashed by MsysteM — Installation Script
# Property-only approach: no APK replacement, original apps stay intact

SKIPUNZIP=0

ui_print "╔══════════════════════════════════════╗"
ui_print "║   Game Space Unleashed by MsysteM    ║"
ui_print "║            v2.3.1                     ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""
ui_print "→ What's new in v2.3.1:"
ui_print "  ✓ Super Resolution property unlocked"
ui_print "  ✓ gamespace_config ALL flags enabled"
ui_print "  ✓ Translation + refreshrate whitelisted"
ui_print "  ✓ ALL plugins available for ALL games"
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

# Remove old Zygisk/DEX files from previous versions
rm -rf "$MODPATH/zygisk" 2>/dev/null
rm -rf "$MODPATH/dex" 2>/dev/null
rm -rf "$MODPATH/webroot" 2>/dev/null

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
ui_print ""
