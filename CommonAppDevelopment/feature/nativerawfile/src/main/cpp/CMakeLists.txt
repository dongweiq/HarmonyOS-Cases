# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NativeRawFile)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(preloadso SHARED preloadso.cpp)
add_library(global_handlers SHARED global_handlers.cpp)
add_library(nativerawfileapi SHARED native_rawfile_api.cpp)
# TODO：知识点：使用target_link_directories命令将需要预加载的.so文件所在目录添加到preloadso的链接目录
target_link_directories(preloadso PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/)
# TODO：知识点：在CMakeLists中导入所需的库，日志库为libhilog_ndk库。
target_link_libraries(preloadso PUBLIC libhilog_ndk.z.so libace_napi.z.so global_handlers libnativerawfile.so)
target_link_libraries(nativerawfileapi PUBLIC libhilog_ndk.z.so libace_napi.z.so global_handlers)

# 编译 native_rawfile.cpp相关配置, native_rawfile.cpp修改后可取消以下代码注释，编译新的libnativerawfile.so
# add_library(nativerawfile SHARED native_rawfile.cpp)
# target_link_libraries(nativerawfile PUBLIC libace_napi.z.so libhilog_ndk.z.so librawfile.z.so)