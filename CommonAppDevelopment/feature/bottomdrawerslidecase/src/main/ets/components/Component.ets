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

import { CommonConstants } from '../constants/CommonConstants';

// 地图顶部标题栏
@Component
export struct HomeTop {
  @Link statusBarHeight: number; // 状态栏高度

  build() {
    Row() {
      Text($r('app.string.homeTop'))
        .margin({ left: $r('app.integer.number_25'), right: $r('app.integer.number_15') })
        .fontColor(Color.Black)
        .fontSize($r('app.integer.number_18'))
    }
    .width('100%')
    .height($r('app.integer.height_48'))
    .margin({ top: this.statusBarHeight })
  }
}

// listItem布局样式
@Component
export struct SettingItemView {
  @Link bottomAvoidHeight: number; // 底部导航条避让高度

  build() {
    Column() {
      Image($r('app.media.list_item'))
        .height($r('app.integer.other_itemheight'))
        .width('98%')
        .borderRadius($r('app.integer.number_10'))
      Blank()
        .color(Color.White)
        .height(this.bottomAvoidHeight)
    }
  }
}

// Image地图布局样式
@Component
export struct ImageMapView {
  @State imagePositionX: number = 0; // 图片在父组件内X轴位置
  @State imagePositionY: number = 0; // 图片在父组件内Y轴位置
  @State offsetX: number = 0; // 拖动事件结束后图片X轴位置
  @State offsetY: number = 0; // 拖动事件结束后图片Y轴位置

  build() {
    Column() {
      // 背景地图图片
      Image($r('app.media.map'))
        .id("bg_img")
        .height($r('app.integer.number_2000'))
        .width($r('app.integer.number_2000'))
        .translate({ x: this.offsetX, y: this.offsetY })// 以组件左上角为坐标原点进行移动
        .draggable(false) // 单指操作拖动背景地图

    }.width('100%')
    .height('100%')
    .clip(true) // 地图图片超出页面区域时裁剪掉
    .gesture(
      PanGesture({ direction: PanDirection.All, fingers: 1 })
        .onActionUpdate((event: GestureEvent) => {
          this.offsetX = event.offsetX + this.imagePositionX;
          this.offsetY = event.offsetY + this.imagePositionY;
        })
        .onActionEnd((event: GestureEvent) => {
          this.imagePositionX = this.offsetX;
          this.imagePositionY = this.offsetY;
        })
    )
  }
}

// 页面最顶部自定义标题
@Component
export struct StatusHead {
  @Link statusBarHeight: number;
  @State topHeaderHeight: number = 0;
  @Link isShow: boolean;

  build() {
    Column() {
      Blank()
        .width(CommonConstants.FULL_SIZE)
        .backgroundColor(Color.White)
        .height(this.statusBarHeight)
      Row() {
        Image($r('app.media.next'))
          .width($r('app.integer.height_22'))
          .height($r('app.integer.height_22'))
          .margin({ left: $r('app.integer.number_25'), right: $r('app.integer.number_15') })
        Text($r('app.string.homeTop'))
          .fontColor(Color.Black)
          .fontSize($r('app.integer.number_20'))
      }
      .backgroundColor(Color.White)
      .width(CommonConstants.FULL_SIZE)
      .height(this.topHeaderHeight)
    }
    .visibility(this.isShow ? Visibility.Visible : Visibility.None)
    .animation({
      duration: 200, // 动画持续时间，单位毫秒
      curve: Curve.Smooth, // 动画曲线
      iterations: 1, // 动画播放次数
      playMode: PlayMode.Normal// 动画播放模式
    })
  }
}

