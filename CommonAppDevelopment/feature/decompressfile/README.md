# Worker子线程中解压文件

### 介绍

本示例介绍在[Worker](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-worker-0000001774121110)
子线程使用[@ohos.zlib](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-zlib-0000001774281346)
提供的zlib.decompressfile接口对沙箱目录中的压缩文件进行解压操作，解压成功后将解压路径返回主线程，获取解压文件列表。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/decompress_file.gif)

**使用说明**

1. 点击解压按钮，解压test.zip文件，显示解压结果。

### 实现思路

1. 在/src/main/ets/workers目录下创建Worker.ets线程文件，绑定Worker对象。源码参考[Worker.ets](./src/main/ets/workers/Worker.ets)

```ts
const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
```

2. 在build-profile.json5中进行配置Worker线程文件路径，Worker线程文件才能确保被打包到应用中。源码参考[build-profile.json5](build-profile.json5)

```json5
"buildOption": {
  "sourceOption": {
    "workers": [
      "./src/main/ets/workers/Worker.ets"
    ]
  }
}
```

3. 在主线程创建一个Worker线程，通过new worker.ThreadWorker()创建Worker实例，传入Worker.ets的加载路径。源码参考[MainPage.ets](./src/main/ets/view/MainPage.ets)

```ts
let workerInstance: worker.ThreadWorker = new worker.ThreadWorker('@decompressFile/ets/workers/Worker.ets');
```

4. 主线程使用postMessage()向worker线程发送应用沙箱路径和压缩文件名称。源码参考[MainPage.ets](./src/main/ets/view/MainPage.ets)

```ts
workerInstance.postMessage({ pathDir: this.pathDir, rawfileZipName: rawfileZipName });
```

5. 在Worker.ets文件中通过调用onmessage()方法接收主线程发送的应用沙箱路径和压缩文件名称。
```ts
workerPort.onmessage = (e: MessageEvents): void => {
  logger.info(TAG, `Worker onmessage：${JSON.stringify(e.data)}`);
  let pathDir: string = e.data.pathDir; // 沙箱目录
  let rawfileZipName: string = e.data.rawfileZipName; // 带.zip后缀的压缩文件名称
}
```
6. 使用fs.access判断输出目录是否已经存在，如果不存在使用fs.mkdirSync()创建空目录用于放置解压后的文件。空目录创建成功后使用zlib.decompressFile接口解压压缩文件，输出到空目录中。源码参考[Worker.ets](./src/main/ets/workers/Worker.ets)

```ts
fs.access(outFileDir).then((res: boolean) => {
  if (!res) {
    // TODO：知识点：使用fs.mkdirSync创建目录，用于存放解压后的文件。
    fs.mkdirSync(outFileDir);
    logger.info(TAG, 'mkdirSync succeed');
  }
  // TODO：知识点：使用zlib.decompressfile接口对沙箱目录中的压缩文件进行解压操作，解压至指定沙箱目录outFileDir。
  // 如果待解压的文件或文件夹在解压后的路径下已经存在，则会直接覆盖同名文件或同名文件夹中的同名文件。
  zlib.decompressFile(`${pathDir}/${rawfileZipName}`, outFileDir, (errData: BusinessError) => {
    if (errData !== null) {
      logger.error(TAG, `decompressFile failed. code is ${errData.code}, message is ${errData.message}`);
    } else {
      logger.info(TAG, `decompressFile succeed. outFileDir is ${outFileDir}`);
      // TODO：知识点：Worker线程向主线程发送信息。
      workerPort.postMessage(outFileDir);
    }
  })
}).catch((err: BusinessError) => {
  logger.error(TAG, `access failed with error message: ${err.message}, error code: ${err.code}`);
});
```

### 高性能知识点

1. 本示例使用了LazyForEach进行数据懒加载，List布局时会根据可视区域按需创建ListItem组件，并在ListItem滑出可视区域外时销毁以降低内存占用。参考文章[正确使用LazyForEach优化](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/)
2. 本示例使用在Work子线程中使用zlib.decompressFile解压文件，避免阻塞主线程的运行。参考文章[多线程能力场景化示例实践](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/multi_thread_capability.md/)。

### 工程结构&模块类型

   ```
   decompressFile                                // har类型
   |---/src/main/ets/model                        
   |   |---FileListDataSource.ets                // 数据模型层-列表数据模型 
   |   |---FileItemModel.ets                     // 数据模型层-列表项数据模型
   |---/src/main/ets/view                        
   |   |---MainPage.ets                          // 视图层-场景列表页面
   |---/src/main/ets/workers                        
   |   |---Worker.ets                            // Worker线程
   ```

### 模块依赖

1. 本实例依赖common模块来获取[日志工具类logger](../../common/utils/src/main/ets/log/Logger.ets)。

### 参考资料

[@ohos.worker(启动一个Worker)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-worker-0000001774121110)

[@ohos.zlib(Zip模块)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-zlib-0000001774281346)

[@ohos.file.fs(文件管理)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-file-fs-0000001820881405)