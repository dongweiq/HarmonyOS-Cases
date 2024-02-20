# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(nativesavepictosandboxLib)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
# 包含头文件
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
# 生成nativesavepictosandbox.so文件
add_library(nativesavepictosandbox SHARED native_picture_to_sandbox.cpp)
# 链接库目录
target_link_directories(nativesavepictosandbox PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/)
# TODO：知识点：指定目标链接的库。日志库：libhilog_ndk.z.so；curl下载库：libcurlDownload.so，该库封装了开源库libcurl的下载功能；rawfile相关接口库：librawfile.z.so
target_link_libraries(nativesavepictosandbox PUBLIC libace_napi.z.so libcurlDownload.so libhilog_ndk.z.so librawfile.z.so)
