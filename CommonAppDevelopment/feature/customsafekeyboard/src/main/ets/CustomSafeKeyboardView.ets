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
 * 实现步骤：
 *  1. 通过TextInput.customKeyboard绑定自定义键盘
 *  2. 自定义键盘使用网格布局，定义数组保存每个按键的值、UI属性和位置，并循环渲染数组完成键盘布局
 *  3. 在字母和特殊字符键盘中将网格拆分为4 * 20布局，保证每个按键都要占用整数单元
 *  4. 在父组件定义按键响应函数onKeyboardEvent，可根据不同的按键类型实现数据更新，然后子组件按键时调用父组件传递过来的onKeyboardEvent即可
 *  5. 在子组件中，必须定义inputValue且使用@Link装饰器，这样能保证子组件调用时onKeyboardEvent时inputValue不为空，父子组件数据双向更新
 */

import { CustomKeyboard } from './components/CustomKeyboard';
import { logger } from 'utils';
import {
  EKeyType,
  EKeyboardType,
  IKeyAttribute,
  lowerCaseKeyData,
  numericKeyData,
  specialKeyData,
  upperCaseKeyData
} from './model/Constants';

@Component
export struct CustomSafeKeyboardView {
  // TextInput输入的值
  @State inputValue: string = '';
  // 当前键盘类型，默认为数字键盘
  @State curKeyboardType: EKeyboardType = EKeyboardType.NUMERIC;
  // 键盘按键数组
  @State items: IKeyAttribute[] = numericKeyData;
  controller: TextInputController = new TextInputController();

  /**
   * 键盘按键事件响应函数
   * @param item 键盘按键数据项
   */
  onKeyboardEvent(item: IKeyAttribute) {
    switch (item.type) {
      // 输入类型，更新输入内容
      case EKeyType.INPUT:
        this.inputValue += item.value;
        break;
      // 删除一个已输入的末尾字符
      case EKeyType.DELETE:
        this.inputValue = this.inputValue.slice(0, -1);
        break;
      // 切换数字字符键盘
      case EKeyType.NUMERIC:
        if (this.curKeyboardType !== EKeyboardType.NUMERIC) {
          this.curKeyboardType = EKeyboardType.NUMERIC;
          this.items = numericKeyData;
        }
        break;
      // 切换大小写
      case EKeyType.CAPSLOCK:
        if (this.curKeyboardType === EKeyboardType.LOWERCASE) {
          // 切换大写字母键盘
          this.curKeyboardType = EKeyboardType.UPPERCASE;
          this.items = upperCaseKeyData;
        } else {
          // 切换小写字母键盘
          this.curKeyboardType = EKeyboardType.LOWERCASE;
          this.items = lowerCaseKeyData;
        }
        break;
      // 切换特殊字符键盘
      case EKeyType.SPECIAL:
        if (this.curKeyboardType !== EKeyboardType.SPECIAL) {
          this.curKeyboardType = EKeyboardType.SPECIAL;
          this.items = specialKeyData;
        }
        break;
      default:
        logger.info('Sorry, we are out of input type.')
    }
  }

  /**
   * 自定义键盘组件Builder
   */
  @Builder
  customKeyboardBuilder() {
    CustomKeyboard({
      items: this.items,
      inputValue: this.inputValue,
      curKeyboardType: this.curKeyboardType,
      onKeyboardEvent: this.onKeyboardEvent,
      controller: this.controller
    })
  }

  build() {
    Column() {
      Image($r("app.media.avatar"))
        .width($r("app.integer.avatar_weight"))
        .height($r("app.integer.avatar_height"))
        .margin({top: $r("app.integer.row_height")})
        .objectFit(ImageFit.Fill)

      Text($r("app.string.account_name"))
        .fontSize($r("app.integer.text_font_size"))
        .margin({ top: $r("app.integer.common_margin_padding") })

      TextInput({
        text: this.inputValue,
        placeholder: $r("app.string.placeholder"),
        controller: this.controller
      })
        .type(InputType.Password)
        .customKeyboard(this.customKeyboardBuilder()) // TODO:知识点: 绑定自定义安全键盘
        .height($r("app.integer.text_input_height"))
        .margin({ top: $r("app.integer.common_margin_padding") })

      Button($r("app.string.login_button_label"))
        .type(ButtonType.Capsule)
        .fontSize($r("app.integer.login_button_font_size"))
        .width($r("app.integer.login_button_width"))
        .height($r("app.integer.login_button_height"))
        .margin({ top: $r("app.integer.login_button_margin") })
        .backgroundColor(Color.Pink)
        .onClick(() => {
          this.controller.stopEditing();
        })

    }
    .width($r("app.string.one_hundred_percent"))
    .height($r("app.string.one_hundred_percent"))
    .padding($r("app.integer.common_margin_padding"))
  }
}
