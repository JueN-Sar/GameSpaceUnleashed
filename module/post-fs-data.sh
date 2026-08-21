#!/system/bin/sh

# Game Space Unleashed by MsysteM
# post-fs-data.sh - runs before Zygote starts

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/game_space_unleashed"

# Ensure config exists before Zygote needs it
[ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cp "$MODDIR/config.json" "$CONFIG_DIR/config.json" 2>/dev/null
    chmod 644 "$CONFIG_DIR/config.json"
fi
