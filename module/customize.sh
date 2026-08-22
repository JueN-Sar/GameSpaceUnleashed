#!/system/bin/sh
# Game Space Unleashed v3.0.0 by MsysteM — Installer

SKIPUNZIP=1

ui_print ""
ui_print "  ╔══════════════════════════════════════════╗"
ui_print "  ║                                          ║"
ui_print "  ║   🎮  Game Space Unleashed  🎮           ║"
ui_print "  ║        by MsysteM — v3.0.0               ║"
ui_print "  ║                                          ║"
ui_print "  ╚══════════════════════════════════════════╝"
ui_print ""

# ── Device check ──
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
ANDROID=$(getprop ro.build.version.release)
ROM=$(getprop ro.build.display.id)

ui_print "  📱 Device: $BRAND $MODEL"
ui_print "  🤖 Android: $ANDROID"
ui_print "  💿 ROM: $ROM"
ui_print ""

# ── Architecture check ──
ARCH=$(getprop ro.product.cpu.abi)
if [ "$ARCH" != "arm64-v8a" ]; then
    abort "  ❌ Unsupported architecture: $ARCH (arm64-v8a required)"
fi
ui_print "  ✅ Architecture: $ARCH"

# ── Extract files ──
ui_print ""
ui_print "  📦 Installing module files..."

unzip -o "$ZIPFILE" module.prop -d "$MODPATH" >&2
unzip -o "$ZIPFILE" system.prop -d "$MODPATH" >&2
unzip -o "$ZIPFILE" service.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" post-fs-data.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" uninstall.sh -d "$MODPATH" >&2

ui_print "  ✅ Module files extracted"

# ── Set permissions ──
ui_print "  🔒 Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
ui_print "  ✅ Permissions set"

# ── Done ──
ui_print ""
ui_print "  ╔══════════════════════════════════════════╗"
ui_print "  ║  🚀 Installation Complete!               ║"
ui_print "  ║                                          ║"
ui_print "  ║  ⚡ GFRC — Super Resolution for ALL      ║"
ui_print "  ║  🔓 ALL plugins unlocked                 ║"
ui_print "  ║  🌍 International ROM fix applied        ║"
ui_print "  ║  🤖 AI features enabled                  ║"
ui_print "  ║                                          ║"
ui_print "  ║  🔄 Reboot to activate                   ║"
ui_print "  ╚══════════════════════════════════════════╝"
ui_print ""
