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

import curves from '@ohos.curves';

@Component
export struct AddressExchangeView {
  // 旋转角度
  @State rotateAngle: number = 0;
  // 偏移量
  @State translateX: number = 0;
  // 是否已切换
  @State swap: boolean = false;
  // 整体内容区宽度
  rowWidth: number = 300;
  // 单次偏移距离
  distance: number = this.rowWidth * 0.6;
  // 内容相隔距离
  columnSpace: number = 40;
  // 初始化偏移距离
  zeroTranslate: number = 0;
  // 单次旋转180°
  rotateAddAngle: number = 180;
  // 内容区背景颜色
  contentBackgroundColor: Color = 0x888888;

  build() {
    Column({ space: this.columnSpace }) {
      Text($r('app.string.address_exchange_title'))
        .margin({ top: $r('app.integer.address_exchange_title_top_space') })

      Text($r('app.string.address_exchange_detail'))

      Row() {
        Text($r('app.string.address_exchange_address_left'))
          .translate({ x: this.translateX })
          .width($r('app.string.address_exchange_address_width'))
          .fontSize($r('app.integer.address_exchange_address_font_size'))
          .textAlign(this.swap ? TextAlign.End : TextAlign.Start)

        Stack() {
          Image($r('app.media.address_exchange_airplane'))
            .size({
              height: $r('app.integer.address_exchange_airplane_size'),
              width: $r('app.integer.address_exchange_airplane_size')
            })
          Image($r('app.media.address_exchange_recycle'))
            .size({
              height: $r('app.integer.address_exchange_recycle_size'),
              width: $r('app.integer.address_exchange_recycle_size')
            })
            .rotate({ angle: this.rotateAngle })
            .animation({
              curve: Curve.EaseOut,
              playMode: PlayMode.Normal,
            })
        }
        .width($r('app.string.address_exchange_image_width'))
        .onClick(() => {
          this.swap = !this.swap
          // TODO 知识点：动画效果，修改偏移量，修改旋转角度，实现效果
          animateTo({ curve: curves.springMotion() }, () => {
            if (this.swap) {
              this.translateX = this.distance
            } else {
              this.translateX = this.zeroTranslate
            }
          })
          this.rotateAngle += this.rotateAddAngle
        })

        Text($r('app.string.address_exchange_address_right'))
          .translate({ x: -this.translateX })
          .width($r('app.string.address_exchange_address_width'))
          .fontSize($r('app.integer.address_exchange_address_font_size'))
          .textAlign(this.swap ? TextAlign.Start : TextAlign.End)
      }
      .width(this.rowWidth)
      .justifyContent(FlexAlign.SpaceBetween)
      .height($r('app.integer.address_exchange_content_height'))
      .backgroundColor(this.contentBackgroundColor)
    }
    .justifyContent(FlexAlign.Start)
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}