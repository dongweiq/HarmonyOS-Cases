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

import advertising from '@ohos.advertising';
import { AdComponent } from '@ohos.advertising.AdComponent';
import { logger } from '@ohos/base';
import promptAction from '@ohos.promptAction';

const TAG = 'LaunchAdvertView';

//广告展示参数
const adDisplayOptions: advertising.AdDisplayOptions = {
  // 是否静音,默认不静音
  mute: false,
}

@Component
export struct LaunchAdvertView {
  // 当前路由栈
  @Consume('pageStack') pageStack: NavPathStack;
  // 广告数据
  ads: Array<advertising.Advertisement> = [];
  // 是否是全屏广告
  isFullScreenAdvert: boolean = false;
  // 广告高度
  advertHeight: ResourceStr = $r('app.string.full_size');

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
      AdComponent({ ads: this.ads, displayOptions: adDisplayOptions,
        interactionListener: {
          onStatusChanged: (status: string, _ad: advertising.Advertisement, _data: string) => {
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
                  duration: 1000
                });
              // 跳转相应的页面
                this.pageStack.pop();
                break;
            }
          }
        }
      })
        .width($r('app.string.full_size'))
        .height(this.advertHeight)

      if (!this.isFullScreenAdvert) {
        Column() {
          Text($r('app.string.half_screen_advert_detail'))
        }
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