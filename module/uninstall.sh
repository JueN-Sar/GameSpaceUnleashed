#!/system/bin/sh
# Game Space Unleashed by MsysteM — Uninstall cleanup

# Clean up config directory
rm -rf /data/adb/game_space_unleashed 2>/dev/null

# Remove diagnostic log
rm -f /sdcard/GSU_diagnostic.log 2>/dev/null

# Note: Settings.Global entries and resetprop overrides are cleared on reboot
# (Magisk only applies them while module is active)
