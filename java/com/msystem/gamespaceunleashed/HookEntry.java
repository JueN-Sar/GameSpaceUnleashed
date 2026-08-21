package com.msystem.gamespaceunleashed;

import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

import org.json.JSONObject;

/**
 * Game Space Unleashed - Hook Entry Point
 * Called by the Zygisk native module after DEX loading and LSPlant init.
 *
 * Mirrors all hooks from KhanhNguyen9872/NubiaToolkit but without LSPosed/Xposed.
 */
public class HookEntry {

    private static ClassLoader targetClassLoader;
    private static JSONObject config;

    // Backup methods for "after" hooks and conditional hooks
    private static Method backup_getItem;
    private static Method backup_isPluginEnable;
    private static Method backup_linkOMTProvider;
    private static Method backup_handleUpdateState;

    /**
     * Main entry point - called from native code.
     * @param processName The hooked process name
     * @param configJson JSON config string
     * @param appClassLoader The target app's class loader
     */
    public static void init(String processName, String configJson, ClassLoader appClassLoader) {
        targetClassLoader = appClassLoader;

        try {
            config = new JSONObject(configJson);
        } catch (Exception e) {
            config = new JSONObject();
        }

        HookBridge.nativeLog("HookEntry.init: process=" + processName);

        try {
            if ("cn.nubia.gameassist".equals(processName)) {
                initGameAssist();
            } else if ("cn.nubia.gamelauncher".equals(processName)) {
                initGameLauncher();
            }
        } catch (Throwable t) {
            HookBridge.nativeLog("HookEntry.init failed: " + t.getMessage());
        }
    }

    private static void initGameAssist() {
        boolean superRes = config.optBoolean("superResolution", true);
        boolean globalMode = config.optBoolean("globalGameMode", true);
        boolean noKill = config.optBoolean("noKill", false);
        boolean hideEnergy = config.optBoolean("hideEnergyCube", false);
        boolean smallWin = config.optBoolean("smallWindow", false);

        if (superRes) {
            hookSuperResolution_GameAssist();
        }
        if (globalMode) {
            hookGlobalGameMode();
        }
        if (noKill) {
            hookNoKill();
        }
        if (hideEnergy) {
            hookHideEnergyCube();
        }
        if (smallWin) {
            hookSmallWindow();
        }
    }

    private static void initGameLauncher() {
        boolean superRes = config.optBoolean("superResolution", true);
        boolean watermark = config.optBoolean("watermarkLength", false);

        if (superRes) {
            hookSuperResolution_GameLauncher();
        }
        if (watermark) {
            hookWatermarkLength();
        }
    }

    // ==================== SUPER RESOLUTION (GameAssist) ====================

    private static void hookSuperResolution_GameAssist() {
        // 1. PluginUtils.getGfrcCapByPkg(String) -> 1
        hookMethod("cn.nubia.gameassist.plugin.PluginUtils",
            "getGfrcCapByPkg", new Class<?>[]{String.class},
            "hook_getGfrcCapByPkg", new Class<?>[]{Object.class, String.class},
            true);

        // 2. PluginUtils.isSupportResolutionOld() -> true
        hookReturnTrue("cn.nubia.gameassist.plugin.PluginUtils",
            "isSupportResolutionOld");

        // 3. PluginUtils.isSupportResolutionSettingsInXml() -> true
        hookReturnTrue("cn.nubia.gameassist.plugin.PluginUtils",
            "isSupportResolutionSettingsInXml");

        // 4. PluginUtils.supportResolution(String) -> true
        hookReturnTrueWithString("cn.nubia.gameassist.plugin.PluginUtils",
            "supportResolution");

        // 5. SuperResolutionTypeDataManager.getItem(String, String) -> after hook
        hookMethod("cn.nubia.plugin.superresolution.SuperResolutionTypeDataManager",
            "getItem", new Class<?>[]{String.class, String.class},
            "hook_getItem", new Class<?>[]{Object.class, String.class, String.class},
            true);

        // 6. ZteFeature.isSupportSuperResolution() -> true
        hookReturnTrue("com.zte.gameassist.config.ZteFeature",
            "isSupportSuperResolution");

        // 7. ZteFeature.isSupportSuperResolutionOld() -> true
        hookReturnTrue("com.zte.gameassist.config.ZteFeature",
            "isSupportSuperResolutionOld");

        // 8. PluginConfig.isPluginEnable(Context, String) -> true for super_resolution
        try {
            Class<?> contextClass = Class.forName("android.content.Context");
            hookMethod("cn.nubia.gameassist.plugin.config.PluginConfig",
                "isPluginEnable", new Class<?>[]{contextClass, String.class},
                "hook_isPluginEnable", new Class<?>[]{Object.class, Object.class, String.class},
                true);
        } catch (Throwable t) {
            HookBridge.nativeLog("isPluginEnable hook setup failed: " + t.getMessage());
        }

        // 9. Utils.isSmallWindowOpen(Context) -> false (for Super Resolution)
        try {
            Class<?> contextClass = Class.forName("android.content.Context");
            hookMethodReturnFalse("cn.nubia.gameassist.utils.Utils",
                "isSmallWindowOpen", new Class<?>[]{contextClass});
        } catch (Throwable t) {
            HookBridge.nativeLog("isSmallWindowOpen (SR) hook failed: " + t.getMessage());
        }
    }

    // ==================== SUPER RESOLUTION (GameLauncher) ====================

    private static void hookSuperResolution_GameLauncher() {
        // 10. SuperResolutionHelper.supportSuperResolutionByPkgName(String) -> true
        hookReturnTrueWithString(
            "cn.nubia.gamelauncher.gamecontrolpanel.superresolution.SuperResolutionHelper",
            "supportSuperResolutionByPkgName");

        // 11. ControlPanelFeatureHelper.getZteFeatureMagicSuperResolution() -> true
        hookReturnTrue(
            "cn.nubia.gamelauncher.gamecontrolpanel.utils.ControlPanelFeatureHelper",
            "getZteFeatureMagicSuperResolution");
    }

    // ==================== GLOBAL GAME MODE ====================

    private static void hookGlobalGameMode() {
        // GameCheck.isGameSpaceListApp(String) -> true
        hookReturnTrueWithString("com.zte.gameassist.common.GameCheck",
            "isGameSpaceListApp");

        // GameCheck.isGameSpaceListApp(String, int) -> true
        try {
            hookMethodReturnTrue("com.zte.gameassist.common.GameCheck",
                "isGameSpaceListApp", new Class<?>[]{String.class, int.class});
        } catch (Throwable t) {
            // Two-arg variant may not exist
        }
    }

    // ==================== NO KILL ====================

    private static void hookNoKill() {
        // CleanAnimationController.startClean() -> null/void
        hookReturnVoid("cn.nubia.gameassist.dessert.policy.clean.CleanAnimationController",
            "startClean");

        // MindSyncManager.startBgAppCleanupFromGameMode(List) -> null/void
        try {
            Class<?> listClass = Class.forName("java.util.List");
            hookMethodReturnVoid("com.zte.performance.mindsync.MindSyncManager",
                "startBgAppCleanupFromGameMode", new Class<?>[]{listClass});
        } catch (Throwable t) {
            // Optional
        }

        // OneMoreThingManager.linkOMTProvider(String, Bundle) -> conditional
        try {
            Class<?> bundleClass = Class.forName("android.os.Bundle");
            hookMethod("cn.nubia.gameassist.onemorething.OneMoreThingManager",
                "linkOMTProvider", new Class<?>[]{String.class, bundleClass},
                "hook_linkOMTProvider", new Class<?>[]{Object.class, String.class, Object.class},
                true);
        } catch (Throwable t) {
            // Optional
        }
    }

    // ==================== HIDE ENERGY CUBE ====================

    private static void hookHideEnergyCube() {
        try {
            Class<?> contextClass = Class.forName("android.content.Context");
            Class<?> handlerClass = Class.forName("android.os.Handler");
            Class<?> listClass = Class.forName("java.util.List");

            hookMethodReturnVoid("cn.nubia.gameassist.tips.GameAssistLaunchTips",
                "createAndShowTips", new Class<?>[]{
                    contextClass, handlerClass, handlerClass,
                    String.class, String.class, listClass,
                    Runnable.class, String.class
                });
        } catch (Throwable t) {
            HookBridge.nativeLog("HideEnergyCube hook failed: " + t.getMessage());
        }
    }

    // ==================== SMALL WINDOW ====================

    private static void hookSmallWindow() {
        // ActivityManagerWrapper.checkTaskSupportWr(String) -> true
        hookReturnTrueWithString("com.zte.shared.wrapper.ActivityManagerWrapper",
            "checkTaskSupportWr");

        // TilesUtil.getHideAppList(Context) -> empty ArrayList
        try {
            Class<?> contextClass = Class.forName("android.content.Context");
            hookMethod("cn.nubia.gameassist.utils.TilesUtil",
                "getHideAppList", new Class<?>[]{contextClass},
                "hook_getHideAppList", new Class<?>[]{Object.class, Object.class},
                true);
        } catch (Throwable t) {
            HookBridge.nativeLog("getHideAppList hook failed: " + t.getMessage());
        }

        // Utils.isSmallWindowOpen(Context) -> true (for SmallWindow feature)
        // Note: SuperResolution hooks this to return false, SmallWindow to return true.
        // If both enabled, SmallWindow's hook runs last (SuperRes already handled its own case).
        // We skip this if superResolution is also enabled since it conflicts.
        if (!config.optBoolean("superResolution", true)) {
            try {
                Class<?> contextClass = Class.forName("android.content.Context");
                hookMethodReturnTrue("cn.nubia.gameassist.utils.Utils",
                    "isSmallWindowOpen", new Class<?>[]{contextClass});
            } catch (Throwable t) {
                // Optional
            }
        }

        // SmallWindowTile.handleUpdateState - after hook to set state
        try {
            Class<?> tileStateClass = targetClassLoader.loadClass("cn.nubia.gameassist.common.QSTile$State");
            hookMethod("cn.nubia.gameassist.dessert.tiles.SmallWindowTile",
                "handleUpdateState", new Class<?>[]{tileStateClass, Object.class},
                "hook_handleUpdateState", new Class<?>[]{Object.class, Object.class, Object.class},
                false); // isBeforeHook=false -> we want after behavior
        } catch (Throwable t) {
            HookBridge.nativeLog("SmallWindowTile hook failed: " + t.getMessage());
        }
    }

    // ==================== WATERMARK LENGTH ====================

    private static void hookWatermarkLength() {
        // WaterMarkWatcher constructor(EditText, int) - change maxLength to 1000
        try {
            Class<?> editTextClass = Class.forName("android.widget.EditText");
            Class<?> watcherClass = targetClassLoader.loadClass(
                "cn.nubia.gamecenter.settings.watermark.WaterMarkWatcher");
            // We hook the constructor — but LSPlant hooks Method objects, not constructors directly.
            // Instead, we'll hook via the class constructor approach.
            // For now, skip constructor hooks as they need special handling.
            HookBridge.nativeLog("WatermarkLength: constructor hooking not yet supported");
        } catch (Throwable t) {
            HookBridge.nativeLog("WatermarkLength hook failed: " + t.getMessage());
        }
    }

    // ==================== REPLACEMENT METHODS ====================
    // These are the actual replacement methods called by LSPlant.
    // For instance methods: first param is 'this' (as Object).
    // For static methods: no 'this' param.
    // We provide both variants and select at hook time.

    // --- Super Resolution replacements ---

    public static int hook_getGfrcCapByPkg(Object thiz, String pkg) {
        return 1; // Always supported
    }

    public static int hook_getGfrcCapByPkg_static(String pkg) {
        return 1;
    }

    public static String hook_getItem(Object thiz, String arg1, String type) {
        // After-hook behavior: call original, then modify result
        if (backup_getItem != null) {
            String result = (String) HookBridge.invokeBackup(backup_getItem, thiz, arg1, type);
            if ("imageQuality".equals(type) && ("origin".equals(result) || result == null)) {
                return "1";
            } else if ("frameRate".equals(type) && ("frameRate_origin".equals(result) || result == null)) {
                return "1";
            }
            return result;
        }
        return "1";
    }

    public static String hook_getItem_static(String arg1, String type) {
        return "1";
    }

    public static boolean hook_isPluginEnable(Object thiz, Object ctx, String pluginName) {
        if ("super_resolution".equals(pluginName) || "super_resolution_old".equals(pluginName)) {
            return true;
        }
        // Call original for other plugins
        if (backup_isPluginEnable != null) {
            Object result = HookBridge.invokeBackup(backup_isPluginEnable, thiz, ctx, pluginName);
            return result != null && (Boolean) result;
        }
        return false;
    }

    public static boolean hook_isPluginEnable_static(Object ctx, String pluginName) {
        if ("super_resolution".equals(pluginName) || "super_resolution_old".equals(pluginName)) {
            return true;
        }
        if (backup_isPluginEnable != null) {
            Object result = HookBridge.invokeBackup(backup_isPluginEnable, null, ctx, pluginName);
            return result != null && (Boolean) result;
        }
        return false;
    }

    // --- No Kill replacements ---

    public static Object hook_linkOMTProvider(Object thiz, String method, Object bundle) {
        if ("kill".equals(method)) {
            HookBridge.nativeLog("NoKill: Intercepted OneMoreThingManager.kill");
            return null;
        }
        if (backup_linkOMTProvider != null) {
            return HookBridge.invokeBackup(backup_linkOMTProvider, thiz, method, bundle);
        }
        return null;
    }

    public static Object hook_linkOMTProvider_static(String method, Object bundle) {
        if ("kill".equals(method)) {
            return null;
        }
        if (backup_linkOMTProvider != null) {
            return HookBridge.invokeBackup(backup_linkOMTProvider, null, method, bundle);
        }
        return null;
    }

    // --- Small Window replacements ---

    public static Object hook_getHideAppList(Object thiz, Object ctx) {
        return new java.util.ArrayList<>();
    }

    public static Object hook_getHideAppList_static(Object ctx) {
        return new java.util.ArrayList<>();
    }

    public static void hook_handleUpdateState(Object thiz, Object state, Object arg) {
        // Call original first (after-hook pattern)
        if (backup_handleUpdateState != null) {
            HookBridge.invokeBackup(backup_handleUpdateState, thiz, state, arg);
        }
        // Then modify state
        if (state != null) {
            try {
                java.lang.reflect.Field valueField = state.getClass().getField("value");
                valueField.setAccessible(true);
                valueField.set(state, true);

                try {
                    java.lang.reflect.Field visibleField = state.getClass().getField("visible");
                    visibleField.setAccessible(true);
                    visibleField.set(state, true);
                } catch (Throwable ignored) {}
            } catch (Throwable t) {
                HookBridge.nativeLog("handleUpdateState field set failed: " + t.getMessage());
            }
        }
    }

    public static void hook_handleUpdateState_static(Object state, Object arg) {
        hook_handleUpdateState(null, state, arg);
    }

    // --- Generic return-value replacements ---

    // Return true - no args
    public static boolean returnTrue0() { return true; }
    public static boolean returnTrue1(Object a) { return true; }
    public static boolean returnTrue2(Object a, Object b) { return true; }
    public static boolean returnTrue3(Object a, Object b, Object c) { return true; }

    // Return false
    public static boolean returnFalse0() { return false; }
    public static boolean returnFalse1(Object a) { return false; }
    public static boolean returnFalse2(Object a, Object b) { return false; }

    // Return void/null
    public static void returnVoid0() {}
    public static void returnVoid1(Object a) {}
    public static void returnVoid2(Object a, Object b) {}
    public static void returnVoid3(Object a, Object b, Object c) {}
    public static Object returnNull0() { return null; }
    public static Object returnNull1(Object a) { return null; }
    public static Object returnNull2(Object a, Object b) { return null; }
    public static Object returnNull3(Object a, Object b, Object c) { return null; }
    public static Object returnNull4(Object a, Object b, Object c, Object d) { return null; }
    public static Object returnNull5(Object a, Object b, Object c, Object d, Object e) { return null; }
    public static Object returnNull6(Object a, Object b, Object c, Object d, Object e, Object f) { return null; }
    public static Object returnNull7(Object a, Object b, Object c, Object d, Object e, Object f, Object g) { return null; }
    public static Object returnNull8(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h) { return null; }
    public static Object returnNull9(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h, Object i) { return null; }

    // ==================== HOOK HELPERS ====================

    /**
     * Hook a method, auto-detecting static vs instance and selecting the correct replacement.
     */
    private static void hookMethod(String className, String methodName,
            Class<?>[] paramTypes, String replacementName,
            Class<?>[] replacementParams, boolean isBeforeHook) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName, paramTypes);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());

            // Find replacement method
            String actualReplacementName = replacementName;
            Class<?>[] actualReplacementParams = replacementParams;

            if (isStatic) {
                // Static target: use _static variant (no 'this' param)
                actualReplacementName = replacementName + "_static";
                // Remove first Object param (thiz)
                if (replacementParams.length > 0 && replacementParams[0] == Object.class) {
                    actualReplacementParams = new Class<?>[replacementParams.length - 1];
                    System.arraycopy(replacementParams, 1, actualReplacementParams, 0,
                        replacementParams.length - 1);
                }
            }

            Method replacement;
            try {
                replacement = HookEntry.class.getDeclaredMethod(actualReplacementName, actualReplacementParams);
            } catch (NoSuchMethodException e) {
                // Fallback to instance variant
                replacement = HookEntry.class.getDeclaredMethod(replacementName, replacementParams);
            }
            replacement.setAccessible(true);

            Method backup = HookBridge.hook(target, replacement);

            // Store backup for after-hooks
            if (backup != null) {
                if ("hook_getItem".equals(replacementName) || "hook_getItem_static".equals(actualReplacementName)) {
                    backup_getItem = backup;
                } else if ("hook_isPluginEnable".equals(replacementName) || "hook_isPluginEnable_static".equals(actualReplacementName)) {
                    backup_isPluginEnable = backup;
                } else if ("hook_linkOMTProvider".equals(replacementName) || "hook_linkOMTProvider_static".equals(actualReplacementName)) {
                    backup_linkOMTProvider = backup;
                } else if ("hook_handleUpdateState".equals(replacementName) || "hook_handleUpdateState_static".equals(actualReplacementName)) {
                    backup_handleUpdateState = backup;
                }
            }
        } catch (ClassNotFoundException e) {
            HookBridge.nativeLog("Class not found: " + className + " (optional hook)");
        } catch (NoSuchMethodException e) {
            HookBridge.nativeLog("Method not found: " + className + "." + methodName + " (optional hook)");
        } catch (Throwable t) {
            HookBridge.nativeLog("Hook failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a no-arg method to return true.
     */
    private static void hookReturnTrue(String className, String methodName) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            Method replacement = HookEntry.class.getDeclaredMethod(
                isStatic ? "returnTrue0" : "returnTrue1",
                isStatic ? new Class<?>[0] : new Class<?>[]{Object.class});
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (ClassNotFoundException e) {
            HookBridge.nativeLog("Class not found: " + className);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookReturnTrue failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a method(String) to return true.
     */
    private static void hookReturnTrueWithString(String className, String methodName) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName, String.class);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            int paramCount = 1 + (isStatic ? 0 : 1); // String + optional this
            Method replacement = HookEntry.class.getDeclaredMethod(
                "returnTrue" + paramCount,
                paramCount == 1 ? new Class<?>[]{Object.class} : new Class<?>[]{Object.class, Object.class});
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (ClassNotFoundException e) {
            HookBridge.nativeLog("Class not found: " + className);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookReturnTrueWithString failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a method to return true with specific param types.
     */
    private static void hookMethodReturnTrue(String className, String methodName, Class<?>[] paramTypes) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName, paramTypes);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            int paramCount = paramTypes.length + (isStatic ? 0 : 1);
            Class<?>[] repParams = new Class<?>[paramCount];
            java.util.Arrays.fill(repParams, Object.class);
            Method replacement = HookEntry.class.getDeclaredMethod("returnTrue" + paramCount, repParams);
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookMethodReturnTrue failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a method to return false with specific param types.
     */
    private static void hookMethodReturnFalse(String className, String methodName, Class<?>[] paramTypes) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName, paramTypes);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            int paramCount = paramTypes.length + (isStatic ? 0 : 1);
            Class<?>[] repParams = new Class<?>[paramCount];
            java.util.Arrays.fill(repParams, Object.class);
            Method replacement = HookEntry.class.getDeclaredMethod("returnFalse" + paramCount, repParams);
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookMethodReturnFalse failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a no-arg method to return void/null.
     */
    private static void hookReturnVoid(String className, String methodName) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            Method replacement = HookEntry.class.getDeclaredMethod(
                isStatic ? "returnVoid0" : "returnVoid1",
                isStatic ? new Class<?>[0] : new Class<?>[]{Object.class});
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookReturnVoid failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }

    /**
     * Hook a method to return void with specific param types.
     */
    private static void hookMethodReturnVoid(String className, String methodName, Class<?>[] paramTypes) {
        try {
            Class<?> targetClass = targetClassLoader.loadClass(className);
            Method target = targetClass.getDeclaredMethod(methodName, paramTypes);
            target.setAccessible(true);

            boolean isStatic = Modifier.isStatic(target.getModifiers());
            int paramCount = paramTypes.length + (isStatic ? 0 : 1);

            // Try void variant first, then null variant
            String methodPrefix = target.getReturnType() == void.class ? "returnVoid" : "returnNull";
            Class<?>[] repParams = new Class<?>[paramCount];
            java.util.Arrays.fill(repParams, Object.class);

            Method replacement;
            try {
                replacement = HookEntry.class.getDeclaredMethod(methodPrefix + paramCount, repParams);
            } catch (NoSuchMethodException e) {
                replacement = HookEntry.class.getDeclaredMethod("returnNull" + paramCount, repParams);
            }
            replacement.setAccessible(true);

            HookBridge.hook(target, replacement);
        } catch (Throwable t) {
            HookBridge.nativeLog("hookMethodReturnVoid failed: " + className + "." + methodName + ": " + t.getMessage());
        }
    }
}
