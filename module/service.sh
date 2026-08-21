#!/system/bin/sh

# Game Space Unleashed by MsysteM
# service.sh - runs in late_start service mode

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/game_space_unleashed"

# Ensure config directory exists
[ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"

# Copy default config if missing
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cp "$MODDIR/config.json" "$CONFIG_DIR/config.json" 2>/dev/null
    chmod 644 "$CONFIG_DIR/config.json"
fi
