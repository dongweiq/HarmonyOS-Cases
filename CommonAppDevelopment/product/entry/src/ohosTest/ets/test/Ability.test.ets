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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { logger } from '@ohos/base';
import { LogCallBack } from '@ohos/logcallback';

const BUNDLE: string = 'CommonAppDevelopment';
const TAG: string = '[CommonAppDevelopment_Test]';
const delegator: AbilityDelegatorRegistry.AbilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();

export default function abilityTest() {
  describe('ActsAbilityTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    /**
     * 开启日志回调验证
     */
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

    /**
     * 关闭日志回调验证
     */
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

  })
}