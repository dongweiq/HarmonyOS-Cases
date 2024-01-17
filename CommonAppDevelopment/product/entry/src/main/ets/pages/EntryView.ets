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

import { ListData } from '@ohos/base';
import { FunctionalScenes } from '@ohos/functionalscenes';

@Entry
@Component
struct EntryView {
  // TODO:路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [{ imageSrc: $r('app.media.img'), name: '场景1' },];
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: NavPathStack) {
    NavDestination() {
      // TODO:补充场景示例组件导航
      if (name === 'scene') {
      }
    }
    .hideTitleBar(true)
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
        // 首页列表组件
        FunctionalScenes({ listData: this.listData })
      }
      .hideTitleBar(true)
      .navDestination(this.PageMap)
    }
    .height('100%')
  }
}