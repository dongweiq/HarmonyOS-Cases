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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

// TODO: 后续修改为单独页面进行搜索，增加列表list，点击listItem可以跳转到相应页面
@Component
export struct SearchComponent {

  build() {
    // 顶部搜索框
    Column() {
      Column() {
        Search({ placeholder: $r('app.string.search_placeholder') })
          .focusOnTouch(false)
          .focusable(false)
          .enableKeyboardOnFocus(false)
          .backgroundColor('#E7E9E8')
          .width('100%')
          .onClick(() => {
            DynamicsRouter.push(new RouterInfo('@ohos/searchcomponent','SearchPage'),"")
          })
      }
      .backgroundColor('#E7E9E8')
      .borderRadius($r('app.string.main_page_top_borderRadius'))
    }
    .padding({ left: $r('app.string.main_page_padding'), right: $r('app.string.main_page_padding') })
  }
}
