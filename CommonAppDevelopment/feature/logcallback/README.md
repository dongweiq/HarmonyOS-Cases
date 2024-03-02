# ArkTS日志回调

### 介绍

本示例介绍ArkTS端如何注册、关闭hilog日志回调，用以确定自定义的功能接口是否被调用。由于ArkTS没有注册日志回调的接口，示例通过Native来注册日志回调，并在Native的自定义日志处理函数中过滤关键日志后回调ArkTS端的回调函数。

### 效果图预览

**不涉及**

**使用说明**：

1. 在product工程的ohosTest中启动Ability.test.ets来验证开启日志回调、关闭日志回调两个测试用例是否成功。

## 实现思路

1. 在Native中实现注册日志回调函数。

   ```cpp
   static napi_value SetLogCallBack(napi_env env, napi_callback_info info) {
       size_t argc = 2;
       napi_value args[2] = {nullptr};
       napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
       // 解析要过滤的日志
       size_t logSize;
       napi_get_value_string_utf8(env, args[0], logToFiter, MAX_LOG_LEN, &logSize);
   
       // 解析ArkTS端的回调函数
       napi_valuetype valueType = napi_undefined;
       napi_typeof(env, args[1], &valueType);
       if (valueType != napi_function) {
           OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "SetLogCallBack fail，param2 is not a function！");
           return nullptr;
       }
       // 创建ArkTS端回调函数的引用
       napi_create_reference(env, args[1], 1, &callbackRef);
       g_env = env;
       // 注册日志回调接口
       OH_LOG_SetCallback(MyHiLog);
       s_functionCallNum = 0;    // 重新初始化接口调用次数
       OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack SetCallback end");
       return nullptr;
   }
   ```

2. 在Native中实现自定义日志处理函数。

   ```cpp
   static void MyHiLog(const LogType type, const LogLevel level, const unsigned int domain, const char *tag,
                    const char *msg) {
    std::string strMsg(msg, strlen(msg) + 1);    
    // 过滤要查找的日志
    size_t foundIndex = strMsg.find(logToFiter);
    if (foundIndex != -1) {
        napi_value callback = nullptr;
        napi_get_reference_value(g_env, callbackRef, &callback);
        napi_value retArg;
        s_functionCallNum += 1;
        napi_create_int32(g_env, s_functionCallNum, &retArg);        
        napi_value ret;
        // TODO: 知识点： 调用ArkTS端的回调函数
        napi_call_function(g_env, nullptr, callback, 1, &retArg, &ret);
    }
    return;
   }
   ```

3. 在Native中实现关闭日志回调功能。

   ```cpp
   static napi_value CancelLogCallBack(napi_env env, napi_callback_info info) {
       // 关闭日志回调
       OH_LOG_SetCallback(nullptr);
       OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack CancelLogCallBack end");
       return nullptr;
   }
   ```

4. 在Native中实现调用功能接口。

   ```cpp
   static napi_value CallMyfunction(napi_env env, napi_callback_info info) {
       OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "TestLogCallBack [%{public}s]", logToFiter);
       // TODO: 业务处理
       return nullptr;
   }
   ```

5. 将以上Native功能封装成一个ts接口logCallBack。

   ```typescript
   import testNapi from 'liblogcallback.so';
   let functionCallNum : number = 0;    // native中callMyfunction接口被调用的次数
   
   export class LogCallBack {
     // TODO: 知识点： ArkTS日志回调函数，param参数为callMycunction接口被调用的次数
     CallBack(param: number) {
       functionCallNum = param;
     }
   
     GetFunctionCallNum() : number {
       return functionCallNum;
     }
   
     // TODO: 知识点： 注册日志回调函数
     RegCallBack(strLog: string) : void {
       functionCallNum = 0;
       testNapi.setLogCallBack(strLog, this.CallBack);
     }
   
     // TODO: 知识点： 关闭日志回调
     CancelCallBack() : void {
       testNapi.cancelLogCallBack();
     }
   
     // TODO: 知识点： 调用native的中的接口
     CallMyfunction() : void {
       testNapi.callMyfunction();
     }
   }
   ```
   
6. 在product工程中实现测试用例编写。

   ```typescript
   it('testLogcallback_001',0, async () => {
      const logCall: LogCallBack = new LogCallBack();
      // 注册日志回调函数,参数为要监听的日志内容。同时清空接口调用次数
      logCall.RegCallBack("testMyfunction");
      // 获取接口调用之前被调用的次数
      let numCallBefore: number = logCall.GetFunctionCallNum();
      logger.info(TAG, 'TestLogCallBack RegCallBack call begin, callNum:' + numCallBefore.toString());
      // 调用接口
      logCall.CallMyfunction();
      // 获取接口调用之后被调用的次数
      let numCallAfter: number = logCall.GetFunctionCallNum();
      logger.info(TAG, 'TestLogCallBack RegCallBack call end, callNum:' + numCallAfter.toString());
      // 校验前后数据差1
      expect(numCallBefore + 1).assertEqual(numCallAfter);
    })   
   
    it('testLogcallback_002',0, async () => {
      const logCall: LogCallBack = new LogCallBack();
      // 关闭日志回调功能
      logCall.CancelCallBack();
      // 获取接口调用之前被调用的次数
      let numCallBefore: number = logCall.GetFunctionCallNum();
      logger.info(TAG, 'TestLogCallBack CancelCallBack call begin, callNum:' + numCallBefore.toString());
      // 调用接口
      logCall.CallMyfunction();
      // 获取接口调用之后被调用的次数
      let numCallAfter: number = logCall.GetFunctionCallNum();
      logger.info(TAG, 'TestLogCallBack CancelCallBack call end, callNum:' + numCallAfter.toString());
      // 校验前后数据相等
      expect(numCallBefore).assertEqual(numCallAfter);
    })
   ```
   
### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   logcallback                           // har类型
   |---src\main\ets\model\
   |   |---logCallBack.ets               // ArkTS层- ts接口
   |---src\main\cpp\
   |   |---logcallback.cpp               // native层-日志回调业务逻辑   
   
   ..\product\src\ohosTest               // 测试用例工程
   |---ets\test\
   |   |---Ability.test.ets              // 测试用例
   ```

### 模块依赖

**不涉及**

### 参考资料

[日志回调注册函数](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/dfx/hilog-guidelines-ndk.md)
