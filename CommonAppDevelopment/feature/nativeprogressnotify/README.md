# 在Native侧实现进度通知功能

### 介绍

本示例通过模拟下载场景介绍如何将Native的进度信息实时同步到ArkTS侧。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/native_progress_notify.gif)

**使用说明**

1. 点击“Start Download“按钮后，Native侧启动子线程模拟下载任务
2. Native侧启动子线程模拟下载，并通过Arkts的回调函数将进度信息实时传递到Arkts侧

### 实现思路

1. 前端进度条使用Progress绘制
    ```typescript
    Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
        .width($r("app.integer.progress_size"))
        .height($r("app.integer.progress_size"))
        .animation({ duration: NativeProgressNotifyConstants.PROGRESS_ANIMATION_DURATION, curve: Curve.Ease })
        .style({ strokeWidth: 15 })
    ```
1. JS侧调用Native侧方法，并传入用于接收下载进度的回调函数，在该回调函数中更改状态变量
   ```typescript
   naitiveprogressnotify.startDownload((data: number) => {
       this.progress = data;
       console.info("[NativeProgressNotify]progress:" + this.progress);
   })
   ```
1. Naitive侧使用std::thread创建子线程执行模拟下载的任务
   ```cpp
   std::thread downloadThread(downloadTask, asyncContext);
   downloadThread.detach();
   ```
1. Native侧模拟下载的线程中，每100ms执行一次uv_queue_work；向eventloop事件堆栈push异步任务。
   ```cpp
    while (context && context->progress < 100) {
        context->progress += 1;
        napi_acquire_threadsafe_function(tsfn);
        napi_call_threadsafe_function(tsfn, (void *)context, napi_tsfn_blocking);
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
   ```
1. 在模拟下载任务的子线程中，调用napi_call_function来执行Arkts回调，向Arkts侧传递进度信息
   ```cpp
    napi_create_int32(arg->env, arg->progress, &progress);
    napi_call_function(arg->env, nullptr, jsCb, 1, &progress, nullptr);
   ```

### 高性能知识点

本例中，在Native侧使用子线程执行下载任务，从而避免对主线程资源的占用，能有效提升性能

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