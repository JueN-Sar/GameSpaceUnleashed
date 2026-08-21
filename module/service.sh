#!/system/bin/sh
# Game Space Unleashed — Boot Service
# Sets system properties to enable R3 chip features globally

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

# Log
log -t "GSU" "Game Space Unleashed: R3 chip properties set"
