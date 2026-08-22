#!/system/bin/sh
# Game Space Unleashed v2.3.1 by MsysteM — Early Boot
# Runs BEFORE zygote starts. Uses resetprop to set/override ro.* properties.
# system.prop handles NEW properties; resetprop handles OVERRIDING existing ones.

MODDIR="${0%/*}"

# ====================================================================
# 1. Properties vendor DOESN'T set (empty) — need to exist before zygote
# ====================================================================

# Super Resolution feature gate — vendor leaves EMPTY
# Without this, Super Resolution plugin is hidden in all games
resetprop -n ro.vendor.feature.zte_feature_magic_super_resolution true

# Shoulder key → launch GameSpace — vendor leaves EMPTY
resetprop -n ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace true

# ====================================================================
# 2. Properties vendor sets WRONG
# ====================================================================

# Game magic voice — vendor sets false
resetprop -n ro.vendor.feature.zte_feature_game_magic_voice true

# MFV window reply
resetprop -n ro.vendor.feature.mfv_feature_windowreply true

# ====================================================================
# 3. Override gamespace_config — unlock ALL feature sections
#    Vendor sets: 0:1,1:1,2:0,3:1,4:0,5:0,6:1,...,e:0,f:0,g:1
#    Positions 2,4,5,e,f are DISABLED (0) — these gate feature sections
#    like framerate control, image quality options, etc.
#    Override ALL to 1 to unlock every feature section.
# ====================================================================
resetprop -n ro.vendor.feature.zte_feature_gamespace_config "0:1,1:1,2:1,3:1,4:1,5:1,6:1,7:1,8:1,9:1,a:1,b:1,c:1,d:1,e:1,f:1,g:1"
