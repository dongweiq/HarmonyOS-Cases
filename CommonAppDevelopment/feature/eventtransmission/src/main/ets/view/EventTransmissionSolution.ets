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
 * 场景:Button按钮组件将enabled设置为false，点击Button按钮期待父组件接收不到事件
 *
 */
import promptAction from '@ohos.promptAction';

@Component
export struct EventTransmissionSolution {
  // 初始化控制使能开关变量
  @Provide isEnable: boolean = false;

  build() {
    Column() {
      // 控制Button按钮使能开关模块
      Row() {
        Text($r('app.string.control_enable_toggle'))
          .fontSize($r('app.integer.enable_toggle_text_font_size'))
          .margin({ left: $r('app.integer.common_space_size') })

        Toggle({ type: ToggleType.Switch, isOn: this.isEnable })
          .selectedColor($r('app.color.toggle_selectedColor'))
          .switchPointColor($r('app.color.toggle_switchpointColor'))
          .onChange((isOn: boolean) => {
            this.isEnable = isOn;
          })
      }.width($r('app.string.common_container_width'))
      .height($r('app.integer.enable_toggle_module_height'))
      .justifyContent(FlexAlign.End)

      Column() {
        Text('ClickEvent')
          .fontSize($r('app.integer.title_font_size'))
          .margin($r('app.integer.common_space_size'))

        // 点击事件模块
        ClickEvent()
          .width($r('app.string.common_container_width'))
          .height($r('app.integer.button_click_event_area_height'))
          .backgroundColor($r('app.color.click_event_area_background_color')) // 父组件点击事件，触发弹窗事件
          .onClick(() => {
            promptAction.showToast({
              message: $r('app.string.parent_component_dialog_message')
            })
          })
        Text('MouseEvent')
          .fontSize($r('app.integer.title_font_size'))
          .margin($r('app.integer.common_space_size'))
        // 鼠标事件模块
        MouseEvent()
          .width($r('app.string.common_container_width'))
          .height($r('app.integer.button_click_event_area_height'))
          .backgroundColor($r('app.color.click_event_area_background_color')) // 父组件点击事件，触发弹窗事件
          .margin({ top: $r('app.integer.common_space_size') })
          .onMouse((event) => {
            if (event.action === MouseAction.Press) {
              promptAction.showToast({
                message: $r('app.string.parent_component_dialog_message')
              })
            }
          })
      }
      .justifyContent(FlexAlign.End)
    }.padding($r('app.integer.common_space_size'))
  }
}

@Component
struct ClickEvent {
  // 初始化控制使能开关变量
  @Consume isEnable: boolean;

  build() {
    Column() {
      Button($r('app.string.child_component')) // 1.enabled的值为false时，点击Button按钮，会导致父组件的点击事件触发，解决方案请看下一步操作。
        .enabled(this.isEnable) // Button点击事件，触发弹窗事件
        .onClick(() => {
          promptAction.showToast({
            message: $r('app.string.click_event_alert_dialog_message')
          })
        })
    }
    // 2.hitTestBehavior为触摸测试控制属性，设置为HitTestMode.Block，可阻止事件的透传。
    // hitTestBehavior参考文档：https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/ts-universal-attributes-hit-test-behavior-0000001630146313-V4
    .hitTestBehavior(this.isEnable ? HitTestMode.Default : HitTestMode.Block)
  }
}

@Component
struct MouseEvent {
  // 初始化控制使能开关变量
  @Consume isEnable: boolean;

  build() {
    Column() {
      Button($r('app.string.child_component'))
        .enabled(this.isEnable) // 鼠标按下事件
        .onMouse((event) => {
          if (event.action === MouseAction.Press) {
            if (this.isEnable) {
              event.stopPropagation(); // 阻止enabled的属性值为true的时候透传。
            }
            promptAction.showToast({
              message: $r('app.string.click_event_alert_dialog_message')
            })
          }
        })
    }
    .hitTestBehavior(this.isEnable ? HitTestMode.Default : HitTestMode.Block)
  }
}

