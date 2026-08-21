#!/system/bin/sh
# Game Space Unleashed v2.2.0 by MsysteM — Boot Service
# Properties are set in system.prop + post-fs-data.sh (BEFORE zygote)
# This script handles: GFRC runtime props, Settings.Global, diagnostics

MODDIR="${0%/*}"
LOG="/sdcard/GSU_diagnostic.log"

# Wait for boot to complete (Settings.Global requires system_server)
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 5

log -t "GSU" "Game Space Unleashed v2.2.0: Starting post-boot setup..."

# ====================================================================
# 1. Diagnostic dump — saves to /sdcard/GSU_diagnostic.log
#    Flash the module, reboot, check this file to verify features
# ====================================================================

echo "=== Game Space Unleashed v2.2.0 Diagnostic ===" > "$LOG"
echo "Date: $(date)" >> "$LOG"
echo "Device: $(getprop ro.product.model) ($(getprop ro.product.brand))" >> "$LOG"
echo "Android: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))" >> "$LOG"
echo "ROM: $(getprop ro.build.display.id)" >> "$LOG"
echo "" >> "$LOG"

# Check if our properties are actually set
echo "=== ZTE Feature Properties (should all be 'true') ===" >> "$LOG"
CRITICAL_PROPS="
ro.vendor.feature.zte_feature_red_magic
ro.vendor.feature.zte_feature_red_magic_phone
ro.vendor.feature.zte_feature_magic_game_assist
ro.vendor.feature.zte_feature_gfrc
ro.vendor.feature.zte_feature_magic_super_resolution
ro.vendor.feature.zte_feature_gamespace_config
ro.vendor.feature.zte_feature_side_shortcut_key
ro.vendor.feature.zte_feature_shoulder_key_launch_gamespace
ro.vendor.feature.zte_feature_game_fan
ro.vendor.feature.zte_feature_colorful_light
ro.vendor.feature.zte_feature_low_sugar
ro.vendor.feature.zte_feature_multi_sub_screen
ro.vendor.feature.zte_feature_magic_virtual_handle
ro.vendor.feature.zte_feature_windowreply_entrance_display
ro.vendor.feature.mfv_feature_windowreply
ro.vendor.feature.zte_feature_redmagic_touch_gamekey
ro.vendor.feature.zte_feature_screen_key_map
ro.vendor.feature.zte_feature_key_mouse_map
ro.vendor.feature.zte_feature_game_center_menu
ro.vendor.feature.zte_feature_game_center_other_options
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
echo "=== All ro.vendor.feature.zte_feature_* properties ===" >> "$LOG"
getprop | grep "ro.vendor.feature.zte_feature" >> "$LOG" 2>/dev/null
echo "" >> "$LOG"

# Search for ZTE feature config files
echo "=== ZTE Feature Config Files ===" >> "$LOG"
for dir in /system/etc /vendor/etc /product/etc /my_product/etc /odm/etc /system_ext/etc; do
    if [ -d "$dir" ]; then
        found=$(find "$dir" -maxdepth 3 -name "*feature*" -o -name "*Feature*" 2>/dev/null)
        if [ -n "$found" ]; then
            echo "  Found in $dir:" >> "$LOG"
            echo "$found" | while read f; do
                echo "    $f ($(ls -la "$f" 2>/dev/null | awk '{print $5}') bytes)" >> "$LOG"
            done
        fi
    fi
done
echo "" >> "$LOG"

# Check GameAssist/GameSpace installation
echo "=== App Installation ===" >> "$LOG"
if [ -d "/system/app/GameAssist" ]; then
    echo "  ✓ GameAssist: /system/app/GameAssist" >> "$LOG"
    ls -la /system/app/GameAssist/*.apk >> "$LOG" 2>/dev/null
else
    echo "  ✗ GameAssist NOT found at /system/app/GameAssist" >> "$LOG"
fi
if [ -d "/system/priv-app/GameSpace" ]; then
    echo "  ✓ GameSpace: /system/priv-app/GameSpace" >> "$LOG"
    ls -la /system/priv-app/GameSpace/*.apk >> "$LOG" 2>/dev/null
else
    echo "  ✗ GameSpace NOT found at /system/priv-app/GameSpace" >> "$LOG"
fi
echo "" >> "$LOG"

# Dump ZTE framework info
echo "=== ZTE Framework ===" >> "$LOG"
for jar in /system/framework/*zte* /system/framework/*nubia* /system/framework/*feature*; do
    if [ -f "$jar" ]; then
        echo "  Found: $jar ($(ls -la "$jar" | awk '{print $5}') bytes)" >> "$LOG"
    fi
done
echo "" >> "$LOG"

log -t "GSU" "Diagnostic saved to $LOG"

# ====================================================================
# 2. GFRC (Game Frame Rate Control / R3 Chip) runtime properties
#    These are non-ro. properties that can be set at any time
# ====================================================================

resetprop vendor.gpp.gfrc.upscale.ratio 1
resetprop vendor.gpp.gfrc.interp.rate 1
resetprop persist.magic.super.resolution 1
resetprop persist.vendor.gfrc.enable 1
resetprop vendor.gpp.gfrc.enable 1
log -t "GSU" "R3 chip GFRC runtime properties set"

# ====================================================================
# 3. Enable GFRC mode for popular games via Settings.Global
#    Format: "pkg+XYZ" where X=image quality, Y=frame rate, Z=master switch
#    Value "111" = all enabled
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
# 4. Verify Settings.Global values in diagnostic
# ====================================================================

echo "=== Settings.Global (GFRC) ===" >> "$LOG"
gfrc_val=$(settings get global game_gfrc_mode 2>/dev/null)
echo "  game_gfrc_mode = ${gfrc_val:-'(not set)'}" >> "$LOG"
echo "" >> "$LOG"

echo "=== Done ===" >> "$LOG"
echo "If features are NOT unlocked, check:" >> "$LOG"
echo "  1. Are all ✓ marks above showing 'true'?" >> "$LOG"
echo "  2. Are there any ZTE feature config files found?" >> "$LOG"
echo "  3. Share this file with the developer for analysis" >> "$LOG"

log -t "GSU" "Game Space Unleashed v2.2.0: Setup complete! ✓"
