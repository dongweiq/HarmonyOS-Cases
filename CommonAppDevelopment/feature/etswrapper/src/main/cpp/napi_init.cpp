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
#include "ets_wrapper.h"
#include "mock.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"registryDocumentViewPickerFn", nullptr, EtsWrapper::TS::RegistryDocumentViewPickerFn, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"addUIContext", nullptr, EtsWrapper::TS::AddUIContext, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeUIContext", nullptr, EtsWrapper::TS::RemoveUIContext, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setTopAbilityID", nullptr, EtsWrapper::TS::SetTopAbilityID, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"mockDocumentViewPickerSelectJSThread", nullptr, Mock::MockDocumentViewPickerSelectJSThread, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"mockDocumentViewPickerSelectPThread", nullptr, Mock::MockDocumentViewPickerSelectPThread, nullptr, nullptr,
         nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "etswrapper",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEtswrapperModule(void) { napi_module_register(&demoModule); }
