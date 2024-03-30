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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { CaptchaLogin } from '../model/CaptchaLogin';
import promptAction from '@ohos.promptAction';

const SPACE_THIRTY = 30;

/**
 * 场景描述：
 * 登录方式有两种，验证码登录和账户，需要在一个全屏模态窗口CaptureLogin中切换，使用if进行条件渲染
 * 1、通过配置NavDestinationMode类型为DIALOG，实现半模态的背景为透明
 * 2、通过bindSheet属性为主页无样式的Text绑定半模态页面，再通过bindContentCover属性为主页无样式的Text绑定全屏模态页面
 * 3、在半模态页面中的验证码登录按钮点击时打开全屏模态转场，并将对应的组件入场动效置为空，此时进场只保留全屏模态入场动效
 * 4、通过点击第二步中的按钮跳转到全屏模态组件(CaptureLogin)，并通过通过isDefaultLogin控制两种登录组件的条件渲染：true(手机验证码登录),false(二维码登录)
 * 控制两种登录方式的条件渲染，同时通过TransitionEffect.move()实现组件间转场。
 * 子组件中被@Link装饰的变量与其父组件中@State装饰的对应数据源建立双向数据绑定，详见：
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-link-0000001820999565
 * 半模态转场详见：
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-sheet-transition-0000001820880845
 * NavDestinationMode配置：
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navdestination-0000001774280918#ZH-CN_TOPIC_0000001774280918__navdestinationmode
 * 组件内转场transition:
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-transition-animation-component-0000001774121354
 */
@Component
export struct HalfModalWindow {
  // 是否显示半屏模态页面
  @State isPresent: boolean = false;
  // 半模态高度
  @State sheetHeight: number = 500;
  // 是否显示控制条
  @State showDragBar: boolean = true;
  // 判断是否同意协议
  @State isConfirmed: boolean = false;
  // 控制全模态的展示
  @State isPresentInLoginView: boolean = false;
  // 发送验证码按钮的透明度
  @State op: number = 0.5;
  @Consume('pageStack') pageStack: NavPathStack;
  // 用于标识转场类型，从半模态跳转至手机验证码组件时为false，从账号密码组件跳转至手机验证码组件时为true
  @State isShowTransition: boolean = false;

  aboutToAppear(): void {
    this.isPresent = true; // 当isPresent为true时显示半模态页面，反之不显示
  }

  @Builder
  defaultLogin() {
    Column() {
      // 在登录页中控制，半模态、全模态和半模态的确认的checkBox
      CaptchaLogin({
        isPresent: $isPresent, isPresentInLoginView: $isPresentInLoginView, isShowTransition: $isShowTransition
      })
    }
  }

  @Builder
  halfModalLogin() { // 半模态窗口页面
    Column() {
      Text($r('app.string.after_login_more_service'))
        .fontColor(Color.Black)
        .fontSize(18)
        .padding({ top: 60 })

      Text($r('app.string.user_phone_number'))
        .fontColor(Color.Black)
        .fontSize(30)
        .fontWeight(50)
        .padding({ top: 30, bottom: 10 })

      Text($r('app.string.get_service'))
        .fontColor($r('app.color.grey_9'))
        .fontSize(15)
        .padding({ bottom: 50 })

      Button($r('app.string.phone_start_login'))
        .fontColor(Color.White)
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.red'))
        .onClick(() => {
          if (this.isConfirmed) {
            // 调用Toast显示登录成功提示
            promptAction.showToast({ message: $r('app.string.login_success') });
          } else {
            // 调用Toast显示请先阅读并同意协议提示
            promptAction.showToast({ message: $r('app.string.please_read_and_agree') });
          }
        })
        .width("90%")
        .height($r('app.integer.height_fifty'))
        .margin({ left: 12, right: 12, bottom: 10 })

      Button($r('app.string.captcha_login_text'))
        .fontColor(Color.Black)
        .borderRadius($r('app.integer.border_radius'))
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.btn_bgc'))
        .border({
          color: $r('app.color.half_modal_btn_bgc'),
          width: 1
        })
        .onClick(() => {
          if (this.isConfirmed) {
            // 半模态页面中调出全模态登录页
            this.isPresentInLoginView = true;
            this.isConfirmed = false;
            this.isShowTransition = false;
          } else {
            // 调用Toast显示请先阅读并同意协议提示
            promptAction.showToast({ message: $r('app.string.please_read_and_agree') });
          }
        })
        .width("90%")
        .height($r('app.integer.height_fifty'))
        .margin({ bottom: 30 })
      Blank() // 在容器主轴方向上自动填充容器空余部分
      Row({ space: SPACE_THIRTY }) {
        Image($r("app.media.app_logo1"))
          .width($r('app.integer.other_ways_icon_height'))
          .borderRadius($r('app.integer.other_ways_border_radius'))
          .onClick(() => {
            // 调用Toast显示提示:此样式仅为案例展示
            promptAction.showToast({ message: $r('app.string.only_show_ui') });
          })

        Image($r("app.media.app_logo2"))
          .width($r('app.integer.other_ways_icon_height'))
          .borderRadius($r('app.integer.other_ways_border_radius'))
          .onClick(() => {
            // 调用Toast显示提示:此样式仅为案例展示
            promptAction.showToast({ message: $r('app.string.only_show_ui') });
          })

        Image($r("app.media.app_logo3"))
          .width($r('app.integer.other_ways_icon_height'))
          .borderRadius($r('app.integer.other_ways_border_radius'))
          .onClick(() => {
            // 调用Toast显示提示:此样式仅为案例展示
            promptAction.showToast({ message: $r('app.string.only_show_ui') });
          })
      }.margin({ bottom: 20 })

      Row() {
        Checkbox({ name: 'checkbox' })
          .select(this.isConfirmed)
          .width(14)
          .onChange((value: boolean) => {
            this.isConfirmed = value;
          })
        Text() {
          Span($r('app.string.read_and_agree'))
            .fontColor($r('app.color.grey_9'))
          Span($r('app.string.server_proxy_rule_detail'))
            .fontColor($r('app.color.note_color'))
            .onClick(() => {
              // 调用Toast显示提示:此样式仅为案例展示
              promptAction.showToast({ message: $r('app.string.only_show_ui') });
            })
        }.fontSize(14)
      }
      .margin({ left: 32 })
      .width($r('app.string.size_full'))
    }
  }

  build() {
    Column() {
      // TODO：需求：增加其他登录方式，如全模态窗口
      Text()
        /**
         * TODO: 知识点: 通过bindSheet属性为组件绑定半模态页面，由于半模态必须绑定组件，
         * 此处绑定无样式的Text组件作为开屏半模态展示。
         * isPresent：是否显示半模态页面
         */
        .bindSheet($$this.isPresent, this.halfModalLogin(), {
          // Text绑定半模态转场
          height: this.sheetHeight, // 半模态高度
          dragBar: this.showDragBar, // 是否显示控制条
          backgroundColor: $r('app.color.btn_bgc'),
          showClose: true, // 是否显示关闭图标
          shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
            sheetDismiss.dismiss();
            this.pageStack.pop();
          })
        })

      Text()
        /**
         * TODO: 知识点: 通过bindContentCover属性为组件绑定全屏模态页面，由于全屏模态必须绑定组件，
         * 此处绑定无样式的Text组件作为手机验证码组件和账号密码组件的全屏模态展示。
         * isPresentInLoginView：是否显示全屏模态页面
         */
        .bindContentCover($$this.isPresentInLoginView, this.defaultLogin())
    }
    .justifyContent(FlexAlign.Center)
    .size({ width: $r('app.string.size_full'), height: $r('app.string.size_full') })
    .padding($r('app.integer.padding_default'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getHalfModalWindow(): void {
  HalfModalWindow();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.MULTI_MODAL_TRANSITION, wrapBuilder(getHalfModalWindow));