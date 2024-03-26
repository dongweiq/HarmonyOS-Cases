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
import { STYLE_CONFIG } from '../model/ConstData';
import { DigitalScrollDetail } from './DigitalScrollDetail';

@Component
export struct DigitalScrollExample {
  private scroller: Scroller = new Scroller(); // Scroller对象
  @State data: number[] = [1, 2, 3, 4, 5, 6]; // 数据项
  @State isRefresh: boolean = false;

  build() {
    Column({ space: STYLE_CONFIG.ITEM_GUTTER }) {
      // 下拉刷新组件
      Refresh({ refreshing: $$this.isRefresh }) {
        this.scrollArea()
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefresh = false; // 刷新完成
        }, 1000)
      })
    }
    .padding({
      top: STYLE_CONFIG.PADDING_TOP
    })
    .width($r('app.string.max_size'))
    .height($r('app.string.max_size'))
    .linearGradient({
      colors: [[$r('app.color.backgroundColor'), 0.0], [$r('sys.color.ohos_id_color_background'), 0.3]]
    })
  }

  @Builder
  scrollArea() {
    List({ space: STYLE_CONFIG.ITEM_GUTTER, scroller: this.scroller }) {
      ListItem() {
        Text($r('app.string.ticket'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .width($r('app.string.max_size'))
          .textAlign(TextAlign.Center)
      }

      ListItem() {
        Column() {
          Row({ space: STYLE_CONFIG.TEXT_MARGIN }) {
            Text($r('app.string.today'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Bold)

            // 数字滚动组件
            DigitalScrollDetail({ isRefresh: this.isRefresh })

            Text($r('app.string.getTicket'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Bold)
          }
          .width($r('app.string.max_size'))
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .scrollBar(BarState.Off) // 设置滚动调状态不可见
    .height($r('app.string.max_size'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getDigitalScrollDetail(): void {
  DigitalScrollExample();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.DIGITAL_SCROLL_ANIMATION, wrapBuilder(getDigitalScrollDetail));
