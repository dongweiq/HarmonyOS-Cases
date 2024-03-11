# NAPI封装ArkTS接口案例

### 介绍

部分应用的主要开发语言为C/C++，但是HarmonyOS的部分接口仅以ArkTS的形式暴露，因此需要将ArkTS的接口封装为Native接口。本例以DocumentViewPicker的Select方法为例，提供了Napi封装ArkTS
API的通用方法，本例包含内容如下：

1. Native侧与ArkTS侧的相互调用
2. Native对象转换为ArkTS对象（包括如何在ArkTS侧调用一般形式的Native方法）
3. 线程安全函数的使用
4. 等待线程安全函数的执行结果
5. 多实例情况下，如何在正确的窗口内执行方法

### 效果图预览

![](../../product/entry/src/main/resources/base/media/ets_wrapper.gif)

**测试说明**：

1. 点击"JS线程调用"按钮，从native侧js线程拉起picker
2. 点击"PThread线程调用"按钮，从native侧pthread子线程中拉起picker
3. 拉起picker后，单击直接选择单个文件，长按可选择多个文件
4. 本例在拉起picker时设置了maxSelectNumber=3，最多个选择3个文件

**集成说明**：

1. 源码集成
2. 参考[aki方式](https://gitee.com/openharmony-sig/aki.git)集成

**使用说明**：

1. [建议]在EntryAbility之外调用registryDocumentViewPickerFn方法，避免多实例下的重复注册
2. [必须]给每个UIAbility生成唯一的ID属性，可使用generateAbilityID方法
3. [必须]在UIAbility的onWindowStageCreate中的windowStage.loadContent的回调中调用addUIContext方法
4. [必须]在UIAbility的onWindowStageCreate中的windowStage.loadContent之后调用setTopAbilityID
5. [建议]在UIAbility的onWindowStageDestroy中调用removeUIContext方法

### 实现思路

1. native侧需要主动调用ets侧的代码，需要将ets侧代码注入到native侧，并在注册时创建函数的引用及线程安全函数，并保存当前线程（js线程）的id及env供后续调用时使用

   ets侧：
   ```typescript
   etswrapper.registryDocumentViewPickerFn(documentViewPickerSelect, documentViewPickerSave);
   ```
   native侧：
   ```cpp
   NODE_API_CALL(env, napi_create_threadsafe_function(env, args[0], nullptr, selectWork, 0, 1, nullptr, nullptr,
      nullptr, tsfn::callJSSelect, &(uniContext->selectTsfn)));
   NODE_API_CALL(env, napi_create_threadsafe_function(env, args[1], nullptr, saveWork, 0, 1, nullptr, nullptr,
      nullptr, tsfn::callJSSave, &(uniContext->saveTsfn)));
   NODE_API_CALL(env, napi_create_reference(env, args[0], 1, &(uniContext->selectRef)));
   NODE_API_CALL(env, napi_create_reference(env, args[1], 1, &(uniContext->saveRef)));
   uniContext->pickerEnv = env;
   uniContext->jsThreadID = fns::getCurrentThreadID();
   ```

2. 对于某些有返回值的ets函数，为了获取其返回值，需要对调用线程进行区分：如果是js线程，直接通过napi_call_function发起调用并获得返回值；否则需要等异步线程执行完毕并通过全局变量获取结果然后返回
   ```cpp
   if (uniContext->jsThreadID != fns::getCurrentThreadID()) {
        status = napi_acquire_threadsafe_function(uniContext->selectTsfn);
        status = napi_call_threadsafe_function(uniContext->selectTsfn, selectParam, napi_tsfn_blocking);
        std::unique_lock<std::mutex> unil(uniContext->resultWaitUtil.lock);
        uniContext->resultWaitUtil.cv.wait(unil, [] { return uniContext->resultWaitUtil.isFinished; });
        return;
    } else {
        status = napi_call_function(uniContext->pickerEnv, nullptr, tsSelect, 4, args, &result);
    }
   ```

3. 因为napi中的线程安全函数只能通过napi_threadsafe_function_call_js中的data参数进行传参，因此需要将所需参数全部封装到一个对象中
   ```cpp
   DocumentViewPickerSelectParam *selectParam = new DocumentViewPickerSelectParam(options, thenWrapper, catchWrapper)
   ```

4. 因为本例中的filepicker是异步的，回调函数需要调用者传入，而napi中若需要将native方法直接封装为ets方法对于函数类型是有要求的。因此这里通过将回调函数封装到对象中，通过对象包装来实现将一般类型的函数封装为ets侧的函数：

   native侧：
   
   ```cpp
   // step：类型声明
   class DocumentViewPickerSelectThenCbWrapper {
   public:
       documentSelectThenFn thenFn;
       DocumentViewPickerSelectThenCbWrapper(documentSelectThenFn fn) : thenFn(fn) {}
       /**
        * 将对象实例包装为js对象
        */
       napi_value convert2NapiValue(napi_env env);
       /**
        * 参数是string[]，这里面会调用thenFn，ets侧调用
        */
       static napi_value call(napi_env env, napi_callback_info info);
   };
   // step2：convert2NapiValue方法实现
   napi_value etswrapper::DocumentViewPickerSelectThenCbWrapper::convert2NapiValue(napi_env env) {
       napi_value object;
       DocumentViewPickerSelectThenCbWrapper *thenWrapper = new DocumentViewPickerSelectThenCbWrapper(this->thenFn);
       NODE_API_CALL(env, napi_create_object(env, &object));
       NODE_API_CALL(env, napi_wrap(
                              env, object, thenWrapper,
                              [](napi_env env, void *finalize_data, void *finalize_hint) -> void {
                                  delete reinterpret_cast<DocumentViewPickerSelectThenCbWrapper *>(finalize_data);
                              },
                              nullptr, nullptr));
       napi_property_descriptor desc[] = {
           {"call", nullptr, DocumentViewPickerSelectThenCbWrapper::call, nullptr, nullptr, nullptr, napi_default,
            nullptr},
       };
       NODE_API_CALL(env, napi_define_properties(env, object, sizeof(desc) / sizeof(*desc), desc));
       return object;
   }
   // step3：call方法实现
   napi_value etswrapper::DocumentViewPickerSelectThenCbWrapper::call(napi_env env, napi_callback_info info) {
       // ...
       napi_value thisArg;
       NODE_API_CALL(env, napi_get_cb_info(env, info, &argc, args, &thisArg, nullptr));
       DocumentViewPickerSelectThenCbWrapper *thenWrapper;
       NODE_API_CALL(env, napi_unwrap(env, thisArg, reinterpret_cast<void **>(&thenWrapper)));
       // ...
       thenWrapper->thenFn(data);
       return nullptr;
   }
   ```
   
   ets侧：
   
   ```typescript
   function documentViewPickerSelect(uiContext: UIContext, options: picker.DocumentSelectOptions, thenWrapper:
   StringArrayThenCbWrapper, catchWrapper: CatchCbWrapper): void {
     let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
     documentViewPicker.select(options).then((value: string[]) => {
       thenWrapper.call(value);
     }).catch((error: BusinessError) => {
       // ...
     })
   }
   ```

5. 多实例情况下，需要在正确的窗口/UIAbility内执行方法。本例通过监听windowStage的状态加上UIContext.runScopedTask方法来实现：

   ```typescript
   // step1：
   windowStage.on("windowStageEvent", (data: window.WindowStageEventType) => {
     if (data === window.WindowStageEventType.ACTIVE) {
       etswrapper.setTopAbilityID(abilityID);
     }
   }
   
   // step2：
   function documentViewPickerSelect(uiContext: UIContext, options: picker.DocumentSelectOptions, thenWrapper:
   StringArrayThenCbWrapper, catchWrapper: CatchCbWrapper): void {
     uiContext.runScopedTask(() => {
       // ...
     })
   }
   ```

### 工程结构&模块类型

```
   dragtoswitchpictures                             // har包
   |---cpp                                          // cpp源码
   |   |---include                                  // 头文件
   |   |---src                                      // 源码
   |---ets/view
   |   |---MockNativeCallPickerView.ets             // 模拟cpp侧发起调用
   |---ets/wrapper
   |   |---wrapper.ets                              // 封装的js方法
```

### 模块依赖

1. [routermodule](../routermodule)：模块动态导入使用
2. [common/utils](../../common/utils)：使用功能描述组件

### 高性能知识点

**不涉及**

### 参考资料

1. [NAPI](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/node-api_u5b9e_u73b0_u8de8_u8bed_u8a00_u4ea4_u4e92-0000001774120790)
2. [aki](https://gitee.com/openharmony-sig/aki.git)

### 其他说明

1. 本例仅实现了DocumentViewPicker的Select方法，对于Save方法，本例搭建了整体框架，因其实现流程基本与Select方法别无二致，因此本例没有具体实现
2. TODO：当前使用的是windowStage.on("windowStageEvent")
   来获取当前活跃窗口对应的UIContext，从理论上来讲，因为事件的处理流程有如下两条并行路径，因此在2in1设备的多实例场景下，直接点击失焦窗口的按钮时，可能会在错误的窗口内响应事件:
   ```text
                    |->焦点切换->on事件分发
   多模事件输入->窗口管理
                    |->arkui->button事件触发
   ```