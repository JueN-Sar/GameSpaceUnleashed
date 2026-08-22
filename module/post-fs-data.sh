#!/system/bin/sh
# Game Space Unleashed v3.0.0 by MsysteM — Early Boot
# Runs BEFORE zygote starts. Uses resetprop to set/override ro.* properties.

MODDIR="${0%/*}"
CONFDIR="/data/adb/game_space_unleashed"

# ====================================================================
# 1. GFRC — The key breakthrough: vendor.gpp.allgame.enable
# ====================================================================

# Read config — default is ALL games enabled
GFRC_ALL_GAMES=1
[ -f "$CONFDIR/config.sh" ] && . "$CONFDIR/config.sh"

if [ "$GFRC_ALL_GAMES" = "1" ]; then
    resetprop -n vendor.gpp.allgame.enable 1
else
    resetprop -n vendor.gpp.allgame.enable 0
fi

# Master GFRC enable
resetprop -n vendor.gpp.frc.enable 0x22
resetprop -n vendor.gpp.dynamic.settings.enable 1

# ====================================================================
# 2. Properties vendor DOESN'T set (empty) — need to exist before zygote
# ====================================================================

resetprop -n ro.vendor.feature.zte_feature_magic_super_resolution true
resetprop -n ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace true

# ====================================================================
# 3. Properties vendor sets WRONG
# ====================================================================

resetprop -n ro.vendor.feature.zte_feature_game_magic_voice true
resetprop -n ro.vendor.feature.mfv_feature_windowreply true

# ====================================================================
# 4. Override gamespace_config — unlock ALL feature sections
# ====================================================================
resetprop -n ro.vendor.feature.zte_feature_gamespace_config "0:1,1:1,2:1,3:1,4:1,5:1,6:1,7:1,8:1,9:1,a:1,b:1,c:1,d:1,e:1,f:1,g:1"
