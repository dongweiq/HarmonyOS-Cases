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
import { FunctionalScenes, pageMap } from '@ohos/functionalscenes';

@Entry
@Component
struct EntryView {
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Navigation(this.pageStack) {
        // 首页列表组件
        FunctionalScenes()
      }
      .backgroundColor($r('app.color.main_background_color'))
      .hideTitleBar(true)
      .navDestination(pageMap)
    }
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}