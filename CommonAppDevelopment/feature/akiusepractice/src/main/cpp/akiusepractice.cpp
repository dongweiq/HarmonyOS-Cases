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
 * 1.使用AKI的JSBIND_ADDON注册OpenHarmony Native插件。
 * 2.使用AKI的JSBIND_GLOBAL注册FFI特性。在JSBIND_GLOBAL作用域下使用AKI的JSBIND_FUNCTION绑定C++全局函数AkiThreadsCallJs。
 * 3.在AkiThreadsCallJs中创建子线程，子线程中使用aki::JSBind::GetJSFunction获取指定JavaScript函数akiAccumulate的句柄后，使用Invoke触发调用JS函数。
 */

#include <aki/jsbind.h>

//  定义C++函数AkiThreadsCallJs。从native主线程中创建子线程subThread调用JavaScript函数。
void AkiThreadsCallJs(int value) {
    // 创建子线程subThread
    std::thread subThread([=]() {
        // TODO：知识点：使用aki::JSBind::GetJSFunction获取指定JavaScript函数句柄后，使用Invoke触发调用。这里获取JS侧定义的函数akiAccumulate。
        if (auto func = aki::JSBind::GetJSFunction("akiAccumulate")) {
            // 定义一个函数对象callback，该函数对象接受一个整数参数并返回void。
            std::function<void(int)> callback = [](int value) {};
            // 调用JavaScript函数，Invoke<T>指定返回值类型。
            func->Invoke<void>(value, callback);
        }
    });
    // 将子线程subThread从主线程中分离出来,独立运行。
    subThread.detach();
    return;
}

// TODO：知识点：使用JSBIND_ADDON注册OpenHarmony Native插件，可从JavaScript import导入插件。注册AKI插件名:即为编译*.so名称，规则与NAPI一致。这里注册AKI插件名为:aki_use_practice
JSBIND_ADDON(aki_use_practice)

// TODO：知识点：使用JSBIND_GLOBAL注册FFI特性。用于圈定需要绑定的全局函数作用域。
JSBIND_GLOBAL() {
    // 在JSBIND_GLOBAL作用域下使用JSBIND_FUNCTION绑定C++全局函数后，可从JavaScript直接调用。
    JSBIND_FUNCTION(AkiThreadsCallJs);
}