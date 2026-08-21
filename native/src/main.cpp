/*
 * Game Space Unleashed by MsysteM
 * Zygisk module - hooks Game Space & Game Assist for Super Resolution, etc.
 * No LSPosed required.
 */

#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <android/log.h>
#include <dlfcn.h>
#include <vector>
#include <string>

#include "zygisk.hpp"
#include "lsplant.hpp"
#include "dobby.h"

#define TAG "GSU-Native"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

static constexpr const char *CONFIG_PATH = "/data/adb/game_space_unleashed/config.json";

// Read entire file into a vector
static std::vector<uint8_t> readFile(int fd) {
    std::vector<uint8_t> data;
    struct stat st{};
    if (fstat(fd, &st) == 0 && st.st_size > 0) {
        data.resize(st.st_size);
        read(fd, data.data(), st.st_size);
    }
    return data;
}

// Companion handler - runs with root, sends DEX and config to the module process
static void companionHandler(int fd) {
    // Read module dir path from fd
    std::string modulePath;
    {
        uint32_t pathLen = 0;
        read(fd, &pathLen, sizeof(pathLen));
        if (pathLen > 0 && pathLen < 4096) {
            modulePath.resize(pathLen);
            read(fd, modulePath.data(), pathLen);
        }
    }

    // Read DEX
    std::string dexPath = modulePath + "/dex/classes.dex";
    int dexFd = open(dexPath.c_str(), O_RDONLY);
    std::vector<uint8_t> dexData;
    if (dexFd >= 0) {
        dexData = readFile(dexFd);
        close(dexFd);
    }

    // Read config
    int cfgFd = open(CONFIG_PATH, O_RDONLY);
    std::vector<uint8_t> cfgData;
    if (cfgFd >= 0) {
        cfgData = readFile(cfgFd);
        close(cfgFd);
    }

    // Send DEX size + data
    uint32_t dexSize = dexData.size();
    write(fd, &dexSize, sizeof(dexSize));
    if (dexSize > 0) {
        write(fd, dexData.data(), dexSize);
    }

    // Send config size + data
    uint32_t cfgSize = cfgData.size();
    write(fd, &cfgSize, sizeof(cfgSize));
    if (cfgSize > 0) {
        write(fd, cfgData.data(), cfgSize);
    }
}

REGISTER_ZYGISK_COMPANION(companionHandler)

class GameSpaceUnleashed : public zygisk::ModuleBase {
public:
    void onLoad(zygisk::Api *api, JNIEnv *env) override {
        api_ = api;
        env_ = env;
    }

    void preAppSpecialize(zygisk::AppSpecializeArgs *args) override {
        const char *niceName = env_->GetStringUTFChars(args->nice_name, nullptr);
        if (!niceName) return;

        bool isTarget = (strcmp(niceName, "cn.nubia.gameassist") == 0 ||
                         strcmp(niceName, "cn.nubia.gamelauncher") == 0);

        if (isTarget) {
            processName_ = niceName;
            shouldHook_ = true;

            // Get module directory
            int modDir = api_->getModuleDir();
            char pathBuf[256];
            snprintf(pathBuf, sizeof(pathBuf), "/proc/self/fd/%d", modDir);
            char resolvedPath[512];
            ssize_t len = readlink(pathBuf, resolvedPath, sizeof(resolvedPath) - 1);
            if (len > 0) {
                resolvedPath[len] = '\0';
                modulePath_ = resolvedPath;
            }

            // Connect to companion to get DEX + config
            int fd = api_->connectCompanion();
            if (fd >= 0) {
                // Send module path
                uint32_t pathLen = modulePath_.size();
                write(fd, &pathLen, sizeof(pathLen));
                write(fd, modulePath_.c_str(), pathLen);

                // Receive DEX
                uint32_t dexSize = 0;
                read(fd, &dexSize, sizeof(dexSize));
                if (dexSize > 0 && dexSize < 10 * 1024 * 1024) {
                    dexData_.resize(dexSize);
                    size_t totalRead = 0;
                    while (totalRead < dexSize) {
                        ssize_t n = read(fd, dexData_.data() + totalRead, dexSize - totalRead);
                        if (n <= 0) break;
                        totalRead += n;
                    }
                    if (totalRead != dexSize) dexData_.clear();
                }

                // Receive config
                uint32_t cfgSize = 0;
                read(fd, &cfgSize, sizeof(cfgSize));
                if (cfgSize > 0 && cfgSize < 1024 * 1024) {
                    configData_.resize(cfgSize);
                    size_t totalRead = 0;
                    while (totalRead < cfgSize) {
                        ssize_t n = read(fd, configData_.data() + totalRead, cfgSize - totalRead);
                        if (n <= 0) break;
                        totalRead += n;
                    }
                    if (totalRead != cfgSize) configData_.clear();
                }

                close(fd);
            }
        }

        env_->ReleaseStringUTFChars(args->nice_name, niceName);

        if (!shouldHook_) {
            api_->setOption(zygisk::DLCLOSE_MODULE_LIBRARY);
        }
    }

    void postAppSpecialize(const zygisk::AppSpecializeArgs *args) override {
        if (!shouldHook_ || dexData_.empty()) {
            if (shouldHook_) {
                LOGE("No DEX data received from companion");
            }
            return;
        }

        LOGI("Hooking process: %s", processName_.c_str());

        // Initialize LSPlant with Dobby as inline hooker
        if (!initLSPlant(env_)) {
            LOGE("LSPlant initialization failed");
            return;
        }

        // Load DEX into the process
        if (!loadDex(env_)) {
            LOGE("Failed to load DEX");
            return;
        }

        // Call Java init
        callJavaInit(env_);
    }

private:
    zygisk::Api *api_ = nullptr;
    JNIEnv *env_ = nullptr;
    bool shouldHook_ = false;
    std::string processName_;
    std::string modulePath_;
    std::vector<uint8_t> dexData_;
    std::vector<uint8_t> configData_;

    bool initLSPlant(JNIEnv *env) {
        return lsplant::Init(env, lsplant::InitInfo{
            .inline_hooker = [](void *target, void *hooker) -> void* {
                dobby_dummy_func_t origin = nullptr;
                if (DobbyHook(target, (dobby_dummy_func_t)hooker, &origin) == 0) {
                    return (void *)origin;
                }
                return nullptr;
            },
            .inline_unhooker = [](void *target) -> bool {
                return DobbyDestroy(target) == 0;
            },
            .art_symbol_resolver = [](std::string_view symbol) -> void* {
                return dlsym(RTLD_DEFAULT, symbol.data());
            },
            .art_symbol_prefix_resolver = [](std::string_view symbol) -> void* {
                return dlsym(RTLD_DEFAULT, symbol.data());
            },
        });
    }

    bool loadDex(JNIEnv *env) {
        // Create ByteBuffer from DEX data
        jobject dexBuffer = env->NewDirectByteBuffer(dexData_.data(), dexData_.size());
        if (!dexBuffer) {
            LOGE("Failed to create ByteBuffer for DEX");
            return false;
        }

        // Use InMemoryDexClassLoader
        jclass clsDexCL = env->FindClass("dalvik/system/InMemoryDexClassLoader");
        if (!clsDexCL) {
            // Fallback: write to tmp and use DexClassLoader
            env->ExceptionClear();
            return loadDexFromFile(env);
        }

        jmethodID ctorDexCL = env->GetMethodID(clsDexCL, "<init>",
            "(Ljava/nio/ByteBuffer;Ljava/lang/ClassLoader;)V");
        if (!ctorDexCL) {
            env->ExceptionClear();
            return loadDexFromFile(env);
        }

        // Get the system class loader
        jclass clsCL = env->FindClass("java/lang/ClassLoader");
        jmethodID getSystemCL = env->GetStaticMethodID(clsCL, "getSystemClassLoader",
            "()Ljava/lang/ClassLoader;");
        jobject systemCL = env->CallStaticObjectMethod(clsCL, getSystemCL);

        // Create our class loader
        dexClassLoader_ = env->NewGlobalRef(
            env->NewObject(clsDexCL, ctorDexCL, dexBuffer, systemCL));

        if (env->ExceptionCheck()) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            return loadDexFromFile(env);
        }

        return dexClassLoader_ != nullptr;
    }

    bool loadDexFromFile(JNIEnv *env) {
        // Write DEX to a temp file
        char tmpPath[256];
        snprintf(tmpPath, sizeof(tmpPath), "/data/local/tmp/gsu_%d.dex", getpid());
        int tmpFd = open(tmpPath, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (tmpFd < 0) {
            LOGE("Cannot create temp DEX file");
            return false;
        }
        write(tmpFd, dexData_.data(), dexData_.size());
        close(tmpFd);

        // Use DexClassLoader
        jclass clsDexCL = env->FindClass("dalvik/system/DexClassLoader");
        jmethodID ctorDexCL = env->GetMethodID(clsDexCL, "<init>",
            "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V");

        jclass clsCL = env->FindClass("java/lang/ClassLoader");
        jmethodID getSystemCL = env->GetStaticMethodID(clsCL, "getSystemClassLoader",
            "()Ljava/lang/ClassLoader;");
        jobject systemCL = env->CallStaticObjectMethod(clsCL, getSystemCL);

        jstring jDexPath = env->NewStringUTF(tmpPath);
        jstring jOptDir = env->NewStringUTF("/data/local/tmp");

        dexClassLoader_ = env->NewGlobalRef(
            env->NewObject(clsDexCL, ctorDexCL, jDexPath, jOptDir, nullptr, systemCL));

        // Cleanup temp file
        unlink(tmpPath);

        if (env->ExceptionCheck()) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            return false;
        }

        return dexClassLoader_ != nullptr;
    }

    void callJavaInit(JNIEnv *env) {
        // Register native methods for the hook bridge
        registerNativeMethods(env);

        // Find HookEntry class from our DEX
        jclass clsCL = env->GetObjectClass(dexClassLoader_);
        jmethodID loadClass = env->GetMethodID(clsCL, "loadClass",
            "(Ljava/lang/String;)Ljava/lang/Class;");

        jstring entryClassName = env->NewStringUTF("com.msystem.gamespaceunleashed.HookEntry");
        jclass hookEntryClass = (jclass)env->CallObjectMethod(dexClassLoader_, loadClass, entryClassName);

        if (env->ExceptionCheck() || !hookEntryClass) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            LOGE("Failed to load HookEntry class");
            return;
        }

        // Call HookEntry.init(String processName, String configJson, ClassLoader targetClassLoader)
        jmethodID initMethod = env->GetStaticMethodID(hookEntryClass, "init",
            "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V");
        if (!initMethod) {
            env->ExceptionClear();
            LOGE("Failed to find HookEntry.init method");
            return;
        }

        jstring jProcessName = env->NewStringUTF(processName_.c_str());
        jstring jConfig = env->NewStringUTF(
            configData_.empty() ? "{}" : std::string((char*)configData_.data(), configData_.size()).c_str());

        // Get the app's class loader (from the current thread's context)
        jclass threadClass = env->FindClass("java/lang/Thread");
        jmethodID currentThread = env->GetStaticMethodID(threadClass, "currentThread",
            "()Ljava/lang/Thread;");
        jmethodID getContextCL = env->GetMethodID(threadClass, "getContextClassLoader",
            "()Ljava/lang/ClassLoader;");
        jobject thread = env->CallStaticObjectMethod(threadClass, currentThread);
        jobject contextCL = env->CallObjectMethod(thread, getContextCL);

        env->CallStaticVoidMethod(hookEntryClass, initMethod, jProcessName, jConfig, contextCL);

        if (env->ExceptionCheck()) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            LOGE("HookEntry.init threw exception");
        } else {
            LOGI("Hooks initialized successfully for %s", processName_.c_str());
        }
    }

    void registerNativeMethods(JNIEnv *env) {
        // Load HookBridge class from our DEX
        jclass clsCL = env->GetObjectClass(dexClassLoader_);
        jmethodID loadClass = env->GetMethodID(clsCL, "loadClass",
            "(Ljava/lang/String;)Ljava/lang/Class;");

        jstring bridgeClassName = env->NewStringUTF("com.msystem.gamespaceunleashed.HookBridge");
        jclass bridgeClass = (jclass)env->CallObjectMethod(dexClassLoader_, loadClass, bridgeClassName);

        if (env->ExceptionCheck() || !bridgeClass) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            LOGE("Failed to load HookBridge class");
            return;
        }

        // Register native methods
        JNINativeMethod methods[] = {
            {"nativeHook", "(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;)Ljava/lang/reflect/Method;",
             (void*)nativeHook},
            {"nativeLog", "(Ljava/lang/String;)V", (void*)nativeLog},
        };

        env->RegisterNatives(bridgeClass, methods, sizeof(methods) / sizeof(methods[0]));
        if (env->ExceptionCheck()) {
            env->ExceptionDescribe();
            env->ExceptionClear();
            LOGE("Failed to register native methods");
        }
    }

    // JNI native implementations
    static jobject JNICALL nativeHook(JNIEnv *env, jclass, jobject targetMember, jobject replacement) {
        // Get the declaring class of the replacement method to use as hooker_object
        jclass methodClass = env->FindClass("java/lang/reflect/Method");
        jmethodID getDeclaringClass = env->GetMethodID(methodClass, "getDeclaringClass",
            "()Ljava/lang/Class;");
        jobject hookerObject = env->CallObjectMethod(replacement, getDeclaringClass);

        // LSPlant::Hook(env, target, hooker_object, callback_method) -> backup method
        jobject backup = lsplant::Hook(env, targetMember, hookerObject, replacement);
        if (!backup) {
            LOGE("LSPlant::Hook failed");
        }
        return backup;
    }

    static void JNICALL nativeLog(JNIEnv *env, jclass, jstring msg) {
        const char *str = env->GetStringUTFChars(msg, nullptr);
        if (str) {
            LOGI("%s", str);
            env->ReleaseStringUTFChars(msg, str);
        }
    }

    jobject dexClassLoader_ = nullptr;
};

REGISTER_ZYGISK_MODULE(GameSpaceUnleashed)
