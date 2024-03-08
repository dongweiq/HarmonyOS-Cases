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
 * 1. 通过调用Native的setLogCallback接口实现日志回调注册
 * 2. 通过调用Native的CancelCallback接口实现关闭日志回调
 */

import testNapi from 'liblogcallback.so';

export class HiLogMonitorManagement {

  // TODO: 知识点： 注册日志回调函数
  registerCallback(strLog: string, callBack : Function) : void {
    testNapi.setLogCallback(strLog, callBack);
  }

  // TODO: 知识点： 关闭日志回调
  cancelCallback() : void {
    testNapi.cancelLogCallback();
  }
}