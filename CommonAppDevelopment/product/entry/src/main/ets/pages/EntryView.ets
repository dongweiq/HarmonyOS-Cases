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
import { emitter } from '@kit.BasicServicesKit';
import { PanPositionModel } from '../model/PanPositionModel';
import { HelperConstants } from '../constants/HelperConstants';
import { HelperView } from '../view/HelperView';
import { RouterInfo } from '@ohos/dynamicsRouter/Index';

@Entry
@Component
struct EntryView {
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: SceneModuleInfo[] = waterFlowData;
  @Provide('fullScreenSize') fullScreenSize: string = '50%';
  // 帮助功能
  @State helperUrl: string = "";
  @State helperIconOffset: PanPositionModel = new PanPositionModel();

  aboutToAppear(): void {
    //  帮助功能：监听当前的案例
    emitter.on("topModule", (data: emitter.EventData) => {
      let moduleName: string = data["data"]!["moduleName"];
      if (moduleName) {
        this.helperUrl = HelperConstants.HELPER_URL_PROTOTYPE.replace("{placeholder}", data["data"]!["moduleName"]);
        this.helperIconOffset.reset();
      } else {
        this.helperUrl = moduleName;
      }
    })
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
    // 按需将NavDestinationMode配置为DIALOG类型，此时背景默认透明
    .mode(name === RouterInfo.MULTI_MODAL_TRANSITION.moduleName + "/" + RouterInfo.MULTI_MODAL_TRANSITION.pageName ?
    NavDestinationMode.DIALOG : NavDestinationMode.STANDARD)
    .hideTitleBar(true)
  }

  build() {
    Stack() {
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
        .onFocus(() => { // 当回到主页的时候隐藏帮助icon
          this.helperUrl = "";
        })
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
      }
      .backgroundColor($r('app.color.main_background_color'))
      .hideTitleBar(true)
      .navBarWidth(this.fullScreenSize)
      .navDestination(this.pageMap)
      .mode(NavigationMode.Auto)

      // 帮助功能：在每个案例的右下角添加“帮助”功能
      if (this.helperUrl) {
        HelperView({ helperUrl: this.helperUrl, helperIconOffset: this.helperIconOffset })
      }
    }
    .alignContent(Alignment.BottomEnd)
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}