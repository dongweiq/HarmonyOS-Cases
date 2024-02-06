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

import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
// 基础公共工具类base，主要包括日志打印和主页列表数据类型以及控制器
import { logger } from '@ohos/base';
import { Configuration } from '@ohos.app.ability.Configuration';
// 引用异常处理模块
import { eventSubscription } from '@ohos/applicationexception';
import { preloadSOByTaskPool } from '@ohos/nativerawfile';

const TAG = 'EntryAbility'
// 资源异常枚举
const RESOURCE_CONTROL: number = 7;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info(TAG, '%{public}s', 'Ability onCreate');
    // TODO：需求：待系统查杀类型需求开发，补充查杀系统枚举类型
    if (launchParam.lastExitReason === RESOURCE_CONTROL) {}
    // 绑定上下文信息
    AppStorage.setOrCreate('context', this.context);
    // 事件订阅(获取上次异常退出信息)
    eventSubscription();
    /**
     * 在Ability的onCreate周期函数中和后续的应用声明周期函数中可以使用TaskPool子线程预加载so库，后续通过句柄调用库中的native方法。
     * 此处在Ability的onCreate周期函数中使用TaskPool子线程预加载so库，加载完成后在nativerawfile模块中使用。
     */
    preloadSOByTaskPool();
  }

  onDestroy(): void {
    logger.info(TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    // 加载应用入口页面
    windowStage.loadContent('pages/EntryView', (err, data) => {
      if (err.code) {
        logger.info(TAG, 'Failed to load the content. Cause:', JSON.stringify(err));
        return;
      }
      logger.info(TAG, 'Succeeded in loading the content. Data:', JSON.stringify(data));
    });

    // 获取当前的颜色模式并保存
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
    // 保存windowStage供fitfordarkmode的har包中FitForDarkPage.ets中setStatusBar方法修改状态栏颜色。
    AppStorage.setOrCreate('windowStage', windowStage);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    logger.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    logger.info(TAG, '%{public}s', 'Ability onForeground');

  }

  onBackground(): void {
    // Ability has back to background
    logger.info(TAG, '%{public}s', 'Ability onBackground');
  }

  // TODO: 知识点：检测当前的深浅模式是否发生变化，刷新状态栏
  onConfigurationUpdate(config: Configuration) {
    // 获取最新的变更颜色并更新到AppStorage
    AppStorage.setOrCreate('currentColorMode', config.colorMode);
    logger.info(`onConfigurationUpdate, config: ${JSON.stringify(config)}`);
  }
}
