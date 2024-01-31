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
import { inputMethod } from '@kit.IMEKit';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { VerifyCodeConstants } from '../constants/VerifyCodeConstants';

@Extend(Text)
function verifyCodeUnitStyle() {
  .fontSize($r("sys.float.ohos_id_text_size_body1"))
  .fontWeight(VerifyCodeConstants.VERIFY_CODE_FONTWEIGHT)
  .textAlign(TextAlign.Center)
  .width($r("app.integer.code_unit_with"))
  .height('100%')
  .margin({ left: $r("app.integer.code_unit_margin"), right: $r("app.integer.code_unit_margin") })
  .border({
    width: { bottom: $r("app.integer.code_border_width") },
    color: { bottom: Color.Grey },
    style: { bottom: BorderStyle.Solid }
  })
}

@Component
struct VerifyCodeComponentWithoutCursor {
  @State codeText: string = "";
  private inputController: inputMethod.InputMethodController = inputMethod.getController();
  private isAttached: boolean = false;
  private verifyCodeLength: number = 6;

  /**
   * 进行绑定并设置监听
   */
  async setAttachAndListener() {
    if (this.isAttached) {
      return;
    }
    let textConfig: inputMethod.TextConfig = {
      inputAttribute: {
        textInputType: inputMethod.TextInputType.NUMBER,
        enterKeyType: inputMethod.EnterKeyType.GO
      },
    };
    // 绑定控件输入法
    await this.inputController.attach(true, textConfig);
    this.isAttached = true;
    this.attachListener();
  }

  /**
   * TODO 知识点：订阅输入法代插入、向左删除事件
   */
  attachListener() {
    this.inputController.on("insertText", (text: string) => {
      if (this.codeText.length >= this.verifyCodeLength) {
        return;
      }
      this.codeText += text;
      if (this.codeText.length === this.verifyCodeLength) {
        promptAction.showToast({ message: this.codeText });
      }
      Logger.info("VerifyCode [insert]: %{public}s", this.codeText);
    })
    this.inputController.on("deleteLeft", (length: number) => {
      this.codeText = this.codeText.substring(0, this.codeText.length - 1);
      Logger.info("VerifyCode [delete left]: %{public}s", this.codeText);
    })
  }

  /**
   * TODO 知识点：部分验证码场景要完全禁止对输入验证码的选中、复制等功能，因此可以使用Text组件完成
   */
  @Builder
  buildVerifyCodeComponent() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.codeText[0])
        .verifyCodeUnitStyle()
      Text(this.codeText[1])
        .verifyCodeUnitStyle()
      Text(this.codeText[2])
        .verifyCodeUnitStyle()
      Text(this.codeText[3])
        .verifyCodeUnitStyle()
      Text(this.codeText[4])
        .verifyCodeUnitStyle()
      Text(this.codeText[5])
        .verifyCodeUnitStyle()
    }
    .backgroundColor(Color.Transparent)
    .height($r("app.integer.verify_code_height"))
    .margin({ left: $r("sys.float.ohos_id_card_margin_start"), right: $r("sys.float.ohos_id_card_margin_start") })
    .defaultFocus(true)
    .onClick(() => {
      this.inputController.showTextInput();
    })
  }

  build() {
    Row() {
      this.buildVerifyCodeComponent()
    }
    .onAppear(() => {
      this.setAttachAndListener()
    })
    .onDisAppear(() => {
      // 解除绑定
      this.inputController.detach((err: BusinessError) => {
        Logger.error("Failed to detach: %{public}s", err.message);
      })
    })
  }
}

/**
 * 验证码组件：禁用选中、复制、光标
 */
@Entry
@Component
export struct VerifyCodeView {
  build() {
    Column() {
      VerifyCodeComponentWithoutCursor()
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}