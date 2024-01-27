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

import { GoodsListView } from './GoodsGridView';
import { FunctionDescription } from '@ohos/base';

/**
 * 实现步骤：
 * 1.创建功能描述组件，展示页面功能。
 * 2.通过GoodsListView()创建商品列表页面。
 * 3.将页面组件export，使其他模块可以加载商品列表页面。
 */

@Component
struct DynamicsImportView {
  build() {
    Column(){
      // 添加功能描述组件，用于展示该页面的功能。
      this.buildFunctionDescriptionView();
      // 商品列表页面。
      GoodsListView();
    }
  }

  // 添加功能描述
  @Builder
  buildFunctionDescriptionView() {
    GridItem() {
      // 功能描述
      Row() {
        FunctionDescription({
          title: $r('app.string.dynamics_import_tips_title'),
          content: $r('app.string.dynamics_import_tips_content')
        })
      }
    }
    .columnStart(0)
    .columnEnd(1)
  }
}

// 导出接口，供其他模块使用。
@Builder
export function createDynamicsImportView(): void {
  DynamicsImportView();
}