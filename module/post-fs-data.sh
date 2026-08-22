#!/system/bin/sh
# Game Space Unleashed v3.0.2 by MsysteM — Early Boot
# Runs BEFORE zygote starts. Uses resetprop to set/override ro.* properties.

MODDIR="${0%/*}"

# ── GFRC bypass — ALL games get max Super Resolution + Frame Interpolation ──
resetprop -n vendor.gpp.allgame.enable 1
resetprop -n vendor.gpp.frc.enable 0x22
resetprop -n vendor.gpp.dynamic.settings.enable 1

# ── Feature gates the vendor leaves EMPTY or sets wrong ──
resetprop -n ro.vendor.feature.zte_feature_magic_super_resolution true
resetprop -n ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace true
resetprop -n ro.vendor.feature.zte_feature_game_magic_voice true
resetprop -n ro.vendor.feature.mfv_feature_windowreply true

# ── Utils.d() plugin gate overrides — unlock ALL plugins ──
resetprop -n ro.vendor.feature.zte_feature_gameassist_voice_controller true
resetprop -n ro.vendor.feature.zte_feature_game_ai_tips true
resetprop -n ro.vendor.feature.zte_feature_ai_game_prediction true
resetprop -n ro.vendor.feature.zte_feature_game_sound_probe true
resetprop -n ro.vendor.feature.zte_feature_low_sugar true
resetprop -n ro.vendor.feature.zte_feature_game_ai_jarvis true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_data_panel true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_redmagic_broadcast true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_redmagic_elvesaid true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_chat_assist true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_biablo true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_fixedlook true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_ai_trigger true
resetprop -n ro.vendor.feature.zte_feature_gameassist_plugin_card_assist true
resetprop -n ro.vendor.feature.zte_feature_gameassist_audio_equalizer true
resetprop -n ro.vendor.feature.zte_feature_ai_speaker true
resetprop -n ro.vendor.feature.zte_feature_game_plugin_counter true

# ── gamespace_config — unlock ALL feature sections ──
resetprop -n ro.vendor.feature.zte_feature_gamespace_config "0:1,1:1,2:1,3:1,4:1,5:1,6:1,7:1,8:1,9:1,a:1,b:1,c:1,d:1,e:1,f:1,g:1"
