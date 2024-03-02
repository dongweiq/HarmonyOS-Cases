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

/**
 * 1. 通过调用Native的setLogCallBack接口实现日志回调注册
 * 2. 定义ArkTS端的回调函数CallBack供Native调用
 * 3. 通过调用Native的CancelCallBack接口实现关闭日志回调
 * 4. 通过调用Native的callMyfunction接口以验证接口是否调用成功
 */

import testNapi from 'liblogcallback.so';
let functionCallNum : number = 0;    // Native中callMyfunction接口被调用的次数

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

  // TODO: 知识点： 调用Native的中的接口
  CallMyfunction() : void {
    testNapi.callMyfunction();
  }
}