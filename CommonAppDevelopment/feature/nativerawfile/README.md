# 预加载so并读取RawFile文件

### 介绍

本示例主要介绍在TaskPool子线程中使用 dlopen 预加载 so 库并使用句柄调用库函数的方法，以及在Native中使用 pread 系统函数读取Rawfile文件的部分文本内容，并添加 HiLog 日志。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/raw_file.gif)

**使用说明**

1. rawfile路径下存在一个有内容的文本文件rawfile.txt。
2. 输入开始读取位置、需要读取的长度，点击“开始读取”，即可通过调用Native侧暴露的getRawFileContent接口把读取到的内容显示在界面上。

具体代码可参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)。

### 实现思路

#### 在TaskPool子线程中使用dlopen预加载so库和使用句柄调用so库函数的方式

1. 将需要加载的.so文件放到工程中，在CMakeLists中使用target_link_directories命令将包含这些库文件的目录添加到预加载库的链接目录。

    ```c++
    target_link_directories(preloadso PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/)
    ```

2. 使用target_link_libraries命令将需要预加载的so库链接到项目中。

    ```c++
    target_link_libraries(preloadso PUBLIC libhilog_ndk.z.so libace_napi.z.so global_handlers libnativerawfile.so)
    ```

3. 定义一个全局对象global_handlers用于存放加载so库所得句柄，其他需要使用global_handlers的cpp文件需要引入定义全局对象的头文件。

    ```c++
    std::unordered_map<std::string, void *> global_handlers;
    ```

4. 在 Native 层的 Preload 接口中，遍历传入的 .so 路径数组，使用 dlopen 函数加载库，并将句柄保存到 global_handlers 中。

    ```c++
    // 获取传入的so库路径数组的长度
    uint32_t arrayLength;
    napi_get_array_length(env, args[0], &arrayLength);
    for (uint32_t i = 0; i < arrayLength; i++) {
        napi_get_element(env, args[0], i, &pathString); // 获取数组的第 i 个元素
        napi_status status = napi_get_value_string_utf8(env, pathString, path, sizeof(path), &pathLength);
        if (status != napi_ok) {
            // 处理获取路径失败的情况
            continue;
        }
        // TODO：知识点：使用dlopen动态加载so库，返回so库的句柄
        void *handler = dlopen(path, RTLD_LAZY);
        if (handler == nullptr) {
            // TODO：知识点：dlerror抛出加载库失败的错误
            dlerror();
            continue; // 加载下一个
        }
        // 将句柄保存到全局对象global_handlers中
        global_handlers[std::string(path)] = handler;
    }
    ```

5. 暴露Preload接口给ArkTS层使用，使其能够通过preload调用Native层的Preload接口。

    ```c++
    napi_property_descriptor desc[] = {{"preload", nullptr, Preload, nullptr, nullptr, nullptr, napi_default, nullptr}};
    ```

6. ArkTS层使用TaskPool创建子线程，通过preload接口调用Native侧的Preload接口，实现在TaskPool子线程中加载.so库，导出preloadSOByTaskPool函数。

    ```typescript
    @Concurrent
    function preloadSO(): string[] {
      return napi.preload(Constants.LIBRARY_PATH_ARRAY);
    }
    export function preloadSOByTaskPool(): void {
      // TODO: 知识点：使用new taskpool.Task()创建任务项，传入任务执行函数和所需参数
      let task: taskpool.Task = new taskpool.Task(preloadSO);
      try {
        // TODO：知识点：使用taskpool.execute将待执行的函数放入TaskPool内部任务队列等待执行
        taskpool.execute(task, taskpool.Priority.HIGH).then((res: string[]) => {
        // so库预加载完成的处理
        logger.info(TAG, '%{public}s', 'PreloadSOByTaskPool：' + JSON.stringify(res));
        })
      } catch (err) {
         logger.error(TAG, "PreloadSOByTaskPool: execute failed, " + (err as BusinessError).toString());
      }
    }
    ```

7. 在Ability的onCreate生命周期函数中，调用preloadSOByTaskPool开启子线程，完成so库的预加载。
```typescript
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        // 在TaskPool子线程预加载so
        preloadSOByTaskPool();
    }
```

8. 后续可以通过句柄使用so库中的函数。

- 在Native层引入头文件global_handlers.h。

    ```c++
    #include "global_handlers.h"
    ```
- 编写napi接口，用于实现ArkTS层和so库之间的交互

    ```c++
    static napi_value GetTotalRawFileContent(napi_env env, napi_callback_info info){}
    static napi_value GetRawFileContent(napi_env env, napi_callback_info info) {}
    ```

- 在napi接口中从全局对象global_handlers中取出对应so库的句柄。

    ```c++
    // 从全局对象中获取指定so库的句柄
    void *handler = global_handlers["libnativerawfile.so"];
    ```

- 句柄不为空时，使用dlsym查找和调用so库中的符号。

    ```c++
    // TODO：知识点：使用dlsym查找和调用so库中的符号
    GetTotalRawFileContentWrapperFunc getTotalRawFileContentWrapper =
        reinterpret_cast<GetTotalRawFileContentWrapperFunc>(dlsym(handler, "GetTotalRawFileContentWrapper"));
    if (getTotalRawFileContentWrapper) {
        // 调用 GetRawFileContentWrapper 函数
        napi_value result = getTotalRawFileContentWrapper(env, info);
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, " GetRawFileContentWrapper finish");
        return result;
    } else {
        // 处理无法获取函数指针的情况
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, " GetTotalRawFileContentWrapper fn failed");
        return nullptr;
    }
    ```

- 在ArkTS层调用编写的napi接口，就可以使用so库导出的函数

    ```typescript
    this.rawfileContent = nativeRawfileApi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', 2, 5);
    ```

#### Native中加入hilog日志的实现主要步骤如下

1. 在CMakeLists中通过target_link_libraries导入日志模块libhilog_ndk.z.so。

   ```c++
   target_link_libraries(nativerawfile PUBLIC libace_napi.z.so libhilog_ndk.z.so librawfile.z.so)
   ```

2. 在需要打印hilog日志的cpp文件开头引入头文件 #include "hilog/log.h"。

   ```c
   #include "hilog/log.h"
   ```

3. 在需要打印日志的地方通过OH_LOG_Print打印日志。日志级别有LOG_INFO、LOG_ERROR等

   ```c++
   OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContent Begin");
   ```

#### Native读取Rawfile中文本文件部分内容主要步骤如下：

1. 在前端通过调用Native中的getRawFileContent接口读取文件部分内容。传入的参数为文件名、开始读取位置、读取文件长度。

   ```typescript
   Button($r('app.string.ReadButton'))
     .onClick(()=> {
        this.rawfileContent = nativeRawfileApi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', this.ReadStartPos, this.readLength);
   }).margin($r('app.string.rawfile_margin'))
   ```

2. 在Native侧native_rawfile.cpp的getRawFileContent接口中通过Rawfile的API接口以及pread函数读取Rawfile文件部分内容。
   ```c++
    // TODO 知识点：通过pread读取文件部分内容。
    if ((ret = pread(descriptor.fd, buf, lenContent,  descriptor.start + startPos)) == -1) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetRawFileContent pread error!");
    } else {
        buf[lenContent] = '\0';
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "GetRawFileContent: %{public}ld: %{public}ld: %{public}s\n",
                     descriptor.start, len, buf);
    }
   ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   nativerawfile                               // har类型
   |---libs\
   |   |---arm64-v8a\libnativeRawFile.so       // arm64-v8a类型so库
   |   |---armeabi-v7a\libnativeRawFile.so     // armeabi-v7a类型so库
   |   |---x86_64\libnativeRawFile.so          // x86_64类型so库
   |---src\main\ets\components\mainpage\
   |   |---MainPage.ets                        // 视图层-Rawfile场景主页面
   |---src\main\ets\utils\
   |   |---Constants.ets                       // 常量数据
   |   |---TaskPool.ets                        // TaskPool子线程加载so库
   |---src\main\cpp\
   |   |---include\global_handlers.h           // native层-全局句柄头文件
   |   |---global_handlers.cpp                 // native层-定义全局句柄对象
   |   |---preloadso.cpp                       // native层-加载libnativeRawFile.so业务逻辑
   |   |---nativeRawFile.cpp                   // native层-读取Rawfile文件部分内容业务逻辑，libnativeRawFile.so源代码
   |   |---native_rawfile_api.cpp              // native层-libnativeRawFile.so和ArkTS中间层接口
   ```

### 模块依赖

1. 本实例依赖common模块来实现[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)。

### 参考资料

[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)
