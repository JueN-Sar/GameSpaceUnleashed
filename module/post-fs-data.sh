#!/system/bin/sh
# Game Space Unleashed by MsysteM — Early Boot Property Override
# Runs BEFORE zygote starts — ensures properties are set before any app reads them
# system.prop handles most properties, this is a safety net for ro.* overrides

MODDIR="${0%/*}"

# resetprop -n = no-trigger (don't notify property service, faster for bulk sets)
# This ensures read-only properties are overridden even if already set by vendor

# Core identity — must be set before GameAssist/GameSpace <clinit>()
resetprop -n ro.vendor.feature.zte_feature_red_magic true
resetprop -n ro.vendor.feature.zte_feature_red_magic_phone true
resetprop -n ro.vendor.feature.zte_feature_magic_game_assist true

# GFRC / R3 chip — must be set before GameAssist starts
resetprop -n ro.vendor.feature.zte_feature_gfrc true
resetprop -n ro.vendor.feature.zte_feature_magic_super_resolution true
resetprop -n ro.vendor.feature.zte_feature_superior_quality_game true

# Hardware features — read early by Constants.<clinit>()
resetprop -n ro.vendor.feature.zte_feature_side_shortcut_key true
resetprop -n ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace true
resetprop -n ro.vendor.feature.zte_feature_game_fan true
resetprop -n ro.vendor.feature.zte_feature_liquid_cooling true
resetprop -n ro.vendor.feature.zte_feature_support_charge_separation true
resetprop -n ro.vendor.feature.zte_feature_bypass_charge_separation true

# Controls — cached in ZteFeatureWrapper.<clinit>()
resetprop -n ro.vendor.feature.zte_feature_redmagic_touch_gamekey true
resetprop -n ro.vendor.feature.zte_feature_redmagic_sports_handle true
resetprop -n ro.vendor.feature.zte_feature_redmagic_x_gravity_gamepad true
resetprop -n ro.vendor.feature.zte_feature_screen_key_map true
resetprop -n ro.vendor.feature.zte_feature_key_mouse_map true

# Overlay tiles — gated by TilesUtil.f() filter
resetprop -n ro.vendor.feature.zte_feature_colorful_light true
resetprop -n ro.vendor.feature.zte_feature_low_sugar true
resetprop -n ro.vendor.feature.zte_feature_multi_sub_screen true
resetprop -n ro.vendor.feature.zte_feature_magic_virtual_handle true
resetprop -n ro.vendor.feature.zte_feature_anti_misoperate_nubia true
resetprop -n ro.vendor.feature.zte_feature_windowreply_entrance_display true
resetprop -n ro.vendor.feature.mfv_feature_windowreply true

# Game Center settings accessibility
resetprop -n ro.vendor.feature.zte_feature_gamespace_config true
resetprop -n ro.vendor.feature.zte_feature_game_center_menu true
resetprop -n ro.vendor.feature.zte_feature_game_center_mode_settings true
resetprop -n ro.vendor.feature.zte_feature_game_center_net true
resetprop -n ro.vendor.feature.zte_feature_game_center_not_disturb true
resetprop -n ro.vendor.feature.zte_feature_game_center_other_options true
resetprop -n ro.vendor.feature.zte_feature_game_center_screen_settings true
resetprop -n ro.vendor.feature.zte_feature_game_center_streaming true
resetprop -n ro.vendor.feature.zte_feature_game_center_flase_touch true
resetprop -n ro.vendor.feature.zte_feature_game_center_zte_flase_touch true
resetprop -n ro.vendor.feature.zte_feature_game_center_race_key_off true
resetprop -n ro.vendor.feature.zte_feature_game_center_about true
resetprop -n ro.vendor.feature.zte_feature_game_controlpanel_menu true
resetprop -n ro.vendor.feature.zte_feature_game_controlpanel_adjust_operation true
