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

#include "napi/native_api.h"
#include <thread>
#include <uv.h>

typedef struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
    int progress = 0;
} CallbackContext;

// TODO：知识点：回调ts侧函数，将进度信息通知到ts侧
static void callTS(napi_env env, napi_value jsCb, void *context, void *data) {
    CallbackContext *arg = (CallbackContext *)data;
    napi_value progress;
    napi_create_int32(arg->env, arg->progress, &progress);
    napi_call_function(arg->env, nullptr, jsCb, 1, &progress, nullptr);
}

/**
 * TODO 知识点：模拟下载任务，这里因为调用了ts侧函数，所以要使用线程安全函数
 */
void downloadTask(CallbackContext *context) {
    // 创建线程安全函数
    napi_value workName;
    napi_create_string_utf8(context->env, "download", NAPI_AUTO_LENGTH, &workName);
    napi_value jsCb;
    napi_get_reference_value(context->env, context->callbackRef, &jsCb);
    napi_threadsafe_function tsfn;
    napi_create_threadsafe_function(context->env, jsCb, nullptr, workName, 0, 1, nullptr, nullptr, nullptr, callTS,
                                    &tsfn);
    while (context && context->progress < 100) {
        context->progress += 1;
        napi_acquire_threadsafe_function(tsfn);
        napi_call_threadsafe_function(tsfn, (void *)context, napi_tsfn_blocking);
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    delete context;
};

static napi_value startDownload(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, args[0], 1, &asyncContext->callbackRef);
    // TODO 知识点：启动下载线程，在子线程中执行下载任务并实时将进度通知到arkts线程
    std::thread downloadThread(downloadTask, asyncContext);
    downloadThread.detach();
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"startDownload", nullptr, startDownload, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "nativeprogressnotify",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterNativeprocessnotifyModule(void) {
    napi_module_register(&demoModule);
}
