#!/system/bin/sh
# Game Space Unleashed by MsysteM — Boot Service
# Unlocks ALL Game Space features via system properties + Settings.Global
# NO APK replacement — original apps stay intact with platform signature

MODDIR="${0%/*}"

# Wait for boot to complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 3

log -t "GSU" "Game Space Unleashed: Starting feature unlock..."

# ====================================================================
# 1. ZTE Feature Flags — set via system properties
#    com.zte.feature.Feature.getBoolean("ZTE_FEATURE_X") reads from
#    ro.vendor.feature.zte_feature_x (lowercase)
# ====================================================================

ZTE_FEATURES="
zte_feature_red_magic
zte_feature_red_magic_phone
zte_feature_magic_game_assist
zte_feature_magic_super_resolution
zte_feature_superior_quality_game
zte_feature_gfrc
zte_feature_gameassist_plugin_ai_trigger
zte_feature_gameassist_plugin_biablo
zte_feature_gameassist_plugin_card_assist
zte_feature_gameassist_plugin_chat_assist
zte_feature_gameassist_plugin_data_panel
zte_feature_gameassist_plugin_fixedlook
zte_feature_gameassist_plugin_game_ratio
zte_feature_gameassist_plugin_4d_vibrate
zte_feature_gameassist_plugin_ai_gamenotes
zte_feature_gameassist_plugin_mode_card
zte_feature_gameassist_plugin_operation_devices
zte_feature_gameassist_plugin_redmagic_broadcast
zte_feature_gameassist_plugin_redmagic_elvesaid
zte_feature_gameassist_plugin_sort
zte_feature_gameassist_audio_equalizer
zte_feature_gameassist_global_search
zte_feature_gameassist_one_key_link
zte_feature_gameassist_support_demi
zte_feature_gameassist_voice_controller
zte_feature_game_ai_jarvis
zte_feature_game_ai_tips
zte_feature_game_display_filter_effect
zte_feature_game_dts_eq_float
zte_feature_game_fan
zte_feature_game_neo_translate
zte_feature_game_plugin_counter
zte_feature_game_random_record
zte_feature_game_sound_probe
zte_feature_game_strategy_station
zte_feature_game_voice_assist
zte_feature_game_voice_assist_v2
zte_feature_ai_game_prediction
zte_feature_ai_speaker
zte_feature_ai_translation
zte_feature_anti_misoperate_nubia
zte_feature_bend_indecate
zte_feature_bypass_charge_separation
zte_feature_camerakey_virtual_touch
zte_feature_colorful_light
zte_feature_display_magic_detach_enable
zte_feature_expand_projection_screen
zte_feature_expand_projection_screen_3d_touchpanel
zte_feature_expand_projection_screen_freeform
zte_feature_gameaiasst
zte_feature_gameaiasst_abroad
zte_feature_host_performance_monitor
zte_feature_keymap_sensitivity_wheel_disc
zte_feature_key_mouse_map
zte_feature_learned_behavior_x_gravity
zte_feature_low_sugar
zte_feature_magic_game_screen_saver
zte_feature_magic_resolutions_settings
zte_feature_magic_virtual_handle
zte_feature_mini_programe_add_gamespace
zte_feature_mirror_projection_screen
zte_feature_mtgpa_predownload
zte_feature_multi_sub_screen
zte_feature_neo_game_lib
zte_feature_package_plugin_vibrate
zte_feature_redmagic_gamekey
zte_feature_redmagic_game_latency_data_switch
zte_feature_redmagic_sports_handle
zte_feature_redmagic_touch_gamekey
zte_feature_redmagic_touch_gamekey_support_portrait
zte_feature_redmagic_x_gravity_gamepad
zte_feature_refresh_rate_lite_option_mode
zte_feature_screen_key_map
zte_feature_sensor_operation_touch
zte_feature_stream_game
zte_feature_support_charge_separation
zte_feature_windowreply_entrance_display
zte_feature_zperf_cube_gpsetting_enabled
zte_feature_leia_3d_uart
zte_feature_shoulder_key_launch_gamespace
zte_feature_side_shortcut_key
zte_feature_display_magic
zte_feature_base_game_plugin_game
zte_feature_game_center_menu
zte_feature_game_center_mode_settings
zte_feature_game_center_net
zte_feature_game_center_not_disturb
zte_feature_game_center_other_options
zte_feature_game_center_screen_settings
zte_feature_game_center_streaming
zte_feature_game_center_flase_touch
zte_feature_game_center_zte_flase_touch
zte_feature_game_center_race_key_off
zte_feature_game_center_about
zte_feature_game_controlpanel_menu
zte_feature_game_controlpanel_adjust_operation
zte_feature_game_high_lights
zte_feature_game_precision_control
zte_feature_gamespace_config
zte_feature_planet_agent
zte_feature_planet_mora
zte_feature_planet_resource_lib
zte_feature_planet_video_banner
zte_feature_redmagic_aikey
zte_feature_redmagic_pc_game
zte_feature_lobby_score_record
zte_feature_liquid_cooling
zte_feature_magic_resolutions
zte_feature_manual_record_only
zte_feature_tp_game_partition
zte_feature_support_mipmap_lod
zte_feature_use_gpu_driver_update
zte_feature_sar_control_4
"

for feature in $ZTE_FEATURES; do
    resetprop "ro.vendor.feature.${feature}" "true"
done
log -t "GSU" "Set $(echo "$ZTE_FEATURES" | wc -w) ZTE feature properties to true"

# ====================================================================
# 2. Enable GFRC (Game Frame Rate Control / R3 Chip) hardware features
# ====================================================================
resetprop vendor.gpp.gfrc.upscale.ratio 1
resetprop vendor.gpp.gfrc.interp.rate 1
resetprop persist.magic.super.resolution 1
resetprop persist.vendor.gfrc.enable 1
resetprop vendor.gpp.gfrc.enable 1
log -t "GSU" "R3 chip properties set"

# ====================================================================
# 3. Enable ALL plugins via Settings.Global
#    PluginConfig.k() reads: Settings.Global["game_assist_enable_plugin_{name}"]
#    Value 1 = enabled
# ====================================================================

PLUGINS="
super_resolution
super_resolution_old
ai_trigger
ai_detect
ai_tip
biablo_mode
card_assist
chat_assit
combat_power
counter
custome_sort
fan
game_prediction
gameshader
high_sensitivity_wheel
hunting_mode
investigation_mode
keyposition_assist
mora_ai_speaker
operation_devices
pleased_display
range_line
redmagic_broadcast
screen_extraction
sensor_operation
sight_assist
sound_effect
timer
vibrate
voice_controller
active_mode
afk
barrage_message
charge_separation
clean
competition_light
dock
game_benefit
game_bilibili
game_browser
game_custom
game_douyin
game_kuaishou
game_qq
game_reminder
game_wechat
handle
help
image_search
keylink
link_mics_translation
liquid_cool
low_sugar
manual_record
mis_operate
multi_sub_screen
noti
performance_monitor
quit
record
refreshrate
rotaton_lock
small_window
snap
tel
virtual_handle
voice
whatsapp
wifi
wifidisplay
"

for plugin in $PLUGINS; do
    settings put global "game_assist_enable_plugin_${plugin}" 1
done
log -t "GSU" "Enabled $(echo "$PLUGINS" | wc -w) plugins via Settings.Global"

# ====================================================================
# 4. Enable GFRC mode for all running games via Settings.Global
#    Format: "pkg+XYZ" where X=image quality, Y=frame rate, Z=master switch
#    Value "111" = all enabled
# ====================================================================

# Set a wildcard-style entry to enable for common games
GFRC_PACKAGES="
com.miHoYo.Yuanshen
com.miHoYo.GenshinImpact
com.tencent.tmgp.pubgmhd
com.tencent.ig
com.tencent.tmgp.sgame
com.tencent.tmgp.cf
com.tencent.af
com.garena.game.kg
com.netease.hyxd
com.netease.ko
com.activision.callofduty.shooter
com.supercell.clashofclans
com.supercell.brawlstars
com.epicgames.fortnite
com.riotgames.league.wildrift
com.riotgames.league.teamfighttactics
com.mobile.legends
"

GFRC_VALUE=""
for pkg in $GFRC_PACKAGES; do
    if [ -n "$GFRC_VALUE" ]; then
        GFRC_VALUE="${GFRC_VALUE},${pkg}+111"
    else
        GFRC_VALUE="${pkg}+111"
    fi
done
settings put global game_gfrc_mode "$GFRC_VALUE"
log -t "GSU" "Set GFRC mode for $(echo "$GFRC_PACKAGES" | wc -w) games"

log -t "GSU" "Game Space Unleashed: All features unlocked! ✓"
