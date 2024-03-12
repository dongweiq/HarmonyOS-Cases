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

import { BusinessError } from '@kit.BasicServicesKit';
import { picker } from '@kit.CoreFileKit';
import { window } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { logger } from '@ohos/common';
import emitter from '@ohos.events.emitter';
import etswrapper from 'libetswrapper.so';

/**
 * 类型声明：处理参数为string[]的回调
 */
export interface StringArrayCbWrapper {
  call: (data: string[]) => void;
}

/**
 * 类型声明：处理参数为BusinessError类型的回调
 */
export interface CatchCbWrapper {
  call: (err: BusinessError) => void;
}

export const EVENT_ID: number = 0x1111; // 注意：仅供UI展示使用

/**
 * 封装后的documentViewPicker的Select方法，需要被注册到native侧
 * @param uiContext：调用本方法的UIContext
 * @param options：拉起picker时的options参数
 * @param thenWrapper：开发者自定义的then回调
 * @param catchWrapper：开发者自定义的catch回调
 */
function documentViewPickerSelect(uiContext: UIContext, options: picker.DocumentSelectOptions, thenWrapper:
  StringArrayCbWrapper, catchWrapper: CatchCbWrapper): void {
  // TODO：知识点：使用对应UIAbitliy的UIContext.runScopedTask来执行方法，确保多实例情况下，事件在正确的窗口/UIAbility内发生
  uiContext.runScopedTask(() => {
    logger.debug("enter ets select");
    logger.debug(JSON.stringify(uiContext));
    let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
    documentViewPicker.select(options).then((value: string[]) => {
      logger.debug("enter js select then");
      logger.debug(JSON.stringify(uiContext));
      // 注意：仅供UI展示使用：通过emitter将消息发送出去，在ui界面处接收并展示
      emitter.emit({
        eventId: EVENT_ID
      }, {
        data: {
          content: value.toString(),
          id: EVENT_ID,
          isEmpty: false
        }
      });
      thenWrapper.call(value);
    }).catch((error: BusinessError) => {
      logger.debug("enter js select catch");
      catchWrapper.call(error);
    })
  })
}

/**
 * 封装后的documentViewPicker的Save方法，需要被注册到native侧
 * @param uiContext：调用本方法的UIContext
 * @param options：拉起picker时的options参数
 * @param thenWrapper：开发者自定义的then回调
 * @param catchWrapper：开发者自定义的catch回调
 */
function documentViewPickerSave(uiContext: UIContext, options: picker.DocumentSaveOptions, thenWrapper:
  StringArrayCbWrapper, catchWrapper: CatchCbWrapper): void {
  //...
}

/**
 * TODO：知识点：步骤一：
 * 注册封装后的方法到native侧
 * 建议在EntryAbility之外调用，单次调用即可
 * example:
 * registryDocumentViewPickerFn();
 * export default class EntryAbility extends UIAbility {
 *     abilityID: string = generateAbilityID();
 *     ...
 * }
 */
export function registryDocumentViewPickerFn(): void {
  etswrapper.registryDocumentViewPickerFn(documentViewPickerSelect, documentViewPickerSave);
}

/**
 * TODO：知识点：步骤二：
 * 生成UUID作为UIAbility实例的id，需在使用时自行为EntryAbility添加id属性
 * example:
 * export default class EntryAbility extends UIAbility {
 *     abilityID: string = generateAbilityID();
 *     ...
 * }
 */
export function generateAbilityID(): string {
  return util.generateRandomUUID();
}


/**
 * TODO：知识点：步骤三：
 * 注册UIAbility的ID及其对应的UIContext，此方法应确保在loadContent成功之后执行，
 * 即EntryAbility中的onWindowStageCreate中的windowStage.loadContent回调中执行
 * @param abilityID：UIAbility的ID
 * @param windowStage：UIAbitliy对应的windowStage对象
 */
export function addUIContext(abilityID: string, windowStage: window.WindowStage): void {
  let uiContext: UIContext = windowStage.getMainWindowSync().getUIContext();
  // TODO：知识点：添加UIAbitliy的id及其对应UIContext，后续将uiContext传回ets侧，以确保多实例情况下事件在正确的窗口/UIAbitliy内发生
  etswrapper.addUIContext(abilityID, uiContext);
}

/**
 * TODO：步骤四：
 * 订阅相关事件，当窗口活跃时，设置对应的abilityID为全局的topAbility（表示当前正活跃的窗口），必须在windowStage.loadContent之后调用
 * @param abilityID：UIAbitliy的ID
 * @param windowStage：UIAbitliy对应的windowStage
 */
export function setTopAbilityID(abilityID: string, windowStage: window.WindowStage): void {
  windowStage.on("windowStageEvent", (data: window.WindowStageEventType) => {
    if (data === window.WindowStageEventType.ACTIVE) {
      logger.debug(`[activeAbility]${abilityID}`);
      // TODO：知识点：当窗口为Active时，设置当前UIAbitliy的id为活跃的id，则在Native执行方法时，需要取到对应id的UIContext
      etswrapper.setTopAbilityID(abilityID);
    }
  })
}

/**
 * TODO：步骤五：
 * 移除abilityID对应的UIContext，建议在EntryAbility中的onWindowStageDestroy中执行
 * @param abilityID
 */
export function removeUIContext(abilityID: string): void {
  etswrapper.removeUIContext(abilityID);
}

/**
 * 模拟从native侧在JS线程发起调用
 */
export function mockDocumentViewPickerSelectJSThread(): void {
  etswrapper.mockDocumentViewPickerSelectJSThread();
}

/**
 * 模拟native侧在PThread线程发起调用
 */
export function mockDocumentViewPickerSelectPThread(): void {
  etswrapper.mockDocumentViewPickerSelectPThread();
}