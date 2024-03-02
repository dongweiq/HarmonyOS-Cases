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
 * 1.定义注册日志回调、关闭日志回调、调用接口三个接口并实现
 * 2.实现自定义的日志处理函数MyHiLog，供册日志回调、关闭日志回调两个接口调用
 */

#include <fstream>
#include "napi/native_api.h"
#include "hilog/log.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[testTag]";

#define MAX_LOG_LEN 512
char logToFiter[MAX_LOG_LEN] = {};      // 要过滤的日志内容
static int s_functionCallNum = 0;       // 接口被调用的次数
napi_env g_env;
napi_ref callbackRef = nullptr;         // ArkTs端回调函数的引用

// TODO: 知识点： 自定义的日志处理函数
static void MyHiLog(const LogType type, const LogLevel level, const unsigned int domain, const char *tag,
                    const char *msg) {
    std::string strMsg(msg, strlen(msg) + 1);    
    // TODO: 知识点： 过滤要查找的日志
    size_t foundIndex = strMsg.find(logToFiter);
    if (foundIndex != -1) {
        napi_value callback = nullptr;
        napi_get_reference_value(g_env, callbackRef, &callback);
        napi_value retArg;
        s_functionCallNum += 1;
        napi_create_int32(g_env, s_functionCallNum, &retArg);        
        napi_value ret;
        // TODO: 知识点： 调用ArkTS端的回调函数
        napi_call_function(g_env, nullptr, callback, 1, &retArg, &ret);
    }
    return;
}

// TODO: 知识点：注册日志回调函数
static napi_value SetLogCallBack(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 解析要过滤的日志
    size_t logSize;
    napi_get_value_string_utf8(env, args[0], logToFiter, MAX_LOG_LEN, &logSize);

    // 解析ArkTS端的回调函数
    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[1], &valueType);
    if (valueType != napi_function) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "SetLogCallBack fail，param2 is not a function！");
        return nullptr;
    }
    // 创建ArkTS端回调函数的引用
    napi_create_reference(env, args[1], 1, &callbackRef);
    g_env = env;
    // 注册日志回调接口
    OH_LOG_SetCallback(MyHiLog);
    s_functionCallNum = 0;    // 重新初始化接口调用次数
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack SetCallback end");
    return nullptr;
}

// TODO: 知识点：关闭日志回调功能
static napi_value CancelLogCallBack(napi_env env, napi_callback_info info) {
    // 关闭日志回调
    OH_LOG_SetCallback(nullptr);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack CancelLogCallBack end");
    return nullptr;
}

// TODO: 知识点：调用功能接口
static napi_value CallMyfunction(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack [%{public}s]", logToFiter);
    // TODO: 业务处理
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"setLogCallBack", nullptr, SetLogCallBack, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cancelLogCallBack", nullptr, CancelLogCallBack, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"callMyfunction", nullptr, CallMyfunction, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "logcallback",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterLogcallbackModule(void)
{
    napi_module_register(&demoModule);
}
