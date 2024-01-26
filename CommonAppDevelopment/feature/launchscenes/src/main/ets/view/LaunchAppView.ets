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

import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import { logger, NavPathParam } from '@ohos/base';
import common from '@ohos.app.ability.common';
import identifier from '@ohos.identifier.oaid';
import advertising from '@ohos.advertising';
import promptAction from '@ohos.promptAction';

export enum AdType {
  // 开屏广告的类型
  SPLASH_AD = 1,
}

const TAG = 'LaunchAppView';

@Component
export struct LaunchAppView {
  // 内容区相隔距离
  columnSpace: number = 16;
  // 当前路由栈
  @Consume('pageStack') pageStack: NavPathStack;
  // 当前context
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 广告配置
  private adOptions: advertising.AdOptions = {};

  // 申请广告跟踪权限，获取广告信息
  aboutToAppear() {
    this.requestOAIDTrackingConsentPermissions(this.context);
  }

  // 进入页面时触发动态授权弹框，向用户请求授权广告跟踪权限。需在模块的module.json5文件中，申请广告跟踪权限ohos.permission.APP_TRACKING_CONSENT。
  requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ["ohos.permission.APP_TRACKING_CONSENT"]).then((data) => {
        if (data.authResults[0] == 0) {
          // 申请权限成功
          logger.info(TAG, 'request permission success');
          // 获取OAID信息
          this.getOAIDString();
        } else {
          logger.info(TAG, 'user rejected APP_TRACKING_CONSENT permission');
        }
      }).catch((err: BusinessError) => {
        logger.error(TAG, `request permission failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      logger.error(TAG, `request permission catch error: ${JSON.stringify(err)}`);
    }
  }

  // 调用getOAID方法获取OAID信息
  getOAIDString() {
    try {
      if (canIUse('SystemCapability.Advertising.OAID')) {
        identifier.getOAID((err: BusinessError, data: string) => {
          if (err.code) {
            logger.error(TAG, `get oaid failed. error: ${JSON.stringify(err)}`);
          } else {
            logger.info(TAG, `get oaid by callback success. oaid: ${data}`);
            // TODO 知识点: 取的OAID添加到广告请求参数中，请求广告信息。
            this.requestAd({
              adId: 'x8vut0ippz', // 'x8vut0ippz'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
              adType: AdType.SPLASH_AD,
              adCount: 1,
              oaid: data
            }, this.adOptions);
          }
        });
      }
    } catch (err) {
      logger.error(TAG, `get oaid catch error: ${JSON.stringify(err)}`);
    }
  }

  // 获取广告信息
  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    // 广告请求回调监听
    const adLoaderListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        logger.error(TAG, `request ad failed. errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`);
        promptAction.showToast({
          message: `request ad failed. errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`,
          duration: 1000
        });
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        logger.info(TAG, 'request ad success');
        if (canIUse("SystemCapability.Advertising.Ads")) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            // 调用开屏广告展示页面
            let isFullScreenAdvert = ads[0]?.isFullScreen === true;
            this.pageStack.replacePath({
              name: 'launchAdvertView',
              param: new NavPathParam(ads, isFullScreenAdvert)
            });
          } else {
            logger.error(TAG, 'error adType');
          }
        }
      }
    }

    if (canIUse("SystemCapability.Advertising.Ads")) {
      // 创建AdLoader广告对象
      const load: advertising.AdLoader = new advertising.AdLoader(this.context);
      logger.info(TAG, 'start request ad');
      // 调用广告请求接口
      load.loadAd(adReqParams, adOptions, adLoaderListener);
    }
  }

  build() {
    // 展示应用启动页，logo + 简介
    Stack() {
      Column({ space: this.columnSpace }) {
        Image($r('app.media.launch_logo'))
          .width($r('app.integer.launch_logo_size'))
          .height($r('app.integer.launch_logo_size'))
          .objectFit(ImageFit.Contain)

        Text($r('app.string.launch_string'))
          .fontSize($r('app.integer.launch_logo_font_size'))
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.ohos_id_color_background'))
      .width($r('app.string.full_size'))
      .height($r('app.string.full_size'))

      Text($r('app.string.launch_title'))
        .margin({ top: $r('app.integer.launch_title_top_space') })
    }
    .align(Alignment.Top)
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}