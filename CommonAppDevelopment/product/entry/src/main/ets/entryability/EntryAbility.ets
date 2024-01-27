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
import { eventSubscription } from '@ohos/applicationexception';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info(TAG, '%{public}s', 'Ability onCreate');
    // TODO：需求：待系统查杀类型需求开发，补充查杀系统枚举类型
    if(launchParam.lastExitReason === 7 ){}
    // 绑定上下文信息
    AppStorage.setOrCreate('context', this.context);
    // 订阅应用事件
    eventSubscription();
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
}
