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

import libaki from 'libaki_use_practice.so'; // 导入自定义AKI插件
import { FunctionDescription } from '@ohos/base';
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsRouter';

/**
 * 本示例介绍使用AKI编写的C++函数实现跨线程调用JS函数场景。在ArkTS侧使用AKI的JSBind.bindFunction绑定
 * JS函数akiAccumulate，然后使用AKI调用C++函数AkiThreadsCallJs。在C++侧AkiThreadsCallJs中创建子
 * 线程去调用JS侧函数akiAccumulate，从而实现对变量value的加10操作，为开发者使用AKI提供参考。
 */

@Component
export struct AkiView {
  @State value: number = 0;
  // 描述标题
  @State title: Resource = $r('app.string.common_title');
  // 描述详情
  @State content: Resource = $r('app.string.common_content');

  build() {
    Row() {
      Column() {
        // 场景描述
        FunctionDescription({ title: this.title, content: this.content })

        Text(this.value.toString())
          .fontSize($r('app.integer.common_fontSize'))
          .fontWeight(FontWeight.Bold)
          .margin($r('app.integer.common_margin'))

        Button($r('app.string.page_button'))
          .width($r('app.string.common_button_width'))
          .height($r('app.integer.common_button_height'))
          .fontSize($r('app.integer.common_button_fontSize'))
          .onClick(() => {
            // TODO：知识点：使用AKI的JSBind.bindFunction绑定JavaScript全局函数。这里第一个参数"akiAccumulate"用于指定绑定的JavaScript函数名，用于Native索引。第二个参数是被绑定的JavaScript函数体。
            libaki.JSBind.bindFunction("akiAccumulate", (values: number) => {
              // 对变量value做加10操作，刷新Text组件的value值。
              values += 10;
              this.value = values;
            });
            // TODO：知识点：使用AKI调用C++全局函数AkiThreadsCallJs，并传入参数value。
            libaki.AkiThreadsCallJs(this.value);
          })
      }
      .width($r('app.string.common_size'))
    }
    .height($r('app.string.common_size'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function createDynamicsImportView(): void {
  AkiView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_AKI_USE_PRACTICE;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(createDynamicsImportView);
  DynamicsRouter.registerBuilder(builderName, builder);
}