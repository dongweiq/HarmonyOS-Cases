# 读取Rawfile文件中部分内容

### 介绍

本示例主要介绍Native如何通过pread系统函数来读取Rawfile中文本文件部分内容，以及如何在Native中加入hilog日志。

### 效果图预览

![](../../screenshots/device/raw_file.gif)

**使用说明**

1. rawfile路径下存在一个有内容的文本文件rawfile.txt。
2. 输入开始读取位置、需要读取的长度，点击“开始读取”，即可通过调用Native侧暴露的getRawFileContent接口把读取到的内容显示在界面上。

具体代码可参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)。

### 实现思路

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
         this.rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', this.ReadStartPos, this.readLength);
   }).margin($r('app.string.rawfile_margin'))
   ```

2. 在Native的getRawFileContent接口中通过Rawfile的API接口以及pread函数读取Rawfile文件部分内容。
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
   |---src\main\ets\components\mainpage\
   |   |---MainPage.ets                        // 视图层-Rawfile场景主页面
   |---src\main\cpp\
   |   |---nativeRawFile.cpp                   // native层-读取Rawfile文件部分内容业务逻辑
   ```

### 模块依赖
1. 本实例依赖common模块来实现[公共组件FunctionDescription](../../common/utils/src/main/ets/FunctionDescription.ets)。

### 参考资料 
[公共组件FunctionDescription](../../common/utils/src/main/ets/FunctionDescription.ets)
