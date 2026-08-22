#!/system/bin/sh
# Game Space Unleashed v3.0.0 by MsysteM — Uninstall cleanup

# Clean up config directory
rm -rf /data/adb/game_space_unleashed 2>/dev/null

# Remove diagnostic log
rm -f /sdcard/GSU_diagnostic.log 2>/dev/null

# Clear plugin whitelist overrides
WHITELISTED_PLUGINS="
hunting_mode ai_detect ai_tip vibrate game_prediction super_resolution
super_resolution_old combat_power keyposition_assist range_line sight_assist
pleased_display biablo_mode card_assist mora_ai_speaker gameshader
investigation_mode counter sensor_operation high_sensitivity_wheel sound_effect
screen_extraction ai_trigger chat_assit operation_devices redmagic_broadcast
voice_controller timer link_mics_translation refreshrate active_mode
"
for plugin in $WHITELISTED_PLUGINS; do
    settings delete global "game_assist_white_list_${plugin}" 2>/dev/null
    settings delete global "game_assist_black_list_${plugin}" 2>/dev/null
done

# Clear space_trigger overrides
for plugin in ai_tip redmagic_broadcast help vibrate game_prediction chat_assit; do
    settings delete global "game_assist_trigger_space_${plugin}" 2>/dev/null
done

# Note: resetprop overrides and system.prop entries are cleared on reboot
# (Magisk/KSU only applies them while module is active)
