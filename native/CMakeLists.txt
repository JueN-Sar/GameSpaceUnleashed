cmake_minimum_required(VERSION 3.18)
project(GameSpaceUnleashed)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build as shared library for Zygisk
add_library(${PROJECT_NAME} SHARED
    src/main.cpp
)

# Dobby - inline hooking engine (required by LSPlant)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../external/dobby/CMakeLists.txt")
    set(DOBBY_DEBUG OFF CACHE BOOL "" FORCE)
    set(DOBBY_GENERATE_SHARED OFF CACHE BOOL "" FORCE)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../external/dobby dobby_build)
    target_link_libraries(${PROJECT_NAME} dobby)
else()
    message(FATAL_ERROR "Dobby not found. Run: git clone --depth=1 https://github.com/jmpews/Dobby.git external/dobby")
endif()

# LSPlant - ART method hooking (build as static lib)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../external/lsplant/lsplant/src/main/jni/CMakeLists.txt")
    set(LSPLANT_BUILD_SHARED OFF CACHE BOOL "" FORCE)
    set(LSPLANT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../external/lsplant/lsplant/src/main/jni")
    add_subdirectory(${LSPLANT_DIR} lsplant_build)
    target_link_libraries(${PROJECT_NAME} lsplant_static)
else()
    message(FATAL_ERROR "LSPlant not found. Run: git clone https://github.com/LSPosed/LSPlant.git external/lsplant")
endif()

# Include paths
target_include_directories(${PROJECT_NAME} PRIVATE
    src
)

# Link Android log library
target_link_libraries(${PROJECT_NAME} log)

# Strip the output for release builds
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -s")

# Set output name to match Zygisk conventions
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "game_space_unleashed"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${ANDROID_ABI}"
)
