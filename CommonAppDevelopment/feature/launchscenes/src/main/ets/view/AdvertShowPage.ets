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

import { AdComponent } from '@ohos.advertising.AdComponent';
import advertising from '@ohos.advertising';
import promptAction from '@ohos.promptAction';
import { logger } from '@ohos/base';

/*
 * 实现步骤：
 * 1. 创建广告展示页，根据获取的广告信息，调用AdComponent广告展示组件，展示广告。
 * 2. 监听广告展示状态，在广告展示结束后，关闭广告展示页。
 */

// 广告展示参数
const AdDisplayOptions: advertising.AdDisplayOptions = {
  // 是否静音,默认不静音
  mute: false,
}

const TAG = 'AdvertShowPage';

@Component
export struct AdvertShowPage {
  // 是否展示广告
  @Link advertShow: boolean;
  // 广告数据
  ads?: Array<advertising.Advertisement> = [];
  // 是否是全屏广告
  isFullScreenAdvert?: boolean = false;
  // 广告高度
  private advertHeight: ResourceStr = $r('app.string.full_size');
  // Toast显示时间
  private promtionDuration: number = 2000;

  //根据广告是否全屏,设置不同的广告展示高度
  aboutToAppear(): void {
    if (this.isFullScreenAdvert) {
      this.advertHeight = $r('app.string.full_size');
    } else {
      this.advertHeight = $r('app.string.half_screen_advert_size');
    }
  }

  build() {
    Column() {
      // 广告展示组件
      AdComponent({ ads: this.ads, displayOptions: AdDisplayOptions,
        interactionListener: {
          onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
            switch (status) {
              // 广告打开
              case AdStatus.AD_OPEN:
                logger.info(TAG, 'onAdOpen');
                break;
              // 广告点击
              case AdStatus.AD_CLICKED:
                logger.info(TAG, 'onAdClick');
                break;
              // 广告关闭
              case AdStatus.AD_CLOSED:
                logger.info(TAG, 'onAdClose');
                promptAction.showToast({
                  message: $r('app.string.advert_close'),
                  duration: this.promtionDuration
                });
                // 跳转相应的页面
                this.advertShow = false;
                break;
            }
          }
        }
      })
        .width($r('app.string.full_size'))
        .height(this.advertHeight)

      // 如果是非全屏广告，可在此处展示一些其他信息。
      if (!this.isFullScreenAdvert) {
        Column() {
          Text($r('app.string.half_screen_advert_detail'))
        }
        .backgroundColor($r('app.color.ohos_id_color_background'))
        .width($r('app.string.full_size'))
        .height($r('app.string.full_size'))
      }
    }
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}

export enum AdStatus {
  AD_OPEN = "onAdOpen",
  AD_CLICKED = "onAdClick",
  AD_CLOSED = "onAdClose",
}