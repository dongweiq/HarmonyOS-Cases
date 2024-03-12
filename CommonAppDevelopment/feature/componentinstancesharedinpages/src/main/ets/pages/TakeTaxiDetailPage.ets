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

import { TakeTaxiPageCommonConstants, CommonConstants } from '../model/CommonConstants';
import { logger } from '@ohos/utils';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

// 页面背景透明并设置事件穿透，用于显示及操作下层地图组件，绑定半模态用来显示内容
@Component
export struct TakeTaxiDetailPage {
  @State pageHeight: number = 0;
  @State cardList: number[] = CommonConstants.CARD_NO_ARRAY;
  @Consume pageStackForComponentSharedPages: NavPathStack;
  // 用于调整下层地图组件和上层内容的手势响应区域，跟scroll的currentOffset相关
  @Consume mapResponseRegionHeight: number;
  @State isShow: boolean = true;
  @State windowWidth: number = 0;
  readonly componentsWindowWidth: number = 600;

  /**
   * 获取应用主窗口的宽高
   */
  aboutToAppear() {
    window.getLastWindow(getContext(this), (err: BusinessError, data: window.Window) => {
      let rect: window.Rect = data.getWindowProperties().windowRect;
      this.windowWidth = px2vp(rect.width);
    })
  }

  @Builder
  taxiContentBuilder() {
    // 页面的内容区域
    Column() {
      /** 性能知识点: ForEach循环渲染会一次性加载所有组件，
       *  会导致页面启动时间长，影响用户体验，长列表推荐使用懒加载LazyForEach
       */
      ForEach(this.cardList, (item: number) => {
        Text()
          .width(CommonConstants.CARD_WIDTH)
          .height(CommonConstants.CARD_HEIGHT)
          .margin(CommonConstants.CARD_MARGIN)
          .backgroundColor(CommonConstants.CARD_BACKGROUND_COLOR)
          .textAlign(TextAlign.Center)
          .borderRadius(CommonConstants.CARD_BORDER_RADIUS)
      })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      // 空的容器设置为页面大小，默认透明用于显示地图组件
      Column() {
      }
      .height('100%')
      .width('100%')
      // 绑定上半模态页面，用于显示内容
      .bindSheet($$this.isShow, this.taxiContentBuilder(),
        {
          detents: TakeTaxiPageCommonConstants.SHEET_DETENTS,
          preferType: this.windowWidth > this.componentsWindowWidth ? SheetType.CENTER : SheetType.POPUP,
          enableOutsideInteractive: true,
          dragBar: false,
          title: { title: $r('app.string.take_taxi_detail_page') },
          backgroundColor: Color.White,
          showClose: false,
          // 关闭半模态组件时直接返回上一级页面
          shouldDismiss: () => {
            this.pageStackForComponentSharedPages.pop(false);
          }
        }
      )
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onAreaChange((oldValue, newValue) => {
      this.pageHeight = newValue.height as number;
      logger.info('NavDestination area change, height is : ' + this.pageHeight);
      this.mapResponseRegionHeight = this.pageHeight;
    })
    .onShown(() => {
      this.mapResponseRegionHeight = this.pageHeight;
      logger.info('NavDestination is show, mapResponseRegionHeight is : ' + this.mapResponseRegionHeight);
    })
  }
}