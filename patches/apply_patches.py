#!/usr/bin/env python3
"""
Game Space Unleashed — APK Patcher
Applies all smali patches to decompiled GameAssist and GameSpace APKs.
"""

import re
import sys
import os

def patch_file(filepath, patches_applied):
    """Apply patches to a single smali file."""
    with open(filepath, "r") as f:
        content = f.read()
    
    original = content
    
    # --- Pattern 1: isSupport*()Z methods → return true ---
    pattern_isSupport = r'(\.method\s+(?:public\s+)?(?:private\s+)?static\s+isSupport\w+\(\)Z\s*\n)(.*?)(\.end method)'
    def replace_isSupport(match):
        header = match.group(1)
        name = re.search(r'isSupport\w+', header).group()
        return f"""{header}    .locals 1
    # GSU: Force {name} = true
    const/4 v0, 0x1
    return v0
.end method"""
    content = re.sub(pattern_isSupport, replace_isSupport, content, flags=re.DOTALL)
    
    # --- Pattern 2: getZteFeature*()Boolean methods → return TRUE ---
    pattern_zte = r'(\.method\s+public\s+static\s+getZteFeature\w+\(\)Ljava/lang/Boolean;\s*\n)(.*?)(\.end method)'
    def replace_zte(match):
        header = match.group(1)
        name = re.search(r'getZteFeature\w+', header).group()
        return f"""{header}    .locals 1
    # GSU: Force {name} = TRUE
    const/4 v0, 0x1
    invoke-static {{v0}}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;
    move-result-object v0
    return-object v0
.end method"""
    content = re.sub(pattern_zte, replace_zte, content, flags=re.DOTALL)
    
    if content != original:
        with open(filepath, "w") as f:
            f.write(content)
        count = content.count("# GSU:")
        patches_applied[0] += count
        return True
    return False


def patch_method_return_true(filepath, method_sig, patches_applied):
    """Replace a method body with 'return true'."""
    with open(filepath, "r") as f:
        content = f.read()
    
    start = content.find(method_sig)
    if start == -1:
        print(f"  WARNING: Method not found: {method_sig[:60]}...")
        return
    
    end = content.find(".end method", start) + len(".end method")
    name = re.search(r'[\w$]+\(', method_sig)
    name = name.group()[:-1] if name else "unknown"
    
    new_method = f"""{method_sig}
    .locals 1
    # GSU: Force {name} = true
    const/4 v0, 0x1
    return v0
.end method"""
    
    content = content[:start] + new_method + content[end:]
    with open(filepath, "w") as f:
        f.write(content)
    patches_applied[0] += 1
    print(f"  ✓ {name} → true")


def patch_method_return_int(filepath, method_sig, value, patches_applied):
    """Replace a method body with 'return <value>'."""
    with open(filepath, "r") as f:
        content = f.read()
    
    start = content.find(method_sig)
    if start == -1:
        print(f"  WARNING: Method not found: {method_sig[:60]}...")
        return
    
    end = content.find(".end method", start) + len(".end method")
    name = re.search(r'[\w$]+\(', method_sig)
    name = name.group()[:-1] if name else "unknown"
    
    new_method = f"""{method_sig}
    .locals 1
    # GSU: Force {name} = {value}
    const/16 v0, {hex(value)}
    return v0
.end method"""
    
    content = content[:start] + new_method + content[end:]
    with open(filepath, "w") as f:
        f.write(content)
    patches_applied[0] += 1
    print(f"  ✓ {name} → {value}")


def patch_method_return_boolean_true(filepath, method_sig, patches_applied):
    """Replace a method returning Boolean with Boolean.TRUE."""
    with open(filepath, "r") as f:
        content = f.read()
    
    start = content.find(method_sig)
    if start == -1:
        print(f"  WARNING: Method not found: {method_sig[:60]}...")
        return
    
    end = content.find(".end method", start) + len(".end method")
    name = re.search(r'[\w$]+\(', method_sig)
    name = name.group()[:-1] if name else "unknown"
    
    new_method = f"""{method_sig}
    .locals 1
    # GSU: Force {name} = TRUE
    const/4 v0, 0x1
    invoke-static {{v0}}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;
    move-result-object v0
    return-object v0
.end method"""
    
    content = content[:start] + new_method + content[end:]
    with open(filepath, "w") as f:
        f.write(content)
    patches_applied[0] += 1
    print(f"  ✓ {name} → TRUE")


def main():
    if len(sys.argv) < 3:
        print("Usage: apply_patches.py <GameAssist_dir> <GameSpace_dir>")
        sys.exit(1)
    
    ga_dir = sys.argv[1]
    gs_dir = sys.argv[2]
    patches = [0]
    
    print("=" * 50)
    print("Game Space Unleashed — Applying Patches")
    print("=" * 50)
    
    # === GameAssist Patches ===
    print("\n[GameAssist] Patching PluginUtils...")
    patch_method_return_int(
        f"{ga_dir}/smali/cn/nubia/gameassist/plugin/PluginUtils.smali",
        ".method public e(Ljava/lang/String;)I", 11, patches)
    
    print("\n[GameAssist] Patching PluginConfig...")
    patch_method_return_true(
        f"{ga_dir}/smali/cn/nubia/gameassist/plugin/config/PluginConfig.smali",
        ".method public static l(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Z", patches)
    patch_method_return_true(
        f"{ga_dir}/smali/cn/nubia/gameassist/plugin/config/PluginConfig.smali",
        ".method public static k(Landroid/content/Context;Ljava/lang/String;)Z", patches)
    
    print("\n[GameAssist] Patching ZteFeature (all isSupport* flags)...")
    zte_file = f"{ga_dir}/smali_classes2/com/zte/gameassist/config/ZteFeature.smali"
    if os.path.exists(zte_file):
        patch_file(zte_file, patches)
        print(f"  ✓ All ZteFeature flags patched")
    
    # === GameSpace Patches ===
    print("\n[GameSpace] Patching SuperResolutionHelper...")
    sr_file = f"{gs_dir}/smali/cn/nubia/gamelauncher/gamecontrolpanel/superresolution/SuperResolutionHelper.smali"
    patch_method_return_true(sr_file,
        ".method public static supportSuperResolutionByPkgName(Ljava/lang/String;)Z", patches)
    patch_method_return_true(sr_file,
        ".method public static supportSuperResolution()Z", patches)
    
    print("\n[GameSpace] Patching ControlPanelFeatureHelper...")
    cp_file = f"{gs_dir}/smali/cn/nubia/gamelauncher/gamecontrolpanel/utils/ControlPanelFeatureHelper.smali"
    patch_method_return_boolean_true(cp_file,
        ".method public static getZteFeatureMagicSuperResolution()Ljava/lang/Boolean;", patches)
    patch_method_return_true(cp_file,
        ".method public static supportGames(Ljava/lang/String;)Z", patches)
    patch_method_return_true(cp_file,
        ".method public static precisionSupportGames(Ljava/lang/String;)Z", patches)
    patch_method_return_boolean_true(cp_file,
        ".method public static supportAiAdjustByFeature(Ljava/lang/String;)Ljava/lang/Boolean;", patches)
    patch_method_return_boolean_true(cp_file,
        ".method public static supportPrecisionByFeature(Ljava/lang/String;)Ljava/lang/Boolean;", patches)
    patch_file(cp_file, patches)
    
    print("\n[GameSpace] Patching GameWhiteList...")
    patch_method_return_true(
        f"{gs_dir}/smali/cn/nubia/gamelauncher/aimhelper/GameWhiteList.smali",
        ".method public static isSupportGame(Ljava/lang/String;)Z", patches)
    
    print("\n[GameSpace] Patching FeatureUtil...")
    patch_file(f"{gs_dir}/smali/cn/nubia/common/util/FeatureUtil.smali", patches)
    
    print("\n[GameSpace] Patching Utils...")
    utils_file = f"{gs_dir}/smali/cn/nubia/gamelauncher/gamecontrolpanel/utils/Utils.smali"
    if os.path.exists(utils_file):
        patch_file(utils_file, patches)
    
    print(f"\n{'=' * 50}")
    print(f"Total patches applied: {patches[0]}")
    print(f"{'=' * 50}")


if __name__ == "__main__":
    main()
