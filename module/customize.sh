#!/system/bin/sh

SKIPUNZIP=1

ui_print "================================================"
ui_print "   Game Space Unleashed by MsysteM"
ui_print "   Unlock Super Resolution for ALL games"
ui_print "   No LSPosed required - Zygisk powered"
ui_print "================================================"

# Check architecture
ARCH=$(getprop ro.product.cpu.abi)
if [ "$ARCH" != "arm64-v8a" ]; then
    abort "! Unsupported architecture: $ARCH (arm64-v8a required)"
fi

# Check Zygisk (Magisk built-in or ReZygisk)
if [ ! -d "/data/adb/modules/zygisksu" ] && [ ! -d "/data/adb/modules/rezygisk" ] && \
   [ "$(magisk --path 2>/dev/null)" != "" ]; then
    # Check if Magisk has Zygisk enabled
    ZYGISK_ENABLED=$(magisk --sqlite "SELECT value FROM settings WHERE key='zygisk'" 2>/dev/null | grep -o '[0-9]*')
    if [ "$ZYGISK_ENABLED" != "1" ]; then
        ui_print "! Warning: Zygisk may not be enabled"
        ui_print "! Make sure Zygisk or ReZygisk is active"
    fi
fi

ui_print "- Extracting module files..."

# Create module directories
mkdir -p "$MODPATH/zygisk"
mkdir -p "$MODPATH/webroot"
mkdir -p "$MODPATH/dex"

# Extract all files
unzip -o "$ZIPFILE" module.prop -d "$MODPATH" >&2
unzip -o "$ZIPFILE" service.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" post-fs-data.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" uninstall.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'webroot/*' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'zygisk/*' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'dex/*' -d "$MODPATH" >&2

# Install default config if not present
CONFIG_PATH="/data/adb/game_space_unleashed"
if [ ! -f "$CONFIG_PATH/config.json" ]; then
    ui_print "- Installing default configuration..."
    mkdir -p "$CONFIG_PATH"
    unzip -o "$ZIPFILE" config.json -d "$CONFIG_PATH" >&2
    chmod 644 "$CONFIG_PATH/config.json"
fi
chmod 755 "$CONFIG_PATH"

# Set permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
[ -f "$MODPATH/zygisk/arm64-v8a.so" ] && set_perm "$MODPATH/zygisk/arm64-v8a.so" 0 0 0644

ui_print ""
ui_print "- Installation complete!"
ui_print "- Open KsuWebUI to configure features"
ui_print "- Reboot to activate hooks"
ui_print ""
