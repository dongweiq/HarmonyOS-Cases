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

import { inputMethod } from '@kit.IMEKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { VerifyCodeConstants } from '../constants/VerifyCodeConstants';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { logger } from '@ohos/common';

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
  private verifyCodeLength: number = 6;
  private textConfig: inputMethod.TextConfig = {
    inputAttribute: {
      textInputType: inputMethod.TextInputType.NUMBER,
      enterKeyType: inputMethod.EnterKeyType.GO
    },
  };
  private codeIndexArray: Array<number> = Array.from([0, 1, 2, 3, 4, 5]);

  aboutToDisappear(): void {
    this.dettach();
  }

  /**
   * TODO 知识点：绑定输入法并订阅输入法相关事件
   */
  async attach() {
    await this.inputController.attach(true, this.textConfig);
    logger.info("attached");
  }

  /**
   * TODO 知识点：订阅输入法代插入、向左删除事件，从而获得键盘输入内容
   */
  listen() {
    this.inputController.on("insertText", (text: string) => {
      if (this.codeText.length >= this.verifyCodeLength) {
        return;
      }
      this.codeText += text;
      if (this.codeText.length === this.verifyCodeLength) {
        logger.info("VerifyCode: %{public}s", this.codeText);
      }
      logger.info("VerifyCode [insert]: %{public}s", this.codeText);
    })
    this.inputController.on("deleteLeft", (length: number) => {
      this.codeText = this.codeText.substring(0, this.codeText.length - 1);
      logger.info("VerifyCode [delete left]: %{public}s", this.codeText);
    })
    logger.info("listener added");
  }

  /**
   * TODO：知识点：解绑
   */
  dettach(): void {
    this.inputController.off("insertText");
    this.inputController.off("deleteLeft");
    this.inputController.detach((err: BusinessError) => {
      if (err) {
        logger.error(err.message);
      }
    })
    logger.info("dettached");
  }

  /**
   * TODO 知识点：部分验证码场景要完全禁止对输入验证码的选中、复制等功能，因此可以使用Text组件完成
   */
  @Builder
  buildVerifyCodeComponent() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.codeIndexArray, (item: number, index: number) => {
        Text(this.codeText[item])
          .verifyCodeUnitStyle()
      }, (item: number, index: number) => item.toString())
    }
    /**
     * TODO：知识点：当可视面积变化时进行绑定注册与解绑
     */
    .onVisibleAreaChange([0.0, 1, 0], async (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        await this.attach();
        this.listen();
      }
      if (!isVisible && currentRatio <= 0.0) {
        this.dettach();
      }
    })
    .backgroundColor(Color.Transparent)
    .height($r("app.integer.verify_code_height"))
    .margin({ left: $r("sys.float.ohos_id_card_margin_start"), right: $r("sys.float.ohos_id_card_margin_start") })
    .defaultFocus(true)
    .onClick(() => {
      // TODO 知识点：点击本组件时弹出输入法，因为这里使用的是Text组件，因此需要重新attach，而不能直接使用showSoftKeyboard
      this.attach();
      logger.info("reattached");
    })
  }

  build() {
    Row() {
      this.buildVerifyCodeComponent()
    }
  }
}

/**
 * 验证码组件：禁用选中、复制、光标
 */
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

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getVerifyCodeView(): void {
  VerifyCodeView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.VERIFY_CODE, wrapBuilder(getVerifyCodeView));