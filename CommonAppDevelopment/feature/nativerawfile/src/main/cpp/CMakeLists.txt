# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NativeRawFile)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
add_library(nativerawfile SHARED hello.cpp)
# TODO：知识点：在CMakeLists中导入所需的库，日志库为libhilog_ndk库。
target_link_libraries(nativerawfile PUBLIC libace_napi.z.so libhilog_ndk.z.so librawfile.z.so)
