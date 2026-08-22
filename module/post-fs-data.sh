#!/system/bin/sh
# Game Space Unleashed by MsysteM — Early Boot
# v2.3.0: Minimal — vendor already sets all game feature props.
# Only set props that are missing or wrong.

MODDIR="${0%/*}"

# Force game voice feature on (vendor sets it false)
resetprop -n ro.vendor.feature.zte_feature_game_magic_voice true

# MFV window reply (may not be in vendor defaults)
resetprop -n ro.vendor.feature.mfv_feature_windowreply true
