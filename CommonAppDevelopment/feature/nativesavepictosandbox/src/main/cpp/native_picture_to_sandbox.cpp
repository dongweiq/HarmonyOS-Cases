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
const char *TAG = "[pic2sandbox]";
const char libCurlDownload[256] = "libcurlDownload.so";   // 下载so文件

// 在executeCB、completeCB之间传递RawFile下载参数数据
struct CallbackRawFileContext {
    napi_async_work asyncWork = nullptr;        // 异步工作
    napi_ref callbackRef = nullptr;             // 回调函数引用
    NativeResourceManager *resMgr = nullptr;    // 资源
    std::string rawFileName = "";               // rawfile中的文件名
    std::string sandboxDir = "";                // 保存到的沙箱目录 
    std::string result = "";                    // 返回结果
};

// 在executeCB、completeCB之间传递网络下载参数数据
struct CallbackInternetContext {
    napi_async_work asyncWork = nullptr;     // 异步工作
    napi_ref callbackRef = nullptr;          // 回调函数引用
    std::string internetPicUrl = "";         // 网络图片地址
    std::string sandboxDir = "";             // 保存到的沙箱目录
    std::string FileName = "";               // 保存的文件名
    std::string result = "";                 // 返回结果
};

// 业务逻辑处理函数，执行耗时任务，由worker线程池调度执行。
static void InternetCallbackExecuteCB(napi_env env, void *data) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet load libcurlDownload.so begin");
    // TODO：知识点：使用dlopen动态加载so库，返回so库的句柄
    void *handler = dlopen(libCurlDownload, RTLD_LAZY);
    if (handler == nullptr) {
        // 抛出加载库失败的错误
        dlerror();
        return;
    }

    // 声明函数指针类型
    typedef std::string (*DownloadInternetFileFunc)(char *, char *);
    DownloadInternetFileFunc downloadInternetWrapper =
        reinterpret_cast<DownloadInternetFileFunc>(dlsym(handler, "DownloadInternetFileWrapper"));
    if (downloadInternetWrapper) {
        // TODO：知识点：调用so的downloadInternetWrapper函数保存网路图片到沙箱
        CallbackInternetContext *internetContext = (CallbackInternetContext *)data;
        if (internetContext == nullptr) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfInternet internetContext is null");
            return;
        }
        // 图片沙箱完整路径
        std::string targetSandboxPath = internetContext->sandboxDir + internetContext->FileName;
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet 保存沙箱文件：%{public}s",
                     targetSandboxPath.c_str());

        internetContext->result = downloadInternetWrapper((char *)internetContext->internetPicUrl.c_str(),
            (char *)targetSandboxPath.c_str());
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet download finish");
        dlclose(handler);
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfInternet download function is null");
        dlclose(handler);
    }
}

// 业务逻辑处理完成回调函数，在业务逻辑处理函数执行完成或取消后触发，由EventLoop线程中执行。
static void InternetCallbackCompleteCB(napi_env env, napi_status status, void *data) {
    CallbackInternetContext *internetContext = (CallbackInternetContext *)data;
    if (internetContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfInternet internetContext is null");
        return;
    }
    napi_value callback = nullptr;
    napi_get_reference_value(env, internetContext->callbackRef, &callback);
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);
    napi_value callbackResult = nullptr;
    napi_value result;
    napi_create_string_utf8(env, internetContext->result.c_str(), NAPI_AUTO_LENGTH, &result);
    // 执行回调函数
    napi_call_function(env, undefined, callback, 1, &result, &callbackResult);
    // 删除napi_ref对象
    if (internetContext->callbackRef != nullptr) {
        napi_delete_reference(env, internetContext->callbackRef);
    }
    // 删除异步工作项
    napi_delete_async_work(env, internetContext->asyncWork);
    delete internetContext;
}

/**
 * 网络图片保存到沙箱路径
 * @param env
 * @param info
 * @return 返回图片保存的沙箱地址
 */
static napi_value SaveImageOfInternetCallback(napi_env env, napi_callback_info info) {
    // 异步工作项上下文用户数据，传递到异步工作项的execute、complete中传递数据
    auto internetContext = new CallbackInternetContext{        
        .asyncWork = nullptr
    };
    if (internetContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfInternet new internetContext fail!");
        return nullptr;
    }

    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    // 网络图片地址
    size_t internetPicSize;
    char internetPicBuf[512];
    napi_get_value_string_utf8(env, args[0], internetPicBuf, sizeof(internetPicBuf), &internetPicSize);
    std::string internetPicUrl(internetPicBuf, internetPicSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet 网络图片路径：%{public}s", internetPicBuf);
    internetContext->internetPicUrl = internetPicUrl;
    
    // 保存文件沙箱目录
    size_t targetDirectorSize;
    char targetDirectoryBuf[512];
    napi_get_value_string_utf8(env, args[1], targetDirectoryBuf, sizeof(targetDirectoryBuf), &targetDirectorSize);
    std::string targetDirectory(targetDirectoryBuf, targetDirectorSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfInternet 保存路径：%{public}s", targetDirectoryBuf);
    internetContext->sandboxDir = targetDirectory;

    // 沙箱中的图片名
    size_t fileNameSize;
    char fileNameBuf[512];
    napi_get_value_string_utf8(env, args[2], fileNameBuf, sizeof(fileNameBuf),
                               &fileNameSize);
    std::string fileName(fileNameBuf, fileNameSize);
    internetContext->FileName = fileName;

    // 将接收到的参数传入用户自定义上下文数据
    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[3], &valueType);
    if (valueType != napi_function) {
        OH_LOG_ERROR(LOG_APP, "saveImageOfInternet param[3] is not function");
        return nullptr;
    }
    napi_create_reference(env, args[3], 1, &internetContext->callbackRef);

    // 创建async work，创建成功后通过最后一个参数接收async work的handle
    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "InternetCallback", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env, nullptr, resourceName, InternetCallbackExecuteCB, InternetCallbackCompleteCB,
                           (void *)internetContext, &internetContext->asyncWork);
    // 将刚创建的async work加到队列，由底层去调度执行
    napi_queue_async_work(env, internetContext->asyncWork);
    // 原生方法返回空对象
    napi_value result = 0;
    napi_get_null(env, &result);
    return result;
}

// 业务逻辑处理函数，执行耗时任务，由worker线程池调度执行。
static void RawFileCallbackExecuteCB(napi_env env, void *data) {
    CallbackRawFileContext *rawFileContext = (CallbackRawFileContext *)data;
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile rawFileContext is null");
        return;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile Begin");    

    // 打开Rawfile文件。
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(rawFileContext->resMgr,
        rawFileContext->rawFileName.c_str());
    if (rawFile == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile OpenRawFile fail!");
        // 释放资源
        OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
        return;
    }
    // 获取文件大小
    long imageDataSize = OH_ResourceManager_GetRawFileSize(rawFile);
    // 申请内存
    std::unique_ptr<char[]> imageData = std::make_unique<char[]>(imageDataSize);
    // TODO：知识点：通过Rawfile的API接口读取Rawfile文件
    long rawFileOffset = OH_ResourceManager_ReadRawFile(rawFile, imageData.get(), imageDataSize);
    // 保存目标网络图片的沙箱路径
    std::string targetSandboxPath = rawFileContext->sandboxDir + rawFileContext->rawFileName;
    // TODO：知识点：通过std::ofstream，将读取的数据写入沙箱文件
    std::ofstream outputFile(targetSandboxPath, std::ios::binary);
    if (!outputFile) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile 创建沙箱目标文件失败");
        // 释放资源
        OH_ResourceManager_CloseRawFile(rawFile);
        OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
        return;
    }
    // 写文件
    outputFile.write(imageData.get(), imageDataSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile 图片写入沙箱成功，沙箱路径：%{public}s",
                 targetSandboxPath.c_str());
    // 关闭文件
    outputFile.close();
    // 释放资源
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
    // 返回沙箱路径
    rawFileContext->result = targetSandboxPath;
}

// 业务逻辑处理完成回调函数，在业务逻辑处理函数执行完成或取消后触发，由EventLoop线程中执行。
static void RawFileCallbackCompleteCB(napi_env env, napi_status status, void *data) {
    CallbackRawFileContext *rawFileContext = (CallbackRawFileContext *)data;
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile rawFileContext is null");
        return;        
    }
    napi_value callback = nullptr;
    napi_get_reference_value(env, rawFileContext->callbackRef, &callback);    
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);    
    napi_value callbackResult = nullptr;
    napi_value result;
    napi_create_string_utf8(env, rawFileContext->result.c_str(), NAPI_AUTO_LENGTH, &result);
    // 执行回调函数
    napi_call_function(env, undefined, callback, 1, &result, &callbackResult);
    // 删除napi_ref对象
    if (rawFileContext->callbackRef != nullptr) {
        napi_delete_reference(env, rawFileContext->callbackRef);
    }
    // 删除异步工作项
    napi_delete_async_work(env, rawFileContext->asyncWork);
    delete rawFileContext;
}

/**
 * rawfile文件保存到沙箱路径
 * @param env
 * @param info
 * @return 返回图片保存的沙箱地址
 */
static napi_value SaveImageOfRawfileCallback(napi_env env, napi_callback_info info) {
    // 异步工作项上下文用户数据，传递到异步工作项的execute、complete中传递数据
    auto rawFileContext = new CallbackRawFileContext{        
        .asyncWork = nullptr
    };
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "saveImageOfRawfile new rawFileContext fail!");
        return nullptr;
    }

    size_t argc = 4;
    napi_value args[4];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    // 初始化native resource manager
    rawFileContext->resMgr = OH_ResourceManager_InitNativeResourceManager(env, args[0]);
    // 获取rawfile中图片文件名
    size_t rawFileNameSize;
    char rawFileNameBuf[512];
    napi_get_value_string_utf8(env, args[1], rawFileNameBuf, sizeof(rawFileNameBuf), &rawFileNameSize);
    std::string rawFileName(rawFileNameBuf, rawFileNameSize);
    rawFileContext->rawFileName = rawFileName;
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile rawfileName :%{public}s", rawFileName.c_str());

    // 获取保存文件的目标目录
    size_t targetDirectorSize;
    char targetDirectoryBuf[512];
    napi_get_value_string_utf8(env, args[2], targetDirectoryBuf, sizeof(targetDirectoryBuf), &targetDirectorSize);
    std::string targetDirectory(targetDirectoryBuf, targetDirectorSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "saveImageOfRawfile targetPath:%{public}s", targetDirectoryBuf);
    rawFileContext->sandboxDir = targetDirectory;
    
    // 将接收到的参数传入用户自定义上下文数据
    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[3], &valueType);
    if (valueType != napi_function) {
        OH_LOG_ERROR(LOG_APP, "saveImageOfRawfile param[3] is not function");
        return nullptr;
    }
    napi_create_reference(env, args[3], 1, &rawFileContext->callbackRef);
   
    // 创建async work，创建成功后通过最后一个参数接收async work的handle
    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "rawFileCallback", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env, nullptr, resourceName, RawFileCallbackExecuteCB, RawFileCallbackCompleteCB,
                           (void *)rawFileContext, &rawFileContext->asyncWork);
    // 将刚创建的async work加到队列，由底层去调度执行
    napi_queue_async_work(env, rawFileContext->asyncWork);
    // 原生方法返回空对象
    napi_value result = 0;
    napi_get_null(env, &result);
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // TODO：知识点：napi_property_descriptor 为结构体，做用是描述扩展暴露的 属性/方法 的描述。
    napi_property_descriptor desc[] = {
        {"saveImageOfInternetCallback", nullptr, SaveImageOfInternetCallback, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"saveImageOfRawfileCallback", nullptr, SaveImageOfRawfileCallback, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
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
