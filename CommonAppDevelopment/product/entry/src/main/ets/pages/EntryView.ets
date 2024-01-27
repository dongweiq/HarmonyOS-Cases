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
import { FunctionalScenes, ListData } from '@ohos/functionalscenes';
import { EventPropagation } from '@ohos/event-propagation';
import { NativeRawfileDemo } from '@ohos/nativerawfile';
import { TabView } from '@ohos/custom-tabbar';
import { SecondaryLinkExample } from '@ohos/secondarylinkage';
import { BarChartPage } from '@ohos/barchart';
import { AddressExchangeView } from '@ohos/addressexchange';
import { ToDoList } from '@ohos/pendingitems';
import { ImageViewerView } from '@ohos/imageviewer';
import { DynamicsImportView } from '../view/DynamicsImportView';

@Entry
@Component
struct EntryView {
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart"), 'MpChat柱状图', 'barChartSolution'),
    new ListData($r("app.media.address_exchange"), '地址交换动画', 'addressExchange', 95),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', 'customTabBar'),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', 'secondarylinkage'),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', 'readRawFile'),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', 'eventTransmissionSolution'),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', 'imageViewer'),
    new ListData($r("app.media.todo_list"), '列表编辑', 'pendingitems'),
    new ListData($r("app.media.icon"), '动态import', 'dynamicsimport')
  ];
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: NavPathStack) {
    NavDestination() {
      // TODO:需求：补充场景示例组件导航
      if (name === 'eventTransmissionSolution') {
        // 阻塞事件冒泡模块
        EventPropagation()
      } else if (name === 'readRawFile') {
        // 读取RawFile文件内容
        NativeRawfileDemo()
      } else if (name === 'customTabBar') {
        // TabBar页签模块
        TabView()
      } else if (name === 'secondarylinkage') {
        // 二级联动模块
        SecondaryLinkExample()
      } else if (name === 'addressExchange') {
        // 地址切换动画模块
        AddressExchangeView()
      } else if (name === 'barChartSolution') {
        // 柱状图模块
        BarChartPage()
      } else if (name === 'imageViewer') {
        ImageViewerView()
      } else if (name === 'pendingitems') {
        ToDoList()
      } else if (name === 'dynamicsimport') {
        // 动态import页面
        DynamicsImportView();
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
    .backgroundColor($r('app.color.main_background_color'))
  }
}