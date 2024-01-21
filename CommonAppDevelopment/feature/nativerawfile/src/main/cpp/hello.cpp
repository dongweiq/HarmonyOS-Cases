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

#include <bits/alltypes.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <malloc.h>
#include <unistd.h>
#include "napi/native_api.h"
#include "rawfile/raw_file_manager.h"
#include "rawfile/raw_file.h"
#include "hilog/log.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Sample_rawfile]";

static napi_value GetRawFileContent(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContent Begin");
    size_t argc = 4;
    napi_value argv[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    // 初始化native resource manager
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    // 获取文件名
    size_t strSize;
    char strBuf[256];
    napi_get_value_string_utf8(env, argv[1], strBuf, sizeof(strBuf), &strSize);
    std::string filename(strBuf, strSize);
    // 获取读取位置与长度参数
    int32_t startPos = 0;
    int32_t lenContent = 0;
    napi_get_value_int32(env, argv[2], &startPos);
    napi_get_value_int32(env, argv[3], &lenContent);

    // 打开指定rawfile文件。
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(mNativeResMgr, filename.c_str());
    if (rawFile == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetRawFileContent OpenRawFile fail!");
        // 释放资源
        OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
        return nullptr;
    }
    // 获取rawfile的fd
    RawFileDescriptor descriptor;
    OH_ResourceManager_GetRawFileDescriptor(rawFile, descriptor);
    // 获取文件大小
    long len = OH_ResourceManager_GetRawFileSize(rawFile);
    // 位置、长度参数校验
    if ((long)startPos < 0 || (long)startPos >= len) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetRawFileContent Fail, error startPos!");
        // 释放资源
        OH_ResourceManager_CloseRawFile(rawFile);
        OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
        return nullptr;
    }
    // 超过文件长度,读取剩余部分
    if (((long)startPos + lenContent) > len) {
        lenContent = len - startPos;
    }

    char *buf = (char *)malloc(lenContent + 1);
    memset(buf, 0, len + 1);
    int ret;
    if ((ret = pread(descriptor.fd, buf, lenContent, startPos)) == -1) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetRawFileContent pread error!");
    } else {
        buf[lenContent] = '\0';
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContent: %{public}ld: %{public}ld: %{public}s\n",
                     descriptor.start, len, buf);
    }
    napi_value strContent;
    napi_create_string_utf8(env, buf, NAPI_AUTO_LENGTH, &strContent);
    // 释放资源
    free(buf);
    buf = NULL;
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
    return strContent;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
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
    .nm_modname = "nativerawfile",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterNativerawfileModule(void)
{
    napi_module_register(&demoModule);
}
