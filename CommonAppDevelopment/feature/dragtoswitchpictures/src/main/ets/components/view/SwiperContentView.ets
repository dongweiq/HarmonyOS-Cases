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

/**
 * 轮播图和房价视图
 */
import { CONFIGURATION } from '../common/Constants';
import { SWIPER_DATA } from '../data/DragToSwitchPicturesData';
import { SwiperDataSource } from '../datasource/DragToSwitchPicturesDataSource';
import { SwiperModule } from '../model/DragToSwitchPicturesModule';

@Component
export struct SwiperContentView {
  private swiperController: SwiperController = new SwiperController();
  private swiperDataSource: SwiperDataSource = new SwiperDataSource();

  aboutToAppear(): void {
    for (let i = CONFIGURATION.INIT_VALUE; i < SWIPER_DATA.length; i++) {
      this.swiperDataSource.pushData(SWIPER_DATA[i]);
    }
  }

  build() {
    Row() {
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(this.swiperDataSource, (item: SwiperModule) => {
            Image(item.imageSrc)
              .width($r('app.integer.swipercontentview_image_width'))
              .objectFit(ImageFit.Fill)
              .height($r('app.integer.swipercontentview_image_height'))
              .borderRadius($r('app.integer.borderradius'))
              .draggable(false)
          })
        }
        .width($r('app.integer.swipercontentview_swiper_width'))
        .height($r('app.integer.swipercontentview_swiper_height'))
        .displayCount(CONFIGURATION.SWIPER_DISCOUNT)
        .autoPlay(true)
        .itemSpace(CONFIGURATION.SWIPER_ITEMSPACE)
        .loop(true)
        .indicator(false)
        .margin({ left: $r('app.integer.swiper_margin_length'), right: $r('app.integer.swiper_margin_length') })
      }
      .width($r('app.string.46_size'))
      .height($r('app.integer.swipercontentview_row_column_height'))
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.swipercontentview_row_column_backgroundcolor'))
      .borderRadius($r('app.integer.borderradius'))
      .margin({ right: $r('app.integer.swipercontentview_row_column_margin_length') })

      Row() {
        Column() {
          Text($r('app.string.average_price'))
            .fontSize($r('app.integer.average_price_fontsize'))
            .width($r('app.integer.average_price_width'))
            .height($r('app.integer.average_price_height'))
            .fontColor($r('app.color.average_price_fontcolor'))
          Row() {
            Text($r('app.string.second_hand_house'))
              .fontSize($r('app.integer.10s_fontsize'))
            Image($r('app.media.down_green'))
              .width($r('app.integer.down_green_width'))
              .objectFit(ImageFit.Fill)
              .height($r('app.integer.down_green_height'))
              .borderRadius($r('app.integer.borderradius'))
              .draggable(false)
            Text($r('app.string.1_4_size'))
              .fontSize($r('app.integer.10s_fontsize'))
              .fontColor($r('app.color.1_4_fontcolor'))
          }
        }.margin({ left: $r('app.integer.column_price_margin_left') })

        Column() {
          Text($r('app.string.sales_count'))
            .fontSize(13)
            .width(50)
            .height(15)
            .fontColor($r('app.color.average_price_fontcolor'))
          Text($r('app.string.traded_yesterday'))
            .fontSize(12)
        }.margin({ left: $r('app.integer.margin_length') })
      }
      .width($r('app.string.46_size'))
      .height($r('app.integer.swipercontentview_row_column_height'))
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('app.color.swipercontentview_row_column_backgroundcolor'))
      .borderRadius($r('app.integer.borderradius'))
      .margin({ left: $r('app.integer.swipercontentview_row_column_margin_length') })
    }
    .width($r('app.string.full_size'))
    .height($r('app.integer.swipercontentview_row_column_height'))
    .justifyContent(FlexAlign.Center)
  }
}