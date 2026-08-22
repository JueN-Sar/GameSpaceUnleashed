#!/system/bin/sh
# Game Space Unleashed v3.0.1 by MsysteM — Boot Service
# Runs AFTER boot completes (sys.boot_completed=1).

MODDIR="${0%/*}"
LOG="/sdcard/GSU_diagnostic.log"

# Wait for boot
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 5

log -t "GSU" "Game Space Unleashed v3.0.1: Starting..."

# ====================================================================
# 1. Plugin whitelists — "." matches ALL package names via contains()
# ====================================================================

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
    settings put global "game_assist_white_list_${plugin}" "."
    settings put global "game_assist_black_list_${plugin}" ""
done
log -t "GSU" "Whitelists overridden for $(echo "$WHITELISTED_PLUGINS" | wc -w) plugins"

# ====================================================================
# 2. Enable ALL plugins
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
log -t "GSU" "Enabled $(echo "$ALL_PLUGINS" | wc -w) plugins"

# ====================================================================
# 3. space_trigger fix for international ROMs
#    Plugins with trigger=1 are BLOCKED on EU/Global (need bit 1 set)
#    Fix: set trigger=3 (bits 0+1) so they pass everywhere
# ====================================================================

TRIGGER_FIX_PLUGINS="
ai_tip
redmagic_broadcast
help
vibrate
game_prediction
chat_assit
"

for plugin in $TRIGGER_FIX_PLUGINS; do
    settings put global "game_assist_trigger_space_${plugin}" 3
done
log -t "GSU" "Fixed space_trigger for $(echo "$TRIGGER_FIX_PLUGINS" | wc -w) international-blocked plugins"

# ====================================================================
# 4. GFRC runtime properties
# ====================================================================

resetprop vendor.gpp.gfrc.upscale.ratio 1
resetprop vendor.gpp.gfrc.interp.rate 1
resetprop vendor.gpp.gfrc.enable 1
log -t "GSU" "GFRC runtime properties set"

# ====================================================================
# 5. GFRC mode for popular games
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
# 6. Diagnostic log
# ====================================================================

echo "=== Game Space Unleashed v3.0.1 ===" > "$LOG"
echo "Date: $(date)" >> "$LOG"
echo "Device: $(getprop ro.product.model) ($(getprop ro.product.brand))" >> "$LOG"
echo "ROM: $(getprop ro.build.display.id)" >> "$LOG"
echo "Android: $(getprop ro.build.version.release) SDK $(getprop ro.build.version.sdk)" >> "$LOG"
echo "Region: $(getprop ro.vendor.mifavor.custom)" >> "$LOG"
echo "" >> "$LOG"

echo "=== GFRC ===" >> "$LOG"
for prop in vendor.gpp.allgame.enable vendor.gpp.frc.enable vendor.gpp.gfrc.enable persist.vendor.gfrc.enable persist.magic.super.resolution; do
    echo "  $prop = $(getprop $prop)" >> "$LOG"
done

echo "" >> "$LOG"
echo "=== Feature Flags ===" >> "$LOG"
for prop in \
    ro.vendor.feature.zte_feature_gfrc \
    ro.vendor.feature.zte_feature_magic_super_resolution \
    ro.vendor.feature.zte_feature_gameassist_voice_controller \
    ro.vendor.feature.zte_feature_game_ai_tips \
    ro.vendor.feature.zte_feature_ai_game_prediction \
    ro.vendor.feature.zte_feature_game_sound_probe \
    ro.vendor.feature.zte_feature_low_sugar \
    ro.vendor.feature.zte_feature_game_ai_jarvis \
    ro.vendor.feature.zte_feature_game_magic_voice \
    ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace \
    ; do
    val=$(getprop "$prop")
    [ "$val" = "true" ] && echo "  ✓ $prop" >> "$LOG" || echo "  ✗ $prop = '$val'" >> "$LOG"
done

echo "" >> "$LOG"
echo "=== Plugin Whitelist Samples ===" >> "$LOG"
for plugin in super_resolution voice_controller ai_tip link_mics_translation; do
    echo "  $plugin = '$(settings get global game_assist_white_list_${plugin} 2>/dev/null)'" >> "$LOG"
done

log -t "GSU" "Diagnostic saved to $LOG"
log -t "GSU" "Game Space Unleashed v3.0.1: Done ✓"
