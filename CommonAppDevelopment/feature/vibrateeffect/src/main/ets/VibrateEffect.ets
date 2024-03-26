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

import vibrator from '@ohos.vibrator';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/base';
import curves from '@ohos.curves';
import { CONFIGURATION } from './components/constantsData';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * 抖动动画及手机振动效果
 * 场景：未勾选服务协议和隐私政策时点击登录
 * 效果：手机产生振动效果，提示文本触发抖动动画
 */

@Component
export struct VibrateEffectView {
  @State translateX: number = 0; // 初始化提示文本的偏移量
  @State confirm: boolean = false; // 是否勾选协议

  // 触发手机振动效果
  startVibrate() {
    try {
      // TODO: 知识点：vibrator.startVibration 根据指定振动效果和振动属性触发马达振动
      vibrator.startVibration({
        type: 'time',
        // 持续触发马达振动时间600ms
        duration: CONFIGURATION.VIBRATION_TIME,
      }, {
        id: 0,
        usage: 'alarm',
      }, (error: BusinessError) => {
        if (error) {
          logger.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        logger.info('Succeed in starting vibration');
      });
    } catch (err) {
      logger.error(`An unexpected error occurred. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 触发提示文本抖动动画效果
  startAnimation() {
    // TODO: 知识点：通过animateTo显示动画指定由于闭包代码导致的状态变化插入过渡动效
    animateTo({
      duration: CONFIGURATION.ANIMATION_TIME,
      // 弹簧曲线：初始速度100，质量1，刚度80，阻尼10
      curve: curves.springCurve(CONFIGURATION.VELOCITY_VALUE, CONFIGURATION.MASS_VALUE,
        CONFIGURATION.STIFFNESS_VALUE, CONFIGURATION.DAMPING_VALUE),
      // 播放2次
      iterations: CONFIGURATION.PLAYBACK_COUNT,
    },
      () => {
        // 抖动动偏移量
        this.translateX = CONFIGURATION.TRANSLATE_OFFSET_X;
      })
    this.translateX = CONFIGURATION.POSITION_ZERO;
  }

  build() {
    Column() {
      Row()
        .width($r('app.string.full_size'))
        .height($r('app.integer.elements_height'))
        .backgroundColor($r('app.color.ohos_id_color_background'))

      Scroll() {
        // 应用图标
        Column({space: CONFIGURATION.MARGIN_VERTICAL}) {
          Image($r('app.media.speed_train'))
            .width($r('app.integer.image_size'))
            .height($r('app.integer.image_size'))
            .backgroundColor($r('app.color.ohos_id_color_palette8'))
            .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))

          // 手机号
          Text($r('app.string.phone_number'))
            .fontSize($r('app.string.ohos_id_text_size_headline'))
            .fontWeight(FontWeight.Bold)

          // 协议阅读与勾选
          Column() {
            Row() {
              Button() {
                Image(this.confirm ? $r('app.media.ic_ok') : $r('app.media.ic_default'))
                  .height($r('app.integer.circle_icon_size'))
                  .width($r('app.integer.circle_icon_size'))
              }
              .onClick(() => {
                this.confirm = !this.confirm;
              })
              .height($r('app.integer.circle_elements_height'))
              .width($r('app.integer.circle_elements_width'))
              .backgroundColor($r('app.color.ohos_id_color_background'))

              Text() {
                Span($r('app.string.read_and_agreed'))
                  .fontColor($r('app.color.ohos_id_color_text_secondary'))
                  .fontSize($r('app.string.ohos_id_text_size_body3'))
                Span($r('app.string.services_and_policies'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.string.ohos_id_text_size_body3'))
                Span($r('app.string.and'))
                  .fontColor($r('app.color.ohos_id_color_text_secondary'))
                  .fontSize($r('app.string.ohos_id_text_size_body3'))
                Span($r('app.string.service_agreement'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.string.ohos_id_text_size_body3'))
                Span($r('app.string.privacy_policy'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.string.ohos_id_text_size_body3'))
              }
              .flexShrink(CONFIGURATION.FLEX_SHRINK)
            }
            .width($r('app.string.full_size'))
            .alignItems(VerticalAlign.Top)

            // 若没有勾选协议，则会出现提示文本：“请阅读并勾选协议”
            if (!this.confirm) {
              Row() {
                Column() {
                  Image($r('app.media.login_popup'))
                    .width($r('app.integer.image_size2'))
                    .height($r('app.integer.image_size2'))
                    .position({ x: CONFIGURATION.POPUP_POSITION_X, y: CONFIGURATION.POPUP_POSITION_Y })
                    .opacity(CONFIGURATION.OPACITY_VALUE)

                  Text($r('app.string.read_and_agree'))
                    .fontColor($r('app.color.ohos_id_color_background'))
                    .fontSize($r('app.string.ohos_id_text_size_caption'))
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r('app.color.ohos_id_color_foreground'))
                    .width($r('app.integer.text_width'))
                    .height($r('app.integer.mark_height'))
                    .position({ x: CONFIGURATION.MARK_POSITION_X, y: CONFIGURATION.MARK_POSITION_Y })
                    .borderRadius($r('app.string.ohos_id_corner_radius_subtab'))
                    .opacity(CONFIGURATION.OPACITY_VALUE)
                }
                .width($r('app.integer.elements_height'))
                .height($r('app.integer.total_mark_height'))
                .position({ x: this.translateX, y: CONFIGURATION.POSITION_ZERO })
              }
              .height($r('app.integer.total_mark_height'))
              .width('100%')
            }
          }

          // 登录按钮
          Button($r('app.string.login_in'))
            .type(ButtonType.Normal)
            .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
            .fontColor($r('app.color.ohos_id_color_background'))
            .fontSize($r('app.string.ohos_id_text_size_body1'))
            .width($r('app.string.full_size'))
            .onClick(() => {
              // 点击登录按钮，若没有勾选协议则触发手机振动效果和抖动动画
              if (this.confirm) {
                logger.info('Login succeeded')
              } else {
                this.startVibrate();
                this.startAnimation();
              }
            })

          Text($r('app.string.other_login_methods'))
            .fontColor($r('app.color.ohos_id_color_palette8'))
            .fontSize($r('app.string.ohos_id_text_size_body2'))
            .backgroundColor($r('app.color.ohos_id_color_background'))
        }
        .width($r('app.string.full_size'))
      }
      .scrollBar(BarState.Off)
    }
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
    .padding(12)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getVibrateEffectView(): void {
  VibrateEffectView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.VIBRATE_EFFECT,wrapBuilder(getVibrateEffectView));