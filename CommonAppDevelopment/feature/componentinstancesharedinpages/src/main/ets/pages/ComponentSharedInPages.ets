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

import { MapComponent } from '../components/MapComponent';
import { MainPageComponent } from './MainPage';
import { TakeTaxiDetailPage } from './TakeTaxiDetailPage';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

// 壳页面，Stack组件下层放地图组件，上层是navigation用来管理页面，页面中需要显示地图的区域设置透明
// navigation是空的，在onAppear回调时直接跳转到主页面
@Component
export struct ComponentSharedInPages {
  // 共享同一个地图组件实例的页面根据自己的布局修改地图区域高度，地图组件根据该状态变量响应该修改
  @Provide mapResponseRegionHeight: number = 0;
  @Provide pageStackForComponentSharedPages: NavPathStack = new NavPathStack();

  @Builder pageMap(name: string) {
    if (name === 'MainPage') {
      MainPageComponent();
    } else if (name === 'TakeTaxiDetailPage') {
      TakeTaxiDetailPage();
    }
  }

  build() {
    Stack({alignContent: Alignment.Bottom}) {
      // 地图组件放在底层，navigation组件放在上层，navigation中的页面需要显示地图组件的位置处设置透明和事件透传
      MapComponent()
      // 应用主页用NavDestination承载，Navigation为空页面直接跳转到MainPage主页面
      Navigation(this.pageStackForComponentSharedPages) {
      }
      .onAppear(()=>{
        this.pageStackForComponentSharedPages.pushPathByName("MainPage", null, false);
      })
      .hideTitleBar(true)
      // TODO：知识点：navigation组件设置事件透传给兄弟组件
      .hitTestBehavior(HitTestMode.Transparent)
      .navDestination(this.pageMap)
    }
    .width('100%')
    .height('100%')
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getComponentSharedInPages(): void {
  ComponentSharedInPages();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.COMPONENT_SHARED_IN_PAGES,wrapBuilder(getComponentSharedInPages));