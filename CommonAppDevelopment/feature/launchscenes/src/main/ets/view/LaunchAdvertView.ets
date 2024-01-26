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
import { logger, FunctionDescription } from '@ohos/base';
import common from '@ohos.app.ability.common';
import identifier from '@ohos.identifier.oaid';
import advertising from '@ohos.advertising';
import promptAction from '@ohos.promptAction';
import { AdvertShowPage } from './AdvertShowPage';

/*
 * 实现步骤：
 * 1. 创建广告选择页，点击展示广告方法申请广告跟踪权限，使用getOAID方法获取OAID信息。
 * 2. 将OAID信息作为请求参数，获取广告信息。
 * 3. 显示广告展示页面，广告结束后，回到广告选择页。
 */

export enum AdType {
  // 开屏广告的类型
  SPLASH_AD = 1,
}

const TAG = 'LaunchAdvertView';

@Component
export struct LaunchAdvertView {
  // 内容区相隔距离
  private columnSpace: number = 16;
  // 当前路由栈
  @Consume('pageStack') pageStack: NavPathStack;
  // 当前context
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 申请广告申请权限成功
  private requestOAIDPermissionSuccess: number = 0;
  // 广告配置
  private adOptions: advertising.AdOptions = {};
  // 测试视频广告位id
  private videoAvertID: string = 'x8vut0ippz';
  // 测试图片广告位id
  private imageAdvertID: string = 'u5q0a64rrh';
  // 是否是视频广告
  private isVideoAdvert: boolean = true;
  // 获取广告数量
  private requestAdvertCount: number = 1;
  // Toast显示时间
  private promtionDuration: number = 2000;
  // 广告数据
  private ads?: Array<advertising.Advertisement> = [];
  // 是否是全屏广告
  private isFullScreenAdvert?: boolean = false;
  // 是否展示广告
  @State advertShow: boolean = false;
  // 描述标题
  @State title: Resource = $r('app.string.launch_title');
  // 描述详情
  @State content: Resource = $r('app.string.launch_detail');

  // 进入页面时触发动态授权弹框，向用户请求授权广告跟踪权限。需在模块的module.json5文件中，申请广告跟踪权限ohos.permission.APP_TRACKING_CONSENT。
  requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ["ohos.permission.APP_TRACKING_CONSENT"]).then((data) => {
        if (data.authResults[0] == this.requestOAIDPermissionSuccess) {
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
            // 请求广告信息
            this.requestAd({
              // 当前广告位ID为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID。应用上线后，才会下发广告任务，并请求到广告，做展示。
              // TODO 知识点: 当前广告位ID为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID。正式广告位ID获取方法参考请参考 https://developer.huawei.com/consumer/cn/forum/topic/0204858516053660175
              adId: this.isVideoAdvert ? this.videoAvertID : this.imageAdvertID,
              adType: AdType.SPLASH_AD,
              adCount: this.requestAdvertCount,
              // TODO 知识点: 获取取的OAID添加到广告请求参数中，请求广告信息。以便为用户推荐更为精准的广告。
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
          duration: this.promtionDuration
        });
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        logger.info(TAG, 'request ad success');
        if (canIUse("SystemCapability.Advertising.Ads")) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            // 开屏广告展示页面
            try {
              // 调用广告展示页面
              this.isFullScreenAdvert = ads[0]?.isFullScreen === true;
              this.ads = ads;
              this.advertShow = true;
            } catch (err) {
              logger.error(TAG, `show ad catch error: ${JSON.stringify(err)}`);
            }
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
      // TODO 知识点： 使用loadAd加载广告信息，第一个参数是广告请求参数，第二个参数是广告配置，第三个是广告请求回调监听
      load.loadAd(adReqParams, adOptions, adLoaderListener);
    }
  }

  build() {
    Stack() {
      // 选择广告视图
      Column({ space: this.columnSpace }) {
        // 描述层
        FunctionDescription({ title: this.title, content: this.content })

        // 视频广告按钮
        Button($r('app.string.video_button'))
          .fontColor(Color.White)
          .margin($r('app.string.ohos_id_card_margin_start'))
          .height($r('app.integer.launch_advert_button_height'))
          .width($r('app.string.button_size'))
          .onClick(() => {
            // 请求视频广告
            this.isVideoAdvert = true;
            // 申请广告跟踪权限，获取广告信息
            this.requestOAIDTrackingConsentPermissions(this.context);
          })

        // 图片广告按钮
        Button($r('app.string.image_button'))
          .fontColor(Color.White)
          .margin($r('app.string.ohos_id_card_margin_start'))
          .height($r('app.integer.launch_advert_button_height'))
          .width($r('app.string.button_size'))
          .onClick(() => {
            // 请求图片广告
            this.isVideoAdvert = false;
            // 申请广告跟踪权限，获取广告信息
            this.requestOAIDTrackingConsentPermissions(this.context);
          })
      }

      // 广告展示视图
      if (this.advertShow) {
        AdvertShowPage({ advertShow: this.advertShow, ads: this.ads, isFullScreenAdvert: this.isFullScreenAdvert })
      }
    }
    .align(Alignment.Top)
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}