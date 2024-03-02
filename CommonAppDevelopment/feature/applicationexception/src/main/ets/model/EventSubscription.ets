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
import { logger } from '@ohos/base';

const TAG: string = 'eventSubscription';

export function eventSubscription() {
  // 添加应用事件观察者方法，可用于订阅应用事件
  hiAppEvent.addWatcher({
    // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
    name: "mst",
    // 开发者可以订阅感兴趣的系统事件，此处是订阅了崩溃事件
    appEventFilters: [
      {
        domain: hiAppEvent.domain.OS,
        names: [hiAppEvent.event.APP_CRASH, hiAppEvent.event.APP_FREEZE]
      }
    ],
    // TODO：知识点：获取事件组信息。开发者可以自行实现订阅回调函数，崩溃和卡死事件下次应用启动时会回调给开发者
    onReceive: async (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
      logger.info(TAG, `HiAppEvent onReceive: domain=${domain}`);
      /**
       * 获取事件组信息，与ApplicationException文件中的@StorageLink('faultMessage') faultMessage进行双向数据绑定
       * 性能关注：如果开发者有同步的代码需要执行耗时操作，建议起worker或者taskpool线程来处理。但如果开发者使用storage和preferences，直接调用即可。
       */
      AppStorage.setOrCreate('appEventGroups', appEventGroups);
    }
  });
}