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
import { FriendsBook } from '@ohos/gbktranscoding';
import { HandleTabs } from '@ohos/handtabs';
// 模拟器因没有广告kit，无法正确加载首页。
import { LaunchAdvertView } from '@ohos/launchscenes';
import { ModalWindow } from '@ohos/modalwindow/Index';
import { SlideToHideAndDisplace } from '@ohos/slidetohideanddisplace/Index';
import { NavigationParameterTransferView, UserBookingInfo } from '@ohos/NavigationParameterTransferView';
import { AkiView } from '@ohos/akiusepractice';
import { VariableWatchView } from '@ohos/variablewatch';
import { DynamicsImportView } from '../view/DynamicsImportView';

@Entry
@Component
struct EntryView {
  private userBooking: UserBookingInfo = new UserBookingInfo('张山','332212199507270611','7F');
  @State strUserBooking :string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', 'barChartSolution', 1, true, '30%'),
    new ListData($r("app.media.address_exchange"), '地址交换动画', 'addressExchange', 2, true, '25%'),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', 'customTabBar', 2, true, '25%'),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', 'secondarylinkage', 1, false, '30%'),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', 'readRawFile', 2, false, '25%'),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', 'eventTransmissionSolution', 1, false, '40%'),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', 'imageViewer', 2, false, '30%'),
    new ListData($r("app.media.todo_list"), '列表编辑', 'pendingitems', 1, false, '40%'),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', 'handletabs', 2, false, '30%'),
    new ListData($r("app.media.launch_advert"), '应用广告页', 'launchAvert', 2, false, '25%'),
    new ListData($r("app.media.modal_window"), '全屏登录页面', 'modalWindow', 2, false, '40%'),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', 'slideToHideAndDisplace', 2, false, '25%'),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', 'NavigationParameterTransfer', 2, false, '30%', this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', 'akiUsePractice', 2, false, '25%' ),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', 'variableWatch', 2, false, '25%'),
    new ListData($r("app.media.icon"), '动态import', 'dynamicsimport',2,false,'30%')
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
        // MpChart图表实现模块
        BarChartPage()
      } else if (name === 'imageViewer') {
        ImageViewerView()
      } else if (name === 'pendingitems') {
        ToDoList()
      } else if (name === 'friendsBook') {
        // GBK转UTF-8模块
        FriendsBook()
      } else if (name === 'handletabs') {
        // 增删tab页签
        HandleTabs()
      } else if (name === 'launchAvert') {
        // 应用广告页模块(模拟器因没有广告kit，无法正确加载首页。)
        LaunchAdvertView()
      } else if (name === 'modalWindow') {
        // 全屏登录页面
        ModalWindow()
      } else if (name === 'slideToHideAndDisplace') {
        // 滑动页面改变顶部个人信息栏显示效果
        SlideToHideAndDisplace()
      } else if (name === 'NavigationParameterTransfer') {
        NavigationParameterTransferView()
      } else if (name === 'akiUsePractice') {
        // AKI使用实践模块
        AkiView()
      } else if (name === 'variableWatch') {
        // 多层嵌套类监听方案
        VariableWatchView()
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
      .backgroundColor($r('app.color.main_background_color'))
      .hideTitleBar(true)
      .navDestination(this.PageMap)
    }
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}