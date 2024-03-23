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

const PHONE_NUMBER_LENGTH = 11;
const SPACE_TWENTY = 20;
const SPACE_TEN = 10;

/**
 * 其他账号登录：主要提供短信验证码登录方式，以及其他三方应用登录方式
 */
@Component
export struct OtherWaysToLogin {
  // 发送验证码按钮的颜色
  @State buttonColor: ResourceColor = Color.Grey;
  // 是否勾选阅读并同意服务协议及个人信息处理规则
  isAgree: boolean = false;
  loginIcons: Resource[] = [$r('app.media.app_logo1'), $r('app.media.app_logo2'), $r('app.media.app_logo3')]

  build() {
    Column({ space: SPACE_TWENTY }) {
      Column({ space: SPACE_TEN }) {
        Row({ space: SPACE_TEN }) {
          Image($r('app.media.phone')).width($r('app.integer.user_image_height'))
            .borderRadius($r('app.integer.border_radius_mid'))
          Text($r('app.string.phone_login')).fontSize($r('app.integer.font_size_mid'))
        }
        .width($r('app.string.size_full'))

        Text($r('app.string.new'))
          .width($r('app.string.size_full'))
      }
      .width($r('app.string.size_full'))
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text($r('app.string.86'))
        Image($r('app.media.arrow_right'))
          .size({ width: $r('app.integer.arrow_right_height'), height: $r('app.integer.arrow_right_height') })
          .margin($r('app.integer.margin_default'))
        TextInput({ placeholder: $r('app.string.input_phone_number') })
          .type(InputType.PhoneNumber)// 电话号码输入模式
          .style(TextInputStyle.Inline)
          .backgroundColor(Color.Transparent)
          .caretColor(Color.Grey)
          .width($r('app.string.size_full'))
          .maxLength(PHONE_NUMBER_LENGTH)// 设置最大输入字符数
            // 当输入字符数为11位时，发送验证码按钮变为蓝色，否则置灰
          .onChange((value: string) => {
            if (value.length === PHONE_NUMBER_LENGTH) {
              this.buttonColor = Color.Blue;
            } else {
              this.buttonColor = Color.Grey;
            }
          })
      }

      Button($r('app.string.verify'))
        .type(ButtonType.Normal)
        .border({ radius: $r('app.integer.border_radius') })
        .width($r('app.string.size_full'))
        .backgroundColor(this.buttonColor)
        .onClick(() => {
          // 输入输入字符数为11位，并同意服务协议及个人信息处理规则，才能发送验证码
          if (this.buttonColor === Color.Grey) {
            promptAction.showToast({ message: $r('app.string.message_right_phone_number') })
          } else if (!this.isAgree) {
            promptAction.showToast({ message: $r('app.string.message_read_agreement') })
          } else {
            promptAction.showToast({ message: $r('app.string.message_verify_code_send') })
          }
        })

      Row() {
        Checkbox({ name: 'agreement' })// $$运算符为系统内置组件提供TS变量的引用，使得TS变量和系统内置组件的内部状态保持同步
          .select($$this.isAgree)
        ReadAgreement()
      }
      .width($r('app.string.size_full'))
      .justifyContent(FlexAlign.Start)

      Blank() // 在容器主轴方向上自动填充容器空余部分

      // 其他三方应用登录方式
      List({ space: SPACE_TWENTY }) {
        // 性能知识点：此处在List中排列组件，列表项确定、数量较少，且需要一次性加载，因此使用ForEach。在列表项多的情况下，推荐使用LazyForEach
        ForEach(this.loginIcons, (item: Resource) => {
          ListItem() {
            Image(item)
              .width($r('app.integer.other_ways_icon_height'))
              .borderRadius($r('app.integer.other_ways_border_radius'))
              .onClick(() => {
                // 调用Toast显示三方应用授权登录提示
                promptAction.showToast({ message: $r('app.string.message_third_party_authorization') });
              })
          }
        })
      }
      .listDirection(Axis.Horizontal)
    }
    .width($r('app.string.size_full'))
    .height($r('app.string.size_full'))
    .backgroundColor(Color.White)
    .padding({ bottom: $r('app.integer.padding_mid'), top: $r('app.integer.padding_to_top') })
  }
}

@Component
export struct ReadAgreement {
  build() {
    Text() {
      Span($r('app.string.read_and_agree'))
        .fontColor($r('app.color.grey_9'))
      Span($r('app.string.server_proxy_rule_detail'))
        .fontColor(Color.Orange)
        .onClick(() => {
          // 调用Toast显示用户点击服务协议及个人信息处理规则的提示
          promptAction.showToast({ message: $r('app.string.server_proxy_rule_detail') });
        })
    }
    .textAlign(TextAlign.Start)
  }
}