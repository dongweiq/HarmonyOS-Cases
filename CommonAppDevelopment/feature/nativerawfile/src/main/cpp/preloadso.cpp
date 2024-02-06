/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 实现步骤：
 * 1.在cpp文件中引入所用API函数及系统函数的头文件。
 * 2.在cpp文件的Init函数中描述并定义要实现、暴露的接口。
 * 3.在cpp文件中实现要暴露的接口。
 * 4.在.d.ts文件中通过export暴露接口给ArkTS层使用
 * 5.在CMakeLists中通过target_link_libraries导入所用的库
 */

#include "napi/native_api.h"
#include <dlfcn.h>           // 包含 dlopen 函数的头文件
#include "global_handlers.h" // 包含全局对象global_handlers的头文件
// TODO：知识点：导入日志头文件。
#include <hilog/log.h>

// hilog参数
const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Preload]";

static napi_value Preload(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload init");
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value result;
    napi_create_array(env, &result); // 创建一个数组用于存放结果

    // args[0]为so库路径数组
    napi_valuetype valuetype;
    napi_typeof(env, args[0], &valuetype);

    if (valuetype != napi_object) {
        // 处理 args[0] 不是对象的情况
        return nullptr;
    }
    // 获取传入的so库路径数组的长度
    uint32_t arrayLength;
    napi_get_array_length(env, args[0], &arrayLength);

    napi_value pathString;
    char path[256]; // 长度256的字符数组，用来存储so库路径
    size_t pathLength;
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload start");
    for (uint32_t i = 0; i < arrayLength; i++) {
        napi_get_element(env, args[0], i, &pathString); // 获取数组的第 i 个元素
        napi_status status = napi_get_value_string_utf8(env, pathString, path, sizeof(path), &pathLength);
        if (status != napi_ok) {
            // 处理获取路径失败的情况
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, " Preload failed");
            continue;
        }
        // TODO：知识点：使用dlopen动态加载so库，返回so库的句柄
        void *handler= dlopen(path, RTLD_LAZY);
        if (handler == nullptr) {
            // TODO：知识点：dlerror抛出加载库失败的错误
            dlerror();
            continue; // 加载下一个
        }
        // 将句柄保存到全局对象global_handlers中
        global_handlers[std::string(path)] = handler;
        // 将成功加载的库的路径添加到结果数组中
        napi_set_element(env, result, i, pathString);
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload finish");
    return result; // 返回加载成功的结果数组
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // TODO：知识点：napi_property_descriptor 为结构体，做用是描述扩展暴露的 属性/方法 的描述。
    napi_property_descriptor desc[] = {{"preload", nullptr, Preload, nullptr, nullptr, nullptr, napi_default, nullptr}};
    // TODO: 知识点：定义暴露的方法
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "preloadso",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterPreloadsoModule(void) { napi_module_register(&demoModule); }
