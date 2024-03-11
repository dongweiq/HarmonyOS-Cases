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

#ifndef COMMONAPPDEVELOPMENT_ETSWRAPPER_H
#define COMMONAPPDEVELOPMENT_ETSWRAPPER_H

#include <list>
#include <string>
#include <thread>
#include <unordered_set>
#include "hilog/log.h"
#include "napi/native_api.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x1111
#define LOG_TAG "DocumentViewPickerWrapper"

/**
 * TODO：知识点：
 * 统一处理异常
 */
#define NODE_API_CALL(env, call)                                                                                       \
    do {                                                                                                               \
        napi_status status = (call);                                                                                   \
        if (status != napi_ok) {                                                                                       \
            const napi_extended_error_info *error_info = NULL;                                                         \
            napi_get_last_error_info((env), &error_info);                                                              \
            const char *err_message = error_info->error_message;                                                       \
            bool is_pending;                                                                                           \
            napi_is_exception_pending((env), &is_pending);                                                             \
            /* If an exception is already pending, don't rethrow it */                                                 \
            if (!is_pending) {                                                                                         \
                const char *message = (err_message == NULL) ? "empty error message" : err_message;                     \
                OH_LOG_ERROR(LOG_APP, "%{public}s", message);                                                          \
                napi_throw_error((env), NULL, message);                                                                \
            }                                                                                                          \
            return NULL;                                                                                               \
        }                                                                                                              \
    } while (0)

/**
 * 思路：调用者可能在js线程，也可能在pthread线程，所以需要使用线程安全函数对注册的方法进行封装
 * 1. 注册select与save方法时，在注册的时候创建线程安全函数
 * 2. 调用的时候，相应参数（包括options与then和catch的回调）封装为参数进行传递
 */
namespace EtsWrapper {
    /**
     * 一些工具函数
     */
    namespace FNS {
        /**
         * 将napi_value转换为std::string
         */
        std::string ConvertNapiValue2String(napi_env env, napi_value value);
        /**
         * 获取当前线程id
         */
        std::thread::id GetCurrentThreadID();
        /**
         * 从napi_ref终取出napi_value
         */
        napi_value ParseNapiRef(napi_env env, napi_ref ref);

    } // namespace FNS

    /**
     * 在ts侧直接调用的方法
     */
    namespace TS {
        /**
         * 注册封装后的ts方法
         */
        napi_value RegistryDocumentViewPickerFn(napi_env env, napi_callback_info info);
        /**
         * 添加UIContext
         */
        napi_value AddUIContext(napi_env env, napi_callback_info info);
        /**
         * 移除UIContext
         */
        napi_value RemoveUIContext(napi_env env, napi_callback_info info);
        /**
         * 设置当前活跃的UIAbilityID
         */
        napi_value SetTopAbilityID(napi_env env, napi_callback_info info);
    } // namespace TS

    /**
     * 线程安全函数相关，创建线程安全函数时使用
     * 真正的回掉通过data参数传递进来，包含三部分，options参数、thenwrapper、catchwrapper、另外需要的uiContext通过活跃的abilityID获取
     */
    namespace TSFn {
        void CallJSSelect(napi_env env, napi_value jscb, void *context, void *data);
        void CallJSSave(napi_env env, napi_value jscb, void *context, void *data);
    } // namespace TSFn

    /**
     * TODO：知识点：
     * ts侧对应数据结构，当ts侧传递error对象到native侧后，使用本结构接收
     * 因为ts侧中的data属性使用了模板，因此这里无法对应的具体类型，这里进行了忽略
     */
    struct BusinessError {
        int code;
        std::string name;
        std::string message;
        std::string stack;
    };

    /**
     * ts侧对应数据结构
     */
    struct DocumentSelectOptions {
        enum DocumentSelectMode {
            UNDEFINED = -1, // 用于判断调用者是否真正设置了TS侧对应值
            FILE = 0,
            FOLDER = 1,
            MIXED = 2,
        };
        std::string defaultFilePathUri = {};
        std::list<std::string> fileSuffixFilters = {};
        uint64_t maxSelectNumber = 0;
        DocumentSelectMode selectMode = UNDEFINED;
        napi_value Convert2NapiValue(napi_env env);
    };
    /**
     * ts侧对应数据结构
     */
    struct DocumentSaveOptions {
        // 参照DocumentSelectOptions
    };

    /**
     * TODO：知识点：
     * 开发者回调函数类型
     */
    typedef void (*DocumentSelectThenFn)(std::list<std::string> value);
    typedef DocumentSelectThenFn DocumentSaveThenFn;
    typedef void (*DocumentCatchFn)(BusinessError error);
    /**
     * TODO：知识点：
     * then回调函数wrapper，调用时真正调用的是Call方法，Call方法中调用真正的回调
     */
    class DocumentViewPickerSelectThenCbWrapper {
    public:
        DocumentSelectThenFn thenFn_;
        DocumentViewPickerSelectThenCbWrapper(DocumentSelectThenFn fn) : thenFn_(fn) {}
        /**
         * 将对象实例包装为js对象
         */
        napi_value Convert2NapiValue(napi_env env);
        /**
         * 参数是string[]，这里面会调用thenFn
         */
        static napi_value Call(napi_env env, napi_callback_info info);
    };
    /**
     * catch账调函数wrapper，调用时真正调用的是Call方法，Call方法中调用真正的回调
     */
    class DocumentViewPickerSelectCatchCbWrapper {
    public:
        DocumentCatchFn catchFn_;
        DocumentViewPickerSelectCatchCbWrapper(DocumentCatchFn fn) : catchFn_(fn) {}
        napi_value Convert2NapiValue(napi_env env);
        /**
         * 参数是BusinessError，这里会调用catchFn
         */
        static napi_value Call(napi_env env, napi_callback_info info);
    };
    /**
     * TODO：知识点：
     * 调用者传递的参数封装，包括select时的options参数、select的then回调、catch回调
     */
    class DocumentViewPickerSelectParam {
    public:
        DocumentSelectOptions options_;
        DocumentViewPickerSelectThenCbWrapper selectThen_;
        DocumentViewPickerSelectCatchCbWrapper selectCatch_;
        DocumentViewPickerSelectParam(DocumentSelectOptions options, DocumentViewPickerSelectThenCbWrapper selectThen,
                                      DocumentViewPickerSelectCatchCbWrapper selectCatch)
            : options_(options), selectThen_(selectThen), selectCatch_(selectCatch) {}
    };
    class DocumentViewPickerSaveParam {
        // 参照DocumentViewPickerSelectParam
    };

    /**
     * TODO：知识点：
     * 同步等待结果的工具
     */
    struct ResultWaitUtil {
        bool isFinished = false;
        std::condition_variable cv;
        std::mutex lock;
    };

    /**
     * TODO：知识点：
     * picker执行的上下文，保存一些全局数据，包括：注册的方法，js线程id，当前活跃ability的id，uiAbilityID及其对应uiContext的映射，锁
     */
    struct UniContext {
        std::thread::id jsThreadID;
        std::string topAbilityID;
        // registry使用，保存注册的ts方法，在非js线程发起调用时使用
        napi_threadsafe_function selectTsfn;
        napi_threadsafe_function saveTsfn;
        std::unordered_map<std::string, napi_ref> uiContextMap;
        std::mutex lock;
        // registry使用，创建注册方法的引用：在js线程发起调用时使用
        napi_ref selectRef;            // NOTE：仅用于ts侧方法有返回值的场景
        napi_ref saveRef;              // NOTE：仅用于ts侧方法有返回值的场景
        napi_env pickerEnv;            // NOTE：仅用于ts侧方法有返回值的场景
        ResultWaitUtil resultWaitUtil; // NOTE：仅用于ts侧方法有返回值的场景
    };
    UniContext *const g_uniContext = new UniContext();
    /**
     * TODO：知识点：
     * 供开发者真正调用的方法，以cpp的形式暴露
     */
    void DocumentViewPickerSelect(DocumentSelectOptions options, DocumentSelectThenFn thenFn, DocumentCatchFn catchFn);
    void DocumentViewPickerSave(DocumentSaveOptions options, DocumentSaveThenFn thenFn, DocumentCatchFn catchFn);
} // namespace EtsWrapper

#endif // COMMONAPPDEVELOPMENT_ETSWRAPPER_H
