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
import promptAction from '@ohos.promptAction';

// 页面背景透明并设置事件穿透，用于显示及操作下层地图组件，绑定半模态用来显示内容
@Component
export struct TakeTaxiDetailPage {
  @State pageHeight: number = 0;
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
      const RECT: window.Rect = data.getWindowProperties().windowRect;
      this.windowWidth = px2vp(RECT.width);
    })
  }

  @Builder
  taxiContentBuilder() {
    // 页面的内容区域
    Column() {
      Image($r('app.media.TaxiPageDetail'))
        .margin({top:CommonConstants.titleTextMargin})
        .width('100%')
        .onClick(() => {
          // 调用Toast显示提示:此样式仅为案例展示
          promptAction.showToast({ message: $r('app.string.demo_toast_tips')});
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
          detents: TakeTaxiPageCommonConstants.sheetDetents,
          preferType: this.windowWidth > this.componentsWindowWidth ? SheetType.CENTER : SheetType.POPUP,
          enableOutsideInteractive: true,
          dragBar: false,
          backgroundColor: TakeTaxiPageCommonConstants.backgroundColor,
          showClose: false,
          // 关闭半模态组件时直接返回上一级页面
          shouldDismiss: ()=>{
            this.isShow = false; // 系统在这块的处理有bug，返回前主动设置false，否则可能引入一些问题，已知：安全键盘无法弹出
            this.pageStackForComponentSharedPages.pop(false);
          }
        }
      )
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onAreaChange((oldValue, newValue) => {
      this.pageHeight = newValue.height as number;
      this.mapResponseRegionHeight = this.pageHeight;
    })
    .onShown(() => {
      this.mapResponseRegionHeight = this.pageHeight;
      logger.info('NavDestination is show, mapResponseRegionHeight is : ' + this.mapResponseRegionHeight);
    })
  }
}