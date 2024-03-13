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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

@Component
export struct SubDetailPage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.left'))
          .width(20)
      }
      .width('100%')
      .height(40)
      .clip(true)
      .margin({ left: 20 })
      .onClick(() => {
        DynamicsRouter.navPathStack.pop(true);
      })

      Column() {
        Text($r("app.string.sub_page_description"))
      }
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getSubDetailPageView(): void {
  SubDetailPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.TRANSITION_ANIMATION_SUB_Detail, wrapBuilder(getSubDetailPageView));