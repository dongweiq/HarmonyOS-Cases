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
  @Link statusBarHeight: number // 状态栏高度

  build() {
    Row() {
      Image($r('app.media.return'))
        .width($r('app.integer.height_22'))
        .height($r('app.integer.height_22'))
        .margin({ left: $r('app.integer.number_25'), right: $r('app.integer.number_15') })
      Text($r('app.string.homeTop'))
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
  private image: Resource | string = ''; // 图片
  @Link bottomAvoidHeight: number; // 底部导航条避让高度

  build() {
    Column() {
      Image(this.image)
        .backgroundColor(Color.White)
        .height($r('app.integer.other_itemheight'))
        .width('98%')
        .borderRadius($r('app.integer.number_10'))
      Blank()
        .color(Color.White)
        .height(this.bottomAvoidHeight)
    }
  }
}

// 页面最顶部自定义标题
@Component
export struct StatusHead {
  @Link statusBarHeight: number;
  @State topHeaderHeight: number = 0;

  build() {
    Column() {
      Blank()
        .width('100%')
        .backgroundColor(Color.White)
        .height(this.statusBarHeight)
      Row() {
        Image($r('app.media.return'))
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
    .animation({
      duration: 2000, // 动画持续时间，单位毫秒
      curve: Curve.EaseOut, // 动画曲线
      iterations: 1, // 动画播放次数
      playMode: PlayMode.Normal// 动画播放模式
    })
  }
}

