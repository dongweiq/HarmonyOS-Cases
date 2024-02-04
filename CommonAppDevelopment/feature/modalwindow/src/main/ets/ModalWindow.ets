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
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsRouter/Index';

import { DefaultLogin } from './model/DefaultLogin';

/**
 * 模态转场是新的界面覆盖在旧的界面上，旧的界面不消失的一种转场方式。
 * 通过bindContentCover属性为Button组件绑定全屏模态页面，点击Button后显示模态页面，模态页面内容自定义，
 * 包含默认一键登录页面和其他登录方式页面。
 */

@Component
export struct ModalWindow {
  // 是否显示全屏模态页面
  @State isPresent: boolean = false;

  @Builder
  loginBuilder() {
    Column() {
      DefaultLogin({ isPresentInLoginView: this.isPresent }) // 通过@State和@Link使isPresentInLoginView和isPresent产生关联
    }
  }

  build() {
    Column() {
      // TODO：需求：增加其他登录方式，如半模态窗口
      Button($r('app.string.full_screen_modal_login_description'))
        .fontColor(Color.White)
        .borderRadius($r('app.integer.border_radius'))
         /**
         * ButtonType为Normal时，按钮圆角通过通用属性borderRadius设置。不同ButtonType下borderRadius属性是否生效，详见：
         * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-button-0000001774121226#ZH-CN_TOPIC_0000001774121226__buttontype枚举说明
         */
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.grey_2'))
        .width($r('app.string.size_full'))
         /**
         * TODO: 知识点: 通过bindContentCover属性为组件绑定全屏模态页面
         * isPresent：是否显示全屏模态页面
         * loginBuilder：配置全屏模态页面内容
         */
        .bindContentCover(this.isPresent, this.loginBuilder)
        .onClick(() => {
          this.isPresent = true; // 当isPresent为true时显示模态页面，反之不显示
        })
    }
    .size({ width: $r('app.string.size_full'), height: $r('app.string.size_full') })
    .padding($r('app.integer.padding_default'))
    .justifyContent(FlexAlign.Center)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function createDynamicsImportView(): void {
  ModalWindow();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_MODAL_WINDOW;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(createDynamicsImportView);
  DynamicsRouter.registerBuilder(builderName, builder);
}