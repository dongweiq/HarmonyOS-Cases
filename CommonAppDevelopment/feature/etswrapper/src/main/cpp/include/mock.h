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

#ifndef COMMONAPPDEVELOPMENT_MOCK_H
#define COMMONAPPDEVELOPMENT_MOCK_H
#include "ets_wrapper.h"

namespace Mock {
    /**
     * 模拟picker.select().then((value:string[])=>void)中的回调，这里只是简单打印选择的文件
     * @param value：选择的文件/目录
     */
    void DocumentSelectThenFn(std::list<std::string> value);
    /**
     * 模拟picker.select().catch((error:BusinessError)=>void)中的回调，实现请参照then回调
     * @param error：ets侧的error参数
     */
    void DocumentSelectCatchFn(EtsWrapper::BusinessError error);
    /**
     * 模拟native侧在js线程发起调用
     */
    napi_value MockDocumentViewPickerSelectJSThread(napi_env env, napi_callback_info info);
    /**
     * 模拟native侧在PThread线程发起调用
     */
    napi_value MockDocumentViewPickerSelectPThread(napi_env env, napi_callback_info info);
} // namespace Mock

#endif // COMMONAPPDEVELOPMENT_MOCK_H
