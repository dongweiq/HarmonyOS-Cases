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
 * 实现步骤
 * 1.在cpp文件中引入所用API函数及系统函数的头文件
 * 2.在cpp文件的Init函数中描述并定义要实现、暴露的接口
 * 3.在cpp文件中实现要暴露的接口
 * 4.在.d.ts文件中通过export暴露接口
 * 5.在CMakeLists中通过target_link_libraries导入所用的库
*/

#include <bits/alltypes.h>
#include <dlfcn.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <malloc.h>
#include <unistd.h>
#include "napi/native_api.h"
#include "global_handlers.h" // 包含全局对象global_handlers的头文件
// TODO：知识点：导入日志头文件。
#include "hilog/log.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Native_Rawfile_Api]";

// 获取并调用so库中的GetTotalRawFileContentWrapper函数，返回调用结果
static napi_value GetTotalRawFileContent(napi_env env, napi_callback_info info) {
    // 从全局对象中获取指定so库的句柄
    void *handler = global_handlers["libnativerawfile.so"];
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "get handler start");
    if (handler == nullptr) {
        // 处理句柄为空的情况
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "get handler failed");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "get handler finish");
    // 声明函数指针类型
    typedef napi_value (*GetTotalRawFileContentWrapperFunc)(napi_env, napi_callback_info);
    // TODO：知识点：使用dlsym查找和调用so库中的符号
    GetTotalRawFileContentWrapperFunc getTotalRawFileContentWrapper =
        reinterpret_cast<GetTotalRawFileContentWrapperFunc>(dlsym(handler, "GetTotalRawFileContentWrapper"));
    if (getTotalRawFileContentWrapper) {
        // 调用 GetRawFileContentWrapper 函数
        napi_value result = getTotalRawFileContentWrapper(env, info);
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContentWrapper finish");
        return result;
    } else {
        // 处理无法获取函数指针的情况
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetTotalRawFileContentWrapper failed");
        return nullptr;
    }
}

// 获取并调用so库中的GetRawFileContentWrapper函数，返回调用结果
static napi_value GetRawFileContent(napi_env env, napi_callback_info info) {
    // 从全局对象中获取指定so库的句柄
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "get handler start");
    void *handler = global_handlers["libnativerawfile.so"];
    if (handler == nullptr) {
        // 处理句柄为空的情况
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "get handler failed");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "get handler finish");
    // 声明函数指针类型
    typedef napi_value (*GetRawFileContentWrapperFunc)(napi_env, napi_callback_info);
    GetRawFileContentWrapperFunc getRawFileContentWrapper =
        reinterpret_cast<GetRawFileContentWrapperFunc>(dlsym(handler, "GetRawFileContentWrapper"));
    if (getRawFileContentWrapper) {
        // 调用 GetRawFileContentWrapper 函数
        napi_value result = getRawFileContentWrapper(env, info);
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContentWrapper finish");
        return result;
    } else {
        // 处理无法获取函数指针的情况
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetRawFileContentWrapper failed");
        return nullptr;
    }
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"getTotalRawFileContent", nullptr, GetTotalRawFileContent, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRawFileContent", nullptr, GetRawFileContent, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "nativerawfileapi",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterNativerawfileModule(void) { napi_module_register(&demoModule); }
