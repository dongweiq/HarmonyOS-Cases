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

import hiAppEvent from '@ohos.hiviewdfx.hiAppEvent';
import { PreferencesManager } from '../model/PreferencesManager';
import { BUTTON_TEXT } from '../model/MockData';
import { FaultDataSource } from '../model/DataSource';
import { FunctionDescription, logger } from '@ohos/base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

const TAG: string = 'FaultLogger'; // 应用异常页面标识
const DELAY_TIME:number = 3000; // 延时时间

/**
 * 依次构建应用异常，应用退出后，进入本页面，等待订阅消息通知，待收到订阅消息后，通过EventSubscription.ets中的onReceive函数，接收到异常信息数据，
 * 并通过AppStorage.setOrCreate('appEventGroups',异常信息数据)双向绑定异常信息，@StorageLink('appEventGroups')接收订阅事件函数传递
 * 的事件组信息，调用getFaultMessage函数对信息进行处理，将处理后的信息通过this.faultDataSource.pushData(message)添加到懒加载数据源中
 * 并通过this.faultDataSource.persistenceStorage()执行持久化存储，最后通过使用LazyForEach将数据信息加载到页面上。
 */
@Component
export struct ApplicationExceptionView {
  // 初始化被点击的异常事件下标
  @Provide eventIndex: number = -1;

  build() {
    Column() {
      // 场景描述组件
      FunctionDescription({
        title: $r('app.string.application_fault_title'),
        content: $r('app.string.application_fault_description')
      })
      // 异常信息显示组件
      FaultArea()
      // 构造异常组件
      FaultConstruction()
    }.padding($r('app.string.ohos_id_card_padding_start'))
  }
}

@Component
struct FaultArea {
  // 懒加载数据源
  @State faultDataSource: FaultDataSource = new FaultDataSource();
  // 双向数据绑定懒加载数据源的数组长度
  @StorageLink('faultDataSourceLength') faultDataSourceLength: number = 0;
  // 双向数据绑定事件组，与AppStorage.setOrCreate进行绑定，此变量发生变化触发getFaultMessage函数
  @StorageLink('appEventGroups') @Watch('getFaultMessage') appEventGroups: Array<hiAppEvent.AppEventGroup> = [];
  // 被点击的异常事件下标
  @Consume eventIndex: number;

  async aboutToAppear() {
    logger.info(TAG, `aboutToAppear start`);
    // 获取Preferences实例
    PreferencesManager.getPreferences(this.faultDataSource);
  }

  // 获取应用异常信息
  async getFaultMessage() {
    logger.info(TAG, `getAppEventGroups start`);
    if (this.appEventGroups && this.appEventGroups.length > 0) {
      // 遍历事件组
      this.appEventGroups.forEach((eventGroup: hiAppEvent.AppEventGroup) => {
        // 遍历事件对象集合
        eventGroup.appEventInfos.forEach(async (eventInfo: hiAppEvent.AppEventInfo) => {
          let message: string = '';
          message += `HiAppEvent eventInfo.domain=${eventInfo.domain}\n` // 事件领域
            + `HiAppEvent eventInfo.name=${eventInfo.name}\n`  // 事件名称
            + `HiAppEvent eventInfo.eventType=${eventInfo.eventType}\n` // 事件名称
            + `HiAppEvent eventInfo.params.time=${eventInfo.params['time']}\n` // 事件发生的时间
            + `HiAppEvent eventInfo.params.crash_type=${eventInfo.params['crash_type']}\n`
            + `HiAppEvent eventInfo.params.foreground=${eventInfo.params['foreground']}\n`
            + `HiAppEvent eventInfo.params.bundle_version=${eventInfo.params['bundle_version']}\n`
            + `HiAppEvent eventInfo.params.bundle_name=${eventInfo.params['bundle_name']}\n`
            + `HiAppEvent eventInfo.params.exception=${JSON.stringify(eventInfo.params['exception'])}\n`
            + `HiAppEvent eventInfo.params.hilog.size=${eventInfo.params['hilog'].length}\n`;
          // TODO：知识点：将异常信息存储到数组faultMessage当中
          this.faultDataSource.pushData(message);
        })
      })
    }
    // TODO：知识点：持久化存储异常信息集合
    this.faultDataSource.persistenceStorage();
  }

  build() {
    List() {
      // 添加判断，如果异常信息集合的信息条数大于0，遍历异常信息
      if (this.faultDataSourceLength > 0) {
        // 性能：动态加载数据场景可以使用LazyForEach遍历数据。https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3
        LazyForEach(this.faultDataSource, (message: string) => {
          ListItem() {
            Text(message)
              .textAlign(TextAlign.Start)
          }
        }, (item: string) => item)
      } else {
        ListItem() {
          // 根据被点击事件的下标响应指定的信息
          Text(this.eventIndex === 0 ? $r('app.string.crash_event_message') :
            (this.eventIndex === 1 ? $r('app.string.freeze_event_message') :
            $r('app.string.no_message')))
        }
      }
    }
    .width('100%')
    .height(300)
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .padding($r('app.string.ohos_id_card_padding_start'))
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
  }
}

@Component
struct FaultConstruction {
  // 被点击的异常事件下标
  @Consume eventIndex: number;
  // 双向数据绑定懒加载数据源的数组长度
  @StorageLink('faultDataSourceLength') faultDataSourceLength: number = 0;

  handleOperate(index: number) {
    switch (index) {
      case 0:
      // 在按钮点击函数中构造一个APP_CRASH场景，触发应用崩溃事件
        let result: object = JSON.parse('');
        break;
      case 1:
      // 在按钮点击函数中构造一个APP_FREEZE场景，触发应用卡死事件,500ms之后执行无限循环
        while (true) {
        }
    }
  }

  build() {
    Column() {
      ForEach(BUTTON_TEXT, (item: string, index: number) => {
        Button(item)
          .type(ButtonType.Capsule)
          .size({ width: '100%' })
          .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
          .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
          .onClick(() => {
            // 点击异常的时候，清空页面信息数据，显示异常描述信息。控制页面信息数据的显示需要将此变量设置为0
            this.faultDataSourceLength = 0;
            // 更新被点击的异常事件下标
            this.eventIndex = index;
            // 3s之后执行系统崩溃操作
            setTimeout(() => {
              this.handleOperate(index);
            }, DELAY_TIME)
          })
      }, (item: string) => JSON.stringify(item))
    }.margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getApplicationExceptionView(): void {
  ApplicationExceptionView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.FAULT,wrapBuilder(getApplicationExceptionView));