#!/system/bin/sh
# Game Space Unleashed — Boot Service
# Sets system properties and ensures patched DEX is loaded

MODDIR="${0%/*}"

# Wait for boot to complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 5

# Enable GFRC (Game Frame Rate Control) hardware features
resetprop vendor.gpp.gfrc.upscale.ratio 1
resetprop vendor.gpp.gfrc.interp.rate 1
resetprop persist.magic.super.resolution 1

# Clear dalvik-cache entries for our patched APKs on every boot
# This ensures Android doesn't re-cache the old OAT from a system update
rm -rf /data/dalvik-cache/arm64/system@app@GameAssist@GameAssist.apk@classes* 2>/dev/null
rm -rf /data/dalvik-cache/arm/system@app@GameAssist@GameAssist.apk@classes* 2>/dev/null
rm -rf /data/dalvik-cache/arm64/system@priv-app@GameSpace@GameSpace.apk@classes* 2>/dev/null
rm -rf /data/dalvik-cache/arm/system@priv-app@GameSpace@GameSpace.apk@classes* 2>/dev/null

# Log
log -t "GSU" "Game Space Unleashed: R3 chip properties set, dalvik cache cleared"
