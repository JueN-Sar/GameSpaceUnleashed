#!/system/bin/sh
# Game Space Unleashed v2.3.1 by MsysteM — Boot Service
# Properties are handled by system.prop + post-fs-data.sh
# This script handles:
#   1. Override plugin whitelists so ALL plugins show for ALL games
#   2. Clear plugin blacklists
#   3. GFRC runtime properties
#   4. Diagnostic logging

MODDIR="${0%/*}"
LOG="/sdcard/GSU_diagnostic.log"

# Wait for boot to complete (Settings.Global requires system_server)
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 5

log -t "GSU" "Game Space Unleashed v2.3.1: Starting post-boot setup..."

# ====================================================================
# 1. Override plugin whitelists — make ALL plugins available in ALL games
#    PluginConfig reads: Settings.Global["game_assist_white_list_{name}"]
#    The matching code uses String.contains() — so "." matches every
#    package name (they all contain dots: com.example.game)
#    Setting whitelist to "." = universal match = show for all games
# ====================================================================

# Plugins that have restrictive whitelists in the APK's XML
# (only show for specific games by default)
WHITELISTED_PLUGINS="
hunting_mode
ai_detect
ai_tip
vibrate
game_prediction
super_resolution
super_resolution_old
combat_power
keyposition_assist
range_line
sight_assist
pleased_display
biablo_mode
card_assist
mora_ai_speaker
gameshader
investigation_mode
counter
sensor_operation
high_sensitivity_wheel
sound_effect
screen_extraction
ai_trigger
chat_assit
operation_devices
redmagic_broadcast
voice_controller
timer
link_mics_translation
refreshrate
active_mode
"

for plugin in $WHITELISTED_PLUGINS; do
    # Set whitelist to "." — matches ALL package names
    settings put global "game_assist_white_list_${plugin}" "."
    # Clear any blacklist
    settings put global "game_assist_black_list_${plugin}" ""
done
log -t "GSU" "Overrode whitelists for $(echo "$WHITELISTED_PLUGINS" | wc -w) plugins (all games)"

# ====================================================================
# 2. Enable ALL plugins via Settings.Global (belt and suspenders)
#    PluginConfig.k() reads: Settings.Global["game_assist_enable_plugin_{name}"]
#    Default is 1 (enabled), but set explicitly to be safe
# ====================================================================

ALL_PLUGINS="
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

for plugin in $ALL_PLUGINS; do
    settings put global "game_assist_enable_plugin_${plugin}" 1
done
log -t "GSU" "Enabled $(echo "$ALL_PLUGINS" | wc -w) plugins via Settings.Global"

# ====================================================================
# 3. GFRC (Game Frame Rate Control / R3 Chip) runtime properties
# ====================================================================

resetprop vendor.gpp.gfrc.upscale.ratio 1
resetprop vendor.gpp.gfrc.interp.rate 1
resetprop vendor.gpp.gfrc.enable 1
log -t "GSU" "R3 chip GFRC runtime properties set"

# ====================================================================
# 4. Enable GFRC mode for popular games via Settings.Global
# ====================================================================

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

# ====================================================================
# 5. Diagnostic dump — saves to /sdcard/GSU_diagnostic.log
# ====================================================================

echo "=== Game Space Unleashed v2.3.1 Diagnostic ===" > "$LOG"
echo "Date: $(date)" >> "$LOG"
echo "Device: $(getprop ro.product.model) ($(getprop ro.product.brand))" >> "$LOG"
echo "Android: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))" >> "$LOG"
echo "ROM: $(getprop ro.build.display.id)" >> "$LOG"
echo "" >> "$LOG"

# Check critical properties
echo "=== Critical ZTE Feature Properties ===" >> "$LOG"
CRITICAL_PROPS="
ro.vendor.feature.zte_feature_red_magic
ro.vendor.feature.zte_feature_red_magic_phone
ro.vendor.feature.zte_feature_magic_game_assist
ro.vendor.feature.zte_feature_gfrc
ro.vendor.feature.zte_feature_magic_super_resolution
ro.vendor.feature.zte_feature_side_shortcut_key
ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace
ro.vendor.feature.zte_feature_game_fan
ro.vendor.feature.zte_feature_game_magic_voice
ro.vendor.feature.mfv_feature_windowreply
"
for prop in $CRITICAL_PROPS; do
    val=$(getprop "$prop")
    if [ "$val" = "true" ]; then
        echo "  ✓ $prop = $val" >> "$LOG"
    else
        echo "  ✗ $prop = '$val' (EXPECTED 'true')" >> "$LOG"
    fi
done

echo "" >> "$LOG"
echo "=== gamespace_config (should all be :1) ===" >> "$LOG"
gs_config=$(getprop ro.vendor.feature.zte_feature_gamespace_config)
echo "  Value: ${gs_config}" >> "$LOG"
if echo "$gs_config" | grep -q ':0'; then
    echo "  ⚠ Some flags still disabled!" >> "$LOG"
else
    echo "  ✓ All flags enabled" >> "$LOG"
fi

echo "" >> "$LOG"
echo "=== Plugin Whitelist Overrides (should all be '.') ===" >> "$LOG"
for plugin in hunting_mode ai_detect ai_tip vibrate game_prediction super_resolution refreshrate link_mics_translation active_mode; do
    val=$(settings get global "game_assist_white_list_${plugin}" 2>/dev/null)
    echo "  game_assist_white_list_${plugin} = '${val}'" >> "$LOG"
done

echo "" >> "$LOG"
echo "=== App Installation ===" >> "$LOG"
if [ -d "/system/app/GameAssist" ]; then
    echo "  ✓ GameAssist: /system/app/GameAssist" >> "$LOG"
else
    echo "  ✗ GameAssist NOT found" >> "$LOG"
fi
if [ -d "/system/priv-app/GameSpace" ]; then
    echo "  ✓ GameSpace: /system/priv-app/GameSpace" >> "$LOG"
else
    echo "  ✗ GameSpace NOT found" >> "$LOG"
fi

echo "" >> "$LOG"
echo "=== Settings.Global (GFRC) ===" >> "$LOG"
gfrc_val=$(settings get global game_gfrc_mode 2>/dev/null)
echo "  game_gfrc_mode = ${gfrc_val:-'(not set)'}" >> "$LOG"

echo "" >> "$LOG"
echo "=== v2.3.1 Changes ===" >> "$LOG"
echo "  - Added: zte_feature_magic_super_resolution = true (was EMPTY)" >> "$LOG"
echo "  - Added: zte_feature_shoulder_key_launch_gamespace = true (was EMPTY)" >> "$LOG"
echo "  - Override: gamespace_config all flags → 1 (was 2:0,4:0,5:0,e:0,f:0)" >> "$LOG"
echo "  - Added: link_mics_translation, refreshrate, active_mode to whitelist" >> "$LOG"

log -t "GSU" "Diagnostic saved to $LOG"
log -t "GSU" "Game Space Unleashed v2.3.1: Setup complete! ✓"
