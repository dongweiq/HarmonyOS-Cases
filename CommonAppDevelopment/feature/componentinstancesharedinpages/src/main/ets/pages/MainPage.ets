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

import { MainPageCommonConstants, CommonConstants} from '../model/CommonConstants';
import promptAction from '@ohos.promptAction';

// 整个页面使用Scroll作为容器，实现页面内容滑动，Scroll中第一个组件设置为透明，并设置页面的事件穿透，用于显示和操作下层地图组件
@Component
@Preview
export struct MainPageComponent {
  @State transParentInitHeight: number = 0;
  @State pageHeight: number = 0;
  @Consume pageStackForComponentSharedPages: NavPathStack;
  @Consume('pageStack') homePageStack: NavPathStack;
  // 用于调整下层地图组件和上层内容的手势响应区域，跟scroll的currentOffset相关
  @Consume mapResponseRegionHeight: number;
  private scrollCurOffset: number = 0;
  private scroller: Scroller = new Scroller();

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          // 页面用于显示地图的区域，放一个空的容器组件，背景默认透明，来显示下层的地图组件（该组件父组件也需要设置透明）
          Column() {
          }
          .width('100%')
          .height(this.transParentInitHeight)
          // 模拟页面的内容区域
          Column() {
            Image($r('app.media.MainPageGrid'))
              .margin({top:CommonConstants.titleTextMargin})
              .width('100%')
              .onClick(() => {
                this.pageStackForComponentSharedPages.pushPathByName("TakeTaxiDetailPage", null, false);
              })
            Image($r('app.media.MainPageAds'))
              .width('100%')
              .onClick(() => {
                // 调用Toast显示提示:此样式仅为案例展示
                promptAction.showToast({ message: $r('app.string.demo_toast_tips')});
              })
          }
          .borderRadius(MainPageCommonConstants.contentAreaRadius)
          .backgroundColor(MainPageCommonConstants.backgroundColor)
          .width('100%')
        }
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(Color.Transparent)
      /** TODO: 知识点: responseRegion属性用于设置手势响应区域，
       *  Scroll部分区域透明用于显示下层地图组件，该透明区域手势事件不应该响应，可通过responseRegion属性设置手势响应区域，
       */
      .responseRegion({
        x: 0,
        y: this.mapResponseRegionHeight,
        width: '100%',
        height: this.pageHeight - this.mapResponseRegionHeight
      })
      /** 性能知识点: onScrollFrameBegin函数是系统高频回调函数，避免在函数中进行冗余或耗时操作。
       */
      .onScrollFrameBegin((offset) => {
        this.scrollCurOffset = this.scroller.currentOffset().yOffset;
        this.mapResponseRegionHeight =
          this.transParentInitHeight - this.scrollCurOffset > 0 ? this.transParentInitHeight - this.scrollCurOffset:0;
        return {offsetRemain : offset};
      })
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onAreaChange((oldValue, newValue) => {
      this.pageHeight = newValue.height as number;
      this.transParentInitHeight = this.pageHeight * MainPageCommonConstants.mapAreaHeightRatio;
      this.mapResponseRegionHeight =
        this.transParentInitHeight - this.scrollCurOffset > 0 ? this.transParentInitHeight - this.scrollCurOffset:0;
    })
    // 其他页面可能修改了手势区域，当前页面显示时更新手势区域
    .onShown(() => {
      this.mapResponseRegionHeight =
        this.transParentInitHeight - this.scrollCurOffset > 0 ? this.transParentInitHeight - this.scrollCurOffset:0;
    })
    // 主页侧滑返回瀑布流页面
    .onBackPressed(() => {
      this.homePageStack.pop(true);
      return true;
    })
  }
}