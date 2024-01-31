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

/**
 * TODO 知识点：模拟下载任务，这里面也可以使用threadsafefunction来实现
 */
void downloadTask(CallbackContext *context) {
    uv_loop_s *loop = nullptr;
    // 获取context->env上下文环境的loop（线程池）
    napi_get_uv_event_loop(context->env, &loop);
    // uv_work_t是关联loop和线程池回调函数的结构体
    uv_work_t *work = new uv_work_t;
    work->data = (CallbackContext *)context;

    while (context && context->progress < 100) {
        uv_queue_work(
            loop, work, [](uv_work_t *) {},
            [](uv_work_t *work, int status) {
                CallbackContext *context = (CallbackContext *)work->data;
                context->progress += 1;
                napi_handle_scope scope;
                // 管理napi_value生命周期，防止内存泄漏
                napi_open_handle_scope(context->env, &scope);
                napi_value callback;
                napi_get_reference_value(context->env, context->callbackRef, &callback);
                napi_value retArg;
                napi_create_int32(context->env, context->progress, &retArg);
                napi_value ret;
                napi_call_function(context->env, nullptr, callback, 1, &retArg, &ret);
                napi_close_handle_scope(context->env, scope);
                if (context->progress > 99) {
                    delete context;
                    delete work;
                }
            });
        // 睡眠100ms
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
};

static napi_value startDownload(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, args[0], 1, &asyncContext->callbackRef);
    // TODO 知识点：启动下载线程
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
