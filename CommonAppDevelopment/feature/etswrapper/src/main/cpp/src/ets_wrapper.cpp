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
#include "ets_wrapper.h"
#include <bits/alltypes.h>

std::string EtsWrapper::FNS::ConvertNapiValue2String(napi_env env, napi_value value) {
    napi_status status;
    napi_valuetype type;
    status = napi_typeof(env, value, &type);
    if (type != napi_string) {
        OH_LOG_ERROR(LOG_APP, "the napi_value is not a string");
        return nullptr;
    }
    size_t strSize = 0;
    NODE_API_CALL(env, napi_get_value_string_utf8(env, value, nullptr, 0, &strSize));
    char buffer[strSize + 1];
    size_t copiedSize;
    NODE_API_CALL(env, napi_get_value_string_utf8(env, value, buffer, strSize + 1, &copiedSize));
    std::string str(buffer);
    return str;
}

std::thread::id EtsWrapper::FNS::GetCurrentThreadID() { return std::this_thread::get_id(); }

napi_value EtsWrapper::FNS::ParseNapiRef(napi_env env, napi_ref ref) {
    napi_value value;
    NODE_API_CALL(env, napi_get_reference_value(env, ref, &value));
    return value;
}

napi_value EtsWrapper::TS::SetTopAbilityID(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[] = {nullptr};
    NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    napi_valuetype type;
    NODE_API_CALL(env, napi_typeof(env, args[0], &type));
    if (type != napi_string) {
        OH_LOG_ERROR(LOG_APP, "parameter is not a string");
        return nullptr;
    }
    std::string str = FNS::ConvertNapiValue2String(env, args[0]);
    {
        std::lock_guard<std::mutex> guard(g_uniContext->lock);
        OH_LOG_INFO(LOG_APP, "setTopAbility:%{public}s=>%{public}s", g_uniContext->topAbilityID.c_str(), str.c_str());
        g_uniContext->topAbilityID = str;
    }
    return nullptr;
}

napi_value EtsWrapper::TS::RegistryDocumentViewPickerFn(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    size_t originArgc = argc;
    napi_value args[] = {nullptr, nullptr};
    NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != originArgc) {
        OH_LOG_ERROR(LOG_APP, "argument number error");
        return nullptr;
    }
    for (int i = 0; i < argc; i++) {
        napi_valuetype argType;
        NODE_API_CALL(env, napi_typeof(env, args[i], &argType));
        if (argType != napi_function) {
            OH_LOG_ERROR(LOG_APP, "argument is not function");
            return nullptr;
        }
    }
    napi_value selectWork, saveWork;
    NODE_API_CALL(env, napi_create_string_utf8(env, "selectWork", NAPI_AUTO_LENGTH, &selectWork));
    NODE_API_CALL(env, napi_create_string_utf8(env, "saveWork", NAPI_AUTO_LENGTH, &saveWork));
    {
        std::lock_guard<std::mutex> guard(g_uniContext->lock);
        NODE_API_CALL(env, napi_create_threadsafe_function(env, args[0], nullptr, selectWork, 0, 1, nullptr, nullptr,
                                                           nullptr, TSFn::CallJSSelect, &(g_uniContext->selectTsfn)));
        NODE_API_CALL(env, napi_create_threadsafe_function(env, args[1], nullptr, saveWork, 0, 1, nullptr, nullptr,
                                                           nullptr, TSFn::CallJSSave, &(g_uniContext->saveTsfn)));
        NODE_API_CALL(env, napi_create_reference(env, args[0], 1, &(g_uniContext->selectRef)));
        NODE_API_CALL(env, napi_create_reference(env, args[1], 1, &(g_uniContext->saveRef)));
        g_uniContext->pickerEnv = env;
        g_uniContext->jsThreadID = FNS::GetCurrentThreadID();
    }
    return nullptr;
}

napi_value EtsWrapper::TS::AddUIContext(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[] = {nullptr, nullptr};

    NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    std::string abilityID = FNS::ConvertNapiValue2String(env, args[0]);
    napi_ref uiContextRef;
    NODE_API_CALL(env, napi_create_reference(env, args[1], 1, &uiContextRef));
    {
        std::lock_guard<std::mutex> guard(g_uniContext->lock);
        g_uniContext->uiContextMap[abilityID] = uiContextRef;
    }
    return nullptr;
}

napi_value EtsWrapper::TS::RemoveUIContext(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[] = {nullptr};
    NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    napi_valuetype type;
    NODE_API_CALL(env, napi_typeof(env, args[0], &type));
    if (type != napi_string) {
        OH_LOG_ERROR(LOG_APP, "argument is not a string");
        return nullptr;
    }
    std::string abilityID = FNS::ConvertNapiValue2String(env, args[0]);
    auto it = g_uniContext->uiContextMap.find(abilityID);
    if (it == g_uniContext->uiContextMap.end()) {
        OH_LOG_ERROR(LOG_APP, "not found key: %{public}s", abilityID.c_str());
        return nullptr;
    }
    napi_ref uiContextRef = it->second;
    NODE_API_CALL(env, napi_delete_reference(env, uiContextRef));
    g_uniContext->uiContextMap.erase(abilityID);
    if (g_uniContext->uiContextMap.size() != 0) {
        return nullptr;
    }
    NODE_API_CALL(env, napi_release_threadsafe_function(g_uniContext->selectTsfn, napi_tsfn_abort));
    NODE_API_CALL(env, napi_release_threadsafe_function(g_uniContext->saveTsfn, napi_tsfn_abort));
    delete g_uniContext;
    return nullptr;
}

void EtsWrapper::TSFn::CallJSSelect(napi_env env, napi_value jscb, void *context, void *data) {
    napi_status status;
    DocumentViewPickerSelectParam *param = (DocumentViewPickerSelectParam *)data;
    napi_value selectOptions = param->options_.Convert2NapiValue(env);
    napi_value thenWrapper = param->selectThen_.Convert2NapiValue(env);
    napi_value catchWrapper = param->selectCatch_.Convert2NapiValue(env);
    auto it = g_uniContext->uiContextMap.find(g_uniContext->topAbilityID);
    if (it == g_uniContext->uiContextMap.end()) {
        OH_LOG_ERROR(LOG_APP, "key error: %{public}s", g_uniContext->topAbilityID.c_str());
        delete param;
        return;
    }
    napi_value uiContext = FNS::ParseNapiRef(env, it->second);
    napi_value argv[] = {uiContext, selectOptions, thenWrapper, catchWrapper};
    status = napi_call_function(env, nullptr, jscb, 4, argv, nullptr);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "call select failed");
    }
    delete param;
    { // NOTE：仅用于用返回值的场景，当jscb有返回值时，上面napi_call_function之后，即可获得其返回值，然后可将其返回值设置到全局
        // 并notify等待返回值的线程
        std::lock_guard<std::mutex> guard(g_uniContext->resultWaitUtil.lock);
        g_uniContext->resultWaitUtil.isFinished = true;
        g_uniContext->resultWaitUtil.cv.notify_all();
    }
}

void EtsWrapper::TSFn::CallJSSave(napi_env env, napi_value jscb, void *context, void *data) {
    // 参照CallJSSelect
}

napi_value EtsWrapper::DocumentSelectOptions::Convert2NapiValue(napi_env env) {
    napi_value opt;
    NODE_API_CALL(env, napi_create_object(env, &opt));
    if (this->defaultFilePathUri.length()) {
        napi_value defaultFilePathUri;
        NODE_API_CALL(
            env, napi_create_string_utf8(env, this->defaultFilePathUri.c_str(), NAPI_AUTO_LENGTH, &defaultFilePathUri));
        NODE_API_CALL(env, napi_set_named_property(env, opt, "defaultFilePathUri", defaultFilePathUri));
    }
    if (this->maxSelectNumber) {
        napi_value maxSelectNumber;
        NODE_API_CALL(env, napi_create_int64(env, this->maxSelectNumber, &maxSelectNumber));
        NODE_API_CALL(env, napi_set_named_property(env, opt, "maxSelectNumber", maxSelectNumber));
    }
    if (this->fileSuffixFilters.size()) {
        napi_value fileSuffixFilters;
        NODE_API_CALL(env, napi_create_array_with_length(env, this->fileSuffixFilters.size(), &fileSuffixFilters));
        uint32_t index = 0;
        for (auto it = this->fileSuffixFilters.begin(); it != this->fileSuffixFilters.end(); it++) {
            napi_handle_scope scope;
            napi_open_handle_scope(env, &scope);
            napi_value ele;
            NODE_API_CALL(env, napi_create_string_utf8(env, (*it).c_str(), NAPI_AUTO_LENGTH, &ele));
            NODE_API_CALL(env, napi_set_element(env, fileSuffixFilters, index++, ele));
            NODE_API_CALL(env, napi_close_handle_scope(env, scope));
        }
        napi_set_named_property(env, opt, "fileSuffixFilters", fileSuffixFilters);
    }
    if (this->selectMode != UNDEFINED) {
        napi_value mode;
        NODE_API_CALL(env, napi_create_int64(env, this->selectMode, &mode));
        NODE_API_CALL(env, napi_set_named_property(env, opt, "selectMode", mode));
    }
    return opt;
}

napi_value EtsWrapper::DocumentViewPickerSelectThenCbWrapper::Convert2NapiValue(napi_env env) {
    napi_value object;
    DocumentViewPickerSelectThenCbWrapper *thenWrapper = new DocumentViewPickerSelectThenCbWrapper(this->thenFn_);
    NODE_API_CALL(env, napi_create_object(env, &object));
    NODE_API_CALL(env, napi_wrap(
                           env, object, thenWrapper,
                           [](napi_env env, void *finalize_data, void *finalize_hint) -> void {
                               delete reinterpret_cast<DocumentViewPickerSelectThenCbWrapper *>(finalize_data);
                           },
                           nullptr, nullptr));
    napi_property_descriptor desc[] = {
        {"call", nullptr, DocumentViewPickerSelectThenCbWrapper::Call, nullptr, nullptr, nullptr, napi_default,
         nullptr},
    };
    NODE_API_CALL(env, napi_define_properties(env, object, sizeof(desc) / sizeof(*desc), desc));
    return object;
}

napi_value EtsWrapper::DocumentViewPickerSelectThenCbWrapper::Call(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    size_t originArgc = 1;
    napi_value args[] = {nullptr};
    napi_value thisArg;
    NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, &thisArg, nullptr));
    if (argc != originArgc) {
        OH_LOG_ERROR(LOG_APP, "number of arguments error");
        return nullptr;
    }
    DocumentViewPickerSelectThenCbWrapper *thenWrapper;
    NODE_API_CALL(env, napi_unwrap(env, thisArg, reinterpret_cast<void **>(&thenWrapper)));
    uint32_t arraySize;
    NODE_API_CALL(env, napi_get_array_length(env, args[0], &arraySize));
    std::list<std::string> data;
    napi_handle_scope scope;
    for (uint32_t i = 0; i < arraySize; i++) {
        napi_open_handle_scope(env, &scope);
        napi_value ele;
        NODE_API_CALL(env, napi_get_element(env, args[0], i, &ele));
        std::string fileName;
        fileName = FNS::ConvertNapiValue2String(env, ele);
        data.push_back(fileName);
        napi_close_handle_scope(env, scope);
    }
    thenWrapper->thenFn_(data);
    return nullptr;
}

napi_value EtsWrapper::DocumentViewPickerSelectCatchCbWrapper::Convert2NapiValue(napi_env env) {
    // 参照DocumentViewPickerSelectThenCbWrapper
    return nullptr;
}

napi_value EtsWrapper::DocumentViewPickerSelectCatchCbWrapper::Call(napi_env env, napi_callback_info info) {
    // 参照DocumentViewPickerSelectThenCbWrapper
    return nullptr;
}

/**
 * NOTE：如果只是本例，这里直接调用线程安全函数即可，但是为了覆盖更通用的知识，这里根据调用线程的不同使用的不同的方法
 * @param options
 * @param thenFn
 * @param catchFn
 */
void EtsWrapper::DocumentViewPickerSelect(DocumentSelectOptions options, DocumentSelectThenFn thenFn,
                                          DocumentCatchFn catchFn) {
    DocumentViewPickerSelectThenCbWrapper thenWrapper(thenFn);
    DocumentViewPickerSelectCatchCbWrapper catchWrapper(catchFn);
    DocumentViewPickerSelectParam *selectParam = new DocumentViewPickerSelectParam(options, thenWrapper, catchWrapper);
    /**
     * TODO：知识点：
     * 虽然本例无需等待返回值，但是本例旨在打造通用的框架，因此这里实现了ts侧有返回值的场景
     * 如果是在非js线程发起调用，这里就需要调用线程安全函数，并等待其结果
     */
    if (g_uniContext->jsThreadID != FNS::GetCurrentThreadID()) {
        napi_status status;
        status = napi_acquire_threadsafe_function(g_uniContext->selectTsfn);
        if (status != napi_ok) {
            OH_LOG_ERROR(LOG_APP, "acquire threadsafe_function failed");
            return;
        }
        status = napi_call_threadsafe_function(g_uniContext->selectTsfn, selectParam, napi_tsfn_blocking);
        if (status != napi_ok) {
            OH_LOG_ERROR(LOG_APP, "call threadsafe_function failed");
        }
        std::unique_lock<std::mutex> unil(g_uniContext->resultWaitUtil.lock);
        g_uniContext->resultWaitUtil.cv.wait(unil, [] { return g_uniContext->resultWaitUtil.isFinished; });
        OH_LOG_INFO(LOG_APP, "test waiting for return value");
        return;
    } else {
        /**
         * TODO：知识点：
         * 如果是在js线程发起的调用，就无需使用线程安全函数，也不能直接等待
         */
        napi_status status;
        napi_value tsSelect;
        status = napi_get_reference_value(g_uniContext->pickerEnv, g_uniContext->selectRef, &tsSelect);
        if (status != napi_ok) {
            OH_LOG_ERROR(LOG_APP, "get reference_value failed");
            return;
        }
        napi_value result; // NOTE：ts方法有返回值时使用
        napi_value uiContext;
        auto it = g_uniContext->uiContextMap.find(g_uniContext->topAbilityID);
        if (it == g_uniContext->uiContextMap.end()) {
            OH_LOG_ERROR(LOG_APP, "key error");
            return;
        }
        status = napi_get_reference_value(g_uniContext->pickerEnv, (*it).second, &uiContext);
        if (status != napi_ok) {
            OH_LOG_ERROR(LOG_APP, "get reference value failed");
        }
        napi_value args[] = {uiContext, options.Convert2NapiValue(g_uniContext->pickerEnv),
                             thenWrapper.Convert2NapiValue(g_uniContext->pickerEnv),
                             catchWrapper.Convert2NapiValue(g_uniContext->pickerEnv)};
        status = napi_call_function(g_uniContext->pickerEnv, nullptr, tsSelect, 4, args, &result);
        if (status != napi_ok) {
            OH_LOG_ERROR(LOG_APP, "call function failed");
            return;
        }
    }
    return;
}

void EtsWrapper::DocumentViewPickerSave(DocumentSaveOptions options, DocumentSaveThenFn thenFn,
                                        DocumentCatchFn catchFn) {
    // 参照documentViewPickerSelect
}