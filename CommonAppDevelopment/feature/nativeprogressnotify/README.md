# Native侧进度通知到Arkts

### 介绍

本示例通过模拟下载场景介绍如何将Native的进度信息实时同步到Arkts侧。

### 效果图预览

// TODO 重新截图
![](../../product/entry/src/main/resources/base/media/VerifyCode.gif)

**使用说明**

1. 点击“Start Download“按钮后，Native侧启动子线程模拟下载任务
2. Native侧通过Arkts的回调函数将进度信息实时传递到Arkts侧

### 实现思路

1. 前端进度条使用Progress绘制
    ```typescript
    Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
                .width($r("app.integer.progress_size"))
                .height($r("app.integer.progress_size"))
                .animation({ duration: NativeProgressNotifyConstants.PROGRESS_ANIMATION_DURATION, curve: Curve.Ease })
                .style({ strokeWidth: 15 })
    ```
1. JS侧调用Native侧方法，并传入用于接收下载进度的回调函数
   ```typescript
   naitiveprogressnotify.startDownload((data: number) => {
                 this.progress = data;
                 console.log("[NativeProgressNotify]progress:" + this.progress);
               })
   ```
1. Naitive侧使用std::thread启动下载线程
   ```typescript
   std::thread downloadThread(downloadTask, asyncContext);
   downloadThread.detach();
   ```
1. Native侧模拟下载的线程中，每100ms执行一次uv_queue_work；向eventLoop事件堆粘push异步任务after_work_cb
   ```typescript
   while (context && context - > progress < 100) {
        uv_queue_work(
           // ...
        );
        // 睡眠100ms
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
   ```
1. 异步任务中，调用napi_call_function来执行Arkts回调，向Arkts侧传递进度信息
   ```typescript
   napi_value callback;
    napi_get_reference_value(context->env, context->callbackRef, &callback);
    napi_value retArg;
    napi_create_int32(context->env, context->progress, &retArg);
    napi_value ret;
    napi_call_function(context->env, nullptr, callback, 1, &retArg, &ret);
   ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   verifycode                                       // har类型
   |---constants
   |   |---NativeProgressNotifyContants.ets         // 常量
   |---view
   |   |---NativeProgressNotify.ets                 // 视图层
   ```

### 模块依赖

**不涉及**

### 参考资料

1. [Progress](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-progress-0000001820880889)
2. [Napi](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/napi-introduction-0000001821000409)
3. [libuv](https://libuv-docs-chinese.readthedocs.io/zh/latest/api.html)