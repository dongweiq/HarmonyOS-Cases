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
import { FunctionDescription } from '@ohos/base';
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsrouter/Index';

@Component
export struct EventPropagation {
  // 初始化控制使能开关变量
  @Provide isEnabled: boolean = true;

  build() {
    Column() {
      // 场景描述组件
      FunctionDescription({ title: $r('app.string.event_propagation'), content: $r('app.string.event_content') })
      Row() {
        // 阻塞事件冒泡使能开关
        Text($r('app.string.control_enable_toggle'))

        Toggle({ type: ToggleType.Switch, isOn: this.isEnabled })
          .selectedColor($r('app.color.toggle_selectedColor'))
          .switchPointColor($r('app.color.toggle_switchpointColor'))
          .onChange((isOn: boolean) => {
            this.isEnabled = isOn;
          })
      }.width($r('app.string.common_container_width'))
      .height($r('app.integer.enable_toggle_module_height'))
      .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
      .justifyContent(FlexAlign.SpaceBetween)

      // 点击事件组件
      ClickEvent()
      // 触摸事件组件
      TouchEvent()
    }.padding($r('app.string.ohos_id_card_padding_start'))
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

  build() {
    Column() {
      Text($r('app.string.click_event_title'))
        .width($r('app.string.common_container_width'))
        .textAlign(TextAlign.Start)
      Column() {
        Text($r('app.string.parent_component_text'))
          .margin($r('app.string.ohos_id_elements_margin_vertical_m'))
        // 父组件响应次数
        Row() {
          Text($r('app.string.parent_component_response_times_text'))
          Text(`${this.parentCompResponseTimes}`)
        }
        .margin({
          top: $r('app.string.ohos_id_elements_margin_vertical_m'),
          bottom: $r('app.string.ohos_id_elements_margin_vertical_m')
        })

        Column() {
          Button($r('app.string.child_component_response'))
            .width($r('app.integer.button_width_size'))
            .height($r('app.integer.button_height_size'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
            .enabled(false)
            .onClick(() => {
            })
        }
        /*
         TODO：知识点：在onClick事件里，需要将Button按钮包裹一层容器组件，在此容器组件通过使用hitTestBehavior来阻止事件冒泡(子组件向父组件透传onClick事件)，
          hitTestBehavior的属性值设置为HitTestMode.Block。
         */
        .hitTestBehavior(this.isEnabled ? HitTestMode.Block : HitTestMode.Default)
      }
      .width($r('app.string.common_container_width'))
      .height($r('app.integer.button_click_event_area_height'))
      .backgroundColor($r('app.color.ohos_id_color_sub_background'))
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        // 冒泡事件发生时，该回调不会触发
        this.parentCompResponseTimes++;
      })
      .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    }.margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
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
        .width($r('app.string.common_container_width'))
        .textAlign(TextAlign.Start)
      Column() {
        Text($r('app.string.parent_component_text_touch'))
          .margin($r('app.string.ohos_id_elements_margin_vertical_m'))
        // 父组件响应次数
        Row() {
          Text($r('app.string.parent_component_response_times_text'))
          Text(`${this.parentCompResponseTimes}`)
        }
        .margin({
          top: $r('app.string.ohos_id_elements_margin_vertical_m'),
          bottom: $r('app.string.ohos_id_elements_margin_vertical_m')
        })

        // 子组件响应次数
        Row() {
          Text($r('app.string.child_component_response_times_text'))
          Text(`${this.childCompResponseTimes}`)
        }.margin({ bottom: $r('app.string.ohos_id_elements_margin_vertical_m') })

        Text($r('app.string.child_touch_component_response'))
          .width($r('app.integer.button_width_size'))
          .height($r('app.integer.button_height_size'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .backgroundColor($r('sys.color.ohos_id_color_focused_bg'))
          .onTouch((event) => {
            if (this.isEnabled) {
              event.stopPropagation(); // TODO：知识点：在onTouch事件里，通过调用event.stopPropagation()阻止事件冒泡(子组件向父组件透传Touch事件)
            }
            this.childCompResponseTimes++;
          })
      }
      .width($r('app.string.common_container_width'))
      .height($r('app.integer.button_click_event_area_height'))
      .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
      .backgroundColor($r('app.color.ohos_id_color_sub_background'))
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      .alignItems(HorizontalAlign.Center)
      .onTouch(() => {
        // 冒泡事件发生时，该回调不会触发
        this.parentCompResponseTimes++;
      })
    }.margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getEventPropagation(): void {
  EventPropagation();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(getEventPropagation);
  DynamicsRouter.registerBuilder(builderName, builder);
}
