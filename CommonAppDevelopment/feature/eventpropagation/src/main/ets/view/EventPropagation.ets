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

@Component
export struct EventPropagation {
  // 初始化控制使能开关变量
  @Provide isEnabled: boolean = true;

  build() {
    Column() {
      Row() {
        // 阻塞事件冒泡使能开关
        Text($r('app.string.control_enable_toggle'))
          .fontSize($r('app.integer.enable_toggle_text_font_size'))
          .margin({ left: $r('app.integer.common_space_size') })

        Toggle({ type: ToggleType.Switch, isOn: this.isEnabled })
          .selectedColor($r('app.color.toggle_selectedColor'))
          .switchPointColor($r('app.color.toggle_switchpointColor'))
          .onChange((isOn: boolean) => {
            this.isEnabled = isOn;
          })
      }.width($r('app.string.common_container_width'))
      .height($r('app.integer.enable_toggle_module_height'))
      .justifyContent(FlexAlign.End)

      // 点击事件组件
      ClickEvent()
      // 触摸事件组件
      TouchEvent()
    }.padding($r('app.integer.common_space_size'))
  }
}

/**
 * 场景描述：
 * enabled的值为false时，点击Button按钮，会导致父组件的点击事件触发。这时需要对Button组件包裹一层容器组件，
 并设置hitTestBehavior属性，属性值设置为HitTestMode.Block，可阻止事件的透传。(enabled：控制组件是否可交互，可交互状态下响应点击事件、触摸事件、拖拽事件、按键事件、焦点事件和鼠标事件。)
 此方案同样可以使用于自定义组件场景。
 enabled参考文档：
 https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/arkui-ts/ts-universal-attributes-enable.md/
 hitTestBehavior参考文档：
 https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/ts-universal-attributes-hit-test-behavior-0000001630146313-V4
 */
@Component
struct ClickEvent {
  // 初始化控制使能开关变量
  @Consume isEnabled: boolean;
  // 父组件响应次数
  @State parentCompResponseTimes: number = 0;
  // 子组件响应次数
  @State childCompResponseTimes: number = 0;

  build() {
    Column() {
      Text($r('app.string.click_event_title'))
        .fontSize($r('app.integer.title_font_size'))
        .width('100%')
        .margin($r('app.integer.common_space_size'))
        .textAlign(TextAlign.Start)
      Column() {
        // 父组件响应次数
        Row() {
          Text($r('app.string.parent_component_response_times_text'))
            .fontSize($r('app.integer.response_text_font_size'))
          Text(`${this.parentCompResponseTimes}`)
            .fontSize($r('app.integer.response_text_font_size'))
        }.margin({ bottom: $r('app.integer.common_space_size') })

        // 子组件响应次数
        Row() {
          Text($r('app.string.child_component_response_times_text'))
            .fontSize($r('app.integer.response_text_font_size'))
          Text(`${this.childCompResponseTimes}`)
            .fontSize($r('app.integer.response_text_font_size'))
        }.margin({ bottom: $r('app.integer.common_space_size') })

        Column() {
          Button(this.isEnabled ? $r('app.string.child_component_no_response') : $r('app.string.child_component_response'))
            .enabled(false)
            .fontSize($r('app.integer.child_component_font_size'))
            .width($r('app.integer.button_width_size'))
            .height($r('app.integer.button_height_size'))
            .onClick(() => {
              this.childCompResponseTimes++;
            })
        }
        /*
         TODO：知识点：在onClick事件里，需要将Button按钮包裹一层容器组件，在此容器组件通过使用hitTestBehavior来阻止事件冒泡(子组件向父组件透传onClick事件)，
          hitTestBehavior的属性值设置为HitTestMode.Block。
         */
        .hitTestBehavior(this.isEnabled ? HitTestMode.Block : HitTestMode.Default)

        Text($r('app.string.parent_component_text'))
          .fontSize($r('app.integer.parent_component_text_font_size'))
          .width($r('app.integer.parent_component_text_width_size'))
          .maxLines(2)
          .textAlign(TextAlign.Start)
          .position({ x: $r('app.string.position_common_space'), y: $r('app.string.position_common_space') })
          .translate({ x: -150, y: -40 })

      }
      .width($r('app.string.common_container_width'))
      .height($r('app.integer.button_click_event_area_height'))
      .backgroundColor($r('app.color.click_event_area_background_color'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 冒泡事件发生时，该回调不会触发
        this.parentCompResponseTimes++;
      })
    }
  }
}

/**
 * 场景描述：
 * 触摸事件中，当子组件触发触摸事件的时候，父组件如果设置触摸事件的话，也会触发。
 这时需要在onTouch函数中执行event.stopPropagation()可阻止事件的透传。
 */
@Component
struct TouchEvent {
  // 初始化控制使能开关变量
  @Consume isEnabled: boolean;
  // 父组件响应次数
  @State parentCompResponseTimes: number = 0;
  // 子组件响应次数
  @State childCompResponseTimes: number = 0;

  build() {
    Column() {
      Text($r('app.string.touch_event_title'))
        .fontSize($r('app.integer.title_font_size'))
        .width('100%')
        .margin($r('app.integer.common_space_size'))
        .textAlign(TextAlign.Start)
      Column() {
        // 父组件响应次数
        Row() {
          Text($r('app.string.parent_component_response_times_text'))
            .fontSize($r('app.integer.response_text_font_size'))
          Text(`${this.parentCompResponseTimes}`)
            .fontSize($r('app.integer.response_text_font_size'))
        }.margin({ bottom: $r('app.integer.common_space_size') })

        // 子组件响应次数
        Row() {
          Text($r('app.string.child_component_response_times_text'))
            .fontSize($r('app.integer.response_text_font_size'))
          Text(`${this.childCompResponseTimes}`)
            .fontSize($r('app.integer.response_text_font_size'))
        }.margin({ bottom: $r('app.integer.common_space_size') })


        Text(this.isEnabled ? $r('app.string.child_component_no_response') : $r('app.string.child_component_response'))
          .width($r('app.integer.button_width_size'))
          .height($r('app.integer.button_height_size'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.integer.child_component_border_radius'))
          .backgroundColor(Color.White)
          .onTouch((event) => {
            if (event.type === TouchType.Down) {
              if (this.isEnabled) {
                event.stopPropagation(); // TODO：知识点：在onTouch事件里，通过调用event.stopPropagation()阻止事件冒泡(子组件向父组件透传Touch事件)
              }
              this.childCompResponseTimes++;
            }
          })
        Text($r('app.string.parent_component_text'))
          .fontSize($r('app.integer.parent_component_text_font_size'))
          .width($r('app.integer.parent_component_text_width_size'))
          .maxLines(2)
          .textAlign(TextAlign.Start)
          .position({ x: $r('app.string.position_common_space'), y: $r('app.string.position_common_space') })
          .translate({ x: -150, y: -40 })
      }
      .width($r('app.string.common_container_width'))
      .height($r('app.integer.button_click_event_area_height'))
      .backgroundColor($r('app.color.click_event_area_background_color'))
      .margin($r('app.integer.common_space_size'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onTouch((event) => {
        // 冒泡事件发生时，该回调不会触发
        if (event.type === TouchType.Down) {
          this.parentCompResponseTimes++;
        }
      })
    }
  }
}

