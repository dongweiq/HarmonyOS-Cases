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
import { SwiperComponent } from '@ohos/swipercomponent';
import { SearchComponent } from '@ohos/searchcomponent';
import { DynamicsRouter } from '@ohos/dynamicsRouter/Index';
import { FunctionalScenes, SceneModuleInfo } from '@ohos/functionalscenes';
import { waterFlowData } from '../data/WaterFlowData';

@Entry
@Component
struct EntryView {
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: SceneModuleInfo[] = waterFlowData;

  aboutToAppear(): void {
    // 注册动态router
    DynamicsRouter.createNavPathStack(this.pageStack);
    // 存储初始数据用于搜索筛选
    AppStorage.setOrCreate('listData', this.listData)
  }

  @Builder
  pageMap(name: string, param: ESObject) {
    NavDestination() {
      // 根据模块名，获取WrappedBuilder对象，通过builder接口创建页面
      DynamicsRouter.getBuilder(name).builder(param);
    }
    .hideTitleBar(true)
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
        Scroll() {
          Column() {
            // 首页搜索组件
            SearchComponent()
            // 首页轮播图组件
            SwiperComponent()
            // 首页列表组件
            FunctionalScenes({ listData: this.listData })
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
      }
      .backgroundColor($r('app.color.main_background_color'))
      .hideTitleBar(true)
      .navDestination(this.pageMap)
      .mode(NavigationMode.Stack)
    }
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}