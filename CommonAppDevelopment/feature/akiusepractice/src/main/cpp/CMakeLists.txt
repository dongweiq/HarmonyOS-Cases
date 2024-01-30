# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(myNpmLib)

# 将当前源代码目录路径设置为NATIVERENDER_ROOT_PATH变量，以便在后续的构建过程中使用。
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# 向编译器添加包含目录
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

# 设置AKI根路径
set(AKI_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../../oh_modules/@ohos/aki)

# 将CMAKE_MODULE_PATH变量的值设置为AKI_ROOT_PATH变量的值，这样CMake在查找自定义模块时会查看这个路径。
set(CMAKE_MODULE_PATH ${AKI_ROOT_PATH})

# 用于查找并加载名为"Aki"的库
find_package(Aki REQUIRED)

# 创建并编译一个aki_use_practice库
add_library(aki_use_practice SHARED akiusepractice.cpp)

# 将Aki::libjsbind库链接到aki_use_practice
target_link_libraries(aki_use_practice PUBLIC Aki::libjsbind)