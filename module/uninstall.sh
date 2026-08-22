#!/system/bin/sh
# Game Space Unleashed v3.0.2 by MsysteM — Uninstall

# Clean up diagnostic log
rm -f /sdcard/GSU_diagnostic.log

# Reset plugin whitelists
WHITELISTED_PLUGINS="
hunting_mode ai_detect ai_tip vibrate game_prediction super_resolution
super_resolution_old combat_power keyposition_assist range_line sight_assist
pleased_display biablo_mode card_assist mora_ai_speaker gameshader
investigation_mode counter sensor_operation high_sensitivity_wheel
sound_effect screen_extraction ai_trigger chat_assit operation_devices
redmagic_broadcast voice_controller timer link_mics_translation
refreshrate active_mode
"

for plugin in $WHITELISTED_PLUGINS; do
    settings delete global "game_assist_white_list_${plugin}" 2>/dev/null
    settings delete global "game_assist_black_list_${plugin}" 2>/dev/null
done

# Reset plugin enable flags
ALL_PLUGINS="
super_resolution super_resolution_old ai_trigger ai_detect ai_tip
biablo_mode card_assist chat_assit combat_power counter custome_sort
fan game_prediction gameshader high_sensitivity_wheel hunting_mode
investigation_mode keyposition_assist mora_ai_speaker operation_devices
pleased_display range_line redmagic_broadcast screen_extraction
sensor_operation sight_assist sound_effect timer vibrate voice_controller
active_mode afk barrage_message charge_separation clean competition_light
dock game_benefit game_bilibili game_browser game_custom game_douyin
game_kuaishou game_qq game_reminder game_wechat handle help image_search
keylink link_mics_translation liquid_cool low_sugar manual_record
mis_operate multi_sub_screen noti performance_monitor quit record
refreshrate rotaton_lock small_window snap tel virtual_handle voice
whatsapp wifi wifidisplay
"

for plugin in $ALL_PLUGINS; do
    settings delete global "game_assist_enable_plugin_${plugin}" 2>/dev/null
done

# Reset space_trigger fixes
TRIGGER_FIX="ai_tip redmagic_broadcast help vibrate game_prediction chat_assit"
for plugin in $TRIGGER_FIX; do
    settings delete global "game_assist_trigger_space_${plugin}" 2>/dev/null
done

# Reset GFRC game mode
settings delete global game_gfrc_mode 2>/dev/null

log -t "GSU" "Game Space Unleashed: Uninstalled — settings cleaned"
