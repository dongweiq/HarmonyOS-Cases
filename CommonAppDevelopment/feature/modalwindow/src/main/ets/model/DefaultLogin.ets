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

import promptAction from '@ohos.promptAction';
import { OtherWaysToLogin, ReadAgreement } from './OtherWaysToLogin';

const EFFECT_DURATION = 800;
const EFFECT_OPACITY = 0.4;
const SPACE_TEN = 10;

@Component
export struct DefaultLogin {
  /**
   * isPresentInLoginView控制登录页面是否显示
   * 子组件中被@Link装饰的变量与其父组件中@State装饰的对应数据源建立双向数据绑定，详见：
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-link-0000001820999565
   */
  @Link isPresentInLoginView: boolean;
  // 是否是默认一键登录方式
  @State isDefaultLogin: boolean = true;
  // 用户名
  userName: string = '18888888888';
  // 判断是否同意协议
  isConfirmed: boolean = false;
  private effect: TransitionEffect = TransitionEffect.OPACITY
    .animation({ duration: EFFECT_DURATION })
    .combine(TransitionEffect.opacity(EFFECT_OPACITY))

  // 默认一键登录方式
  @Builder
  DefaultLoginPage() {
    Column({ space: SPACE_TEN }) {
      Row({ space: SPACE_TEN }) {
        Image($r('app.media.batman'))
          .width($r('app.integer.user_image_height'))
          .height($r('app.integer.user_image_height'))
        Column({ space: SPACE_TEN }) {
          Text($r('app.string.welcome_back'))
            .fontWeight(FontWeight.Bold)
            .fontSize($r('app.integer.font_size_mid'))
            .fontColor(Color.Black)

          Text($r('app.string.more_wonderful_after_login'))
            .fontColor($r('app.color.grey_3'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width($r('app.string.size_full'))

      Text(this.userName)
        .fontColor($r('app.color.grey_3'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: $r('app.integer.padding_default') })
        .height($r('app.integer.user_image_height'))
        .width($r('app.string.size_full'))
        .borderRadius($r('app.integer.border_radius'))
        .backgroundColor($r('app.color.grey_e'))

      Text($r('app.string.verify_server_tip'))
        .fontColor($r('app.color.grey_6'))
        .width($r('app.string.size_full'))
        .textAlign(TextAlign.Start)

      Row() {
        Checkbox({ name: 'checkbox1' })
          .select(this.isConfirmed)
          .onChange((value: boolean) => {
            this.isConfirmed = value
          })
        ReadAgreement()
      }
      .width($r('app.string.size_full'))
      .alignItems(VerticalAlign.Center)

      Button($r('app.string.phone_start_login'))
        .fontColor(Color.White)
        .borderRadius($r('app.integer.border_radius'))
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.grey_2'))
        .onClick(() => {
          if (this.isConfirmed) {
            // 调用Toast显示登录成功提示
            promptAction.showToast({ message: $r('app.string.login_success') });
          } else {
            // 调用Toast显示请先阅读并同意协议提示
            promptAction.showToast({ message: $r('app.string.please_read_and_agree') });
          }
        })
        .width($r('app.string.size_full'))
        .height($r('app.integer.height_fifty'))
      Row() {
        Text($r('app.string.other_way_login'))
          .fontColor($r('app.color.grey_7'))
          .backgroundColor($r('app.color.transparent_7'))
          .onClick(() => {
            this.isDefaultLogin = false;
          })

        Blank() // 在容器主轴方向上自动填充容器空余部分

        Text($r('app.string.login_problems'))
          .fontColor($r('app.color.grey_7'))
          .backgroundColor($r('app.color.transparent_7'))
          .onClick(() => {
            // 调用Toast显示遇到问题提示
            promptAction.showToast({ message: $r('app.string.login_problems') });
          })
      }
      .width($r('app.string.size_full'))
    }
    .width($r('app.string.size_full'))
    .height($r('app.string.size_full'))
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 登录方式有两种(默认一键登录方式和其他方式登录)，需要在一个模态窗口中切换，使用if进行条件渲染
      if (this.isDefaultLogin) {
        this.DefaultLoginPage() // 默认一键登录方式
      } else {
        OtherWaysToLogin()// 其他登录方式
          .transition(this.effect) // 此处涉及到组件的显示和消失，所以使用transition属性设置出现/消失转场
      }
      Image($r('app.media.arrow_back'))// 通过Stack组件，两个页面只实现一个back
        .width($r('app.integer.height_twenty_five')).height($r('app.integer.height_twenty_five'))
        .margin({ top: $r('app.integer.margin_mid') })
        .onClick(() => {
          if (this.isDefaultLogin) {
            this.isPresentInLoginView = false;
          } else {
            this.isDefaultLogin = true
          }
        })
    }
    .size({ width: $r('app.string.size_full'), height: $r('app.string.size_full') })
    .padding({
      top: $r('app.integer.padding_default'),
      left: $r('app.integer.padding_default'),
      right: $r('app.integer.padding_default')
    })
    .backgroundColor(Color.White) // 将模态页面背景设置为白色，以避免模态页面内组件发生显隐变化时露出下层页面
  }
}