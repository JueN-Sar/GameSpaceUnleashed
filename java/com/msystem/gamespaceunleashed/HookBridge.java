package com.msystem.gamespaceunleashed;

import java.lang.reflect.Member;
import java.lang.reflect.Method;

/**
 * JNI bridge to LSPlant hooking engine.
 * Native methods are registered by the Zygisk module.
 */
public class HookBridge {

    /**
     * Hook a method using LSPlant.
     * @param target The target method/constructor to hook
     * @param replacement The replacement method (must have matching signature)
     * @return Backup method to call original, or null on failure
     */
    public static native Method nativeHook(Member target, Method replacement);

    /**
     * Log a message via native Android logging.
     */
    public static native void nativeLog(String message);

    /**
     * Convenience: hook and return backup, with error logging.
     */
    public static Method hook(Member target, Method replacement) {
        try {
            Method backup = nativeHook(target, replacement);
            if (backup != null) {
                backup.setAccessible(true);
                nativeLog("Hooked: " + target.getDeclaringClass().getName() + "." + target.getName());
            } else {
                nativeLog("Hook FAILED: " + target.getDeclaringClass().getName() + "." + target.getName());
            }
            return backup;
        } catch (Throwable t) {
            nativeLog("Hook exception: " + t.getMessage());
            return null;
        }
    }

    /**
     * Invoke a backup (original) method.
     */
    public static Object invokeBackup(Method backup, Object thiz, Object... args) {
        try {
            return backup.invoke(thiz, args);
        } catch (Throwable t) {
            nativeLog("Backup invoke failed: " + t.getMessage());
            return null;
        }
    }
}
