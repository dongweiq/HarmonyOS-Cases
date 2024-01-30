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
import { UserBookingInfo } from '@ohos/NavigationParameterTransferView';
import { DynamicsImportPage } from '../view/DynamicsImportPage';

@Entry
@Component
struct EntryView {
  private userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
  @State strUserBooking: string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', 'barChartSolution', 1, true, '30%', "@ohos/barchart"),
    new ListData($r("app.media.address_exchange"), '地址交换动画', 'addressExchange', 2, true, '25%', "@ohos/addressexchange"),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', 'customTabBar', 2, true, '25%', "@ohos/custom-tabbar"),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', 'secondarylinkage', 1, false, '30%', "@ohos/secondarylinkage"),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', 'readRawFile', 2, false, '25%', "@ohos/nativerawfile"),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', 'eventTransmissionSolution', 1, false, '40%', "@ohos/event-propagation"),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', 'imageViewer', 2, false, '30%', "@ohos/imageviewer"),
    new ListData($r("app.media.todo_list"), '列表编辑', 'pendingitems', 1, false, '40%', "@ohos/pendingitems"),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', 'handletabs', 2, false, '30%', "@ohos/handtabs"),
    new ListData($r("app.media.launch_advert"), '应用广告页', 'launchAvert', 2, false, '25%', "@ohos/launchscenes"),
    new ListData($r("app.media.modal_window"), '全屏登录页面', 'modalWindow', 2, false, '40%', "@ohos/modalwindow"),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', 'slideToHideAndDisplace', 2, false, '25%', "@ohos/slidetohideanddisplace"),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', 'NavigationParameterTransfer', 2, false, '30%', "@ohos/NavigationParameterTransferView", this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', 'akiUsePractice', 2, false, '25%', "@ohos/akiusepractice"),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', 'variableWatch', 2, false, '25%', "@ohos/variablewatch")
  ];
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: NavPathStack) {
    NavDestination() {
      // 传入需要动态import的模块名，用于加载对应的模块
      DynamicsImportPage({ moduleName: name })
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