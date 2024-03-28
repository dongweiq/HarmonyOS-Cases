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

import { GridSceneView } from '../view/GridSceneView';
import { ListSceneView } from '../view/ListSceneView';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 模拟桌面背景，模块化Grid与List示图实现
 */
@Component
export struct Launcher {
  build() {
    Column() {
      GridSceneView() // 实现Grid拖拽场景
      ListSceneView() // 实现List拖拽场景
    }
    .width($r('app.string.layout_100_percent'))
    .height($r('app.string.layout_100_percent'))
    .justifyContent(FlexAlign.Center)
    .backgroundImage($r('app.media.wallpaper_default'))
    .backgroundImageSize(ImageSize.Cover)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getLauncher(): void {
  Launcher();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.DRAG_EXCHANGE, wrapBuilder(getLauncher));
