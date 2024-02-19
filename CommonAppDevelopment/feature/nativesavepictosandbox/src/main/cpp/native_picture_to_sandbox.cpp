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

/** 实现步骤
 * 1.将编译好的libcurl.so libcurl.so.4 libnghttp2.so libnghttp2.so.14 libzstd.so以及libcurlDownload.so放入libs中相应的目录
 * 2.使用libcurlDownload.so暴露的接口DownloadInternetFileWrapper保存网络图片到沙箱
 * 3.使用Rawfile的API接口及文件流saveImageOfRawfile接口保存rawfile文件到沙箱
 */

#include <fstream>
#include <dlfcn.h>
#include "napi/native_api.h"
#include "hilog/log.h"
#include "rawfile/raw_file_manager.h"
#include "rawfile/raw_file.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[testTag]";
const char libCurlDownload[256] = "libcurlDownload.so";   // 下载so文件

/**
 * 网络图片保存到沙箱路径
 * @param env
 * @param info
 * @return 返回图片保存的沙箱地址
 */
static napi_value SaveImageOfInternet(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet load libcurlDownload.so begin");
    // 使用dlopen动态加载so库，返回so库的句柄
    void *handler = dlopen(libCurlDownload, RTLD_LAZY);
    if (handler == nullptr) {
        // 抛出加载库失败的错误
        dlerror();
        return nullptr;
    }

    // 声明函数指针类型
    typedef napi_value (*DownloadInternetFileFunc)(napi_env, napi_callback_info);
    DownloadInternetFileFunc downloadInternetWrapper =
        reinterpret_cast<DownloadInternetFileFunc>(dlsym(handler, "DownloadInternetFileWrapper"));
    if (downloadInternetWrapper) {
        // TODO：知识点：调用so的downloadInternetWrapper函数保存网路图片到沙箱
        napi_value result = downloadInternetWrapper(env, info);
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet download finish");
        dlclose(handler);
        return result;
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfInternet download function is null");
        dlclose(handler);
        return nullptr;
    }
}

/**
 * rawfile文件保存到沙箱路径
 * @param env
 * @param info
 * @return 返回图片保存的沙箱地址
 */
static napi_value SaveImageOfRawfile(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile Begin");
    size_t argc = 3;
    napi_value argv[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    // 初始化native resource manager
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    // 获取源文件rawfile目录
    size_t rawFileNameSize;
    char rawFileNameBuf[512];
    napi_get_value_string_utf8(env, argv[1], rawFileNameBuf, sizeof(rawFileNameBuf), &rawFileNameSize);
    std::string rawFileName(rawFileNameBuf, rawFileNameSize);
    // 获取保存文件的目标目录
    size_t targetDirectorSize;
    char targetDirectoryBuf[512];
    napi_get_value_string_utf8(env, argv[2], targetDirectoryBuf, sizeof(targetDirectoryBuf), &targetDirectorSize);
    std::string targetDirectory(targetDirectoryBuf, targetDirectorSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile targetPath:%{public}s", targetDirectoryBuf);

    // 打开Rawfile文件。
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(mNativeResMgr, rawFileName.c_str());
    if (rawFile == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile OpenRawFile fail!");
        // 释放资源
        OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
        return nullptr;
    }
    // 获取文件大小
    long imageDataSize = OH_ResourceManager_GetRawFileSize(rawFile);
    // 申请内存
    std::unique_ptr<char[]> imageData = std::make_unique<char[]>(imageDataSize);
    // TODO：知识点：通过Rawfile的API接口读取Rawfile文件
    long rawFileOffset = OH_ResourceManager_ReadRawFile(rawFile, imageData.get(), imageDataSize);
    // 保存目标网络图片的沙箱路径
    std::string targetSandboxPath = targetDirectory + rawFileName;
    // TODO：知识点：通过std::ofstream，将读取的数据写入沙箱文件
    std::ofstream outputFile(targetSandboxPath, std::ios::binary);
    if (!outputFile) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile 创建沙箱目标文件失败");
        // 释放资源
        OH_ResourceManager_CloseRawFile(rawFile);
        OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
        return nullptr;
    }
    // 写文件
    outputFile.write(imageData.get(), imageDataSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile 图片写入沙箱成功，沙箱路径：%{public}s",
                 targetSandboxPath.c_str());
    // 关闭文件
    outputFile.close();
    // 释放资源
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
    // 返回沙箱路径
    napi_value strSandBoxPath;
    napi_create_string_utf8(env, targetSandboxPath.c_str(), NAPI_AUTO_LENGTH, &strSandBoxPath);
    return strSandBoxPath;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // TODO：知识点：napi_property_descriptor 为结构体，做用是描述扩展暴露的 属性/方法 的描述。
    napi_property_descriptor desc[] = {
        {"saveImageOfInternet", nullptr, SaveImageOfInternet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"saveImageOfRawfile", nullptr, SaveImageOfRawfile, nullptr, nullptr, nullptr, napi_default, nullptr}};
    // TODO: 知识点：定义暴露的方法
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "nativesavepictosandbox",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterNativerawfileModule(void) { napi_module_register(&demoModule); }
