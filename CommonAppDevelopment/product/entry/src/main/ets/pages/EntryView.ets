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
import { ModalWindow } from '@ohos/modalwindow/Index';
import { SlideToHideAndDisplace } from '@ohos/slidetohideanddisplace/Index';
import { NavigationParameterTransferView, UserBookingInfo } from '@ohos/NavigationParameterTransferView';
import { AkiView } from '@ohos/akiusepractice';
import { VariableWatchView } from '@ohos/variablewatch';
import { PictureManager } from '@ohos/photopickandsave';
import { PageTurningAnimation } from '@ohos/pageturninganimation';
import { ApplicationExceptionView } from '@ohos/applicationexception';
import { FitForDarkMode } from '@ohos/fitfordarkmode';
import { MarqueeView } from '@ohos/marquee';
import { PullToRefreshNews } from '@ohos/pulltorefreshnews';
import { VerifyCodeView } from '@ohos/verifycode';
import { NativeProgressNotify } from '@ohos/nativeprogressnotify';
import { VibrateEffectView } from '@ohos/vibrateeffect';
import { NativeProgressNotify } from '@ohos/nativeprogressnotify';
import { SwiperSmoothVariation } from '@ohos/swipersmoothvariation';


@Entry
@Component
struct EntryView {
  private userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
  @State strUserBooking: string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', 'barChartSolution', 1, true, '30%', '三方库'),
    new ListData($r("app.media.address_exchange"), '地址交换动画', 'addressExchange', 2, true, '25%', '动效'),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', 'customTabBar', 2, true, '25%', '动效'),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', 'secondarylinkage', 1, false, '30%', 'UI布局'),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', 'readRawFile', 2, false, '25%', 'Native'),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', 'eventTransmissionSolution', 1, false, '40%', '其他'),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', 'imageViewer', 2, false, '30%', '其他'),
    new ListData($r("app.media.todo_list"), '列表编辑', 'pendingitems', 1, false, '40%', 'UI布局'),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', 'handletabs', 2, false, '30%', 'UI布局'),
    new ListData($r("app.media.modal_window"), '全屏登录页面', 'modalWindow', 2, false, '40%', 'UI布局'),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', 'slideToHideAndDisplace', 2, false, '25%', 'UI布局'),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', 'NavigationParameterTransfer', 2, false, '30%', '其他', this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', 'akiUsePractice', 2, false, '25%', '其他'),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', 'variableWatch', 2, false, '25%', '其他'),
    new ListData($r("app.media.photo_pick_and_save"), '图片选择和下载保存', 'photopickandsave', 1, false, '25%', '其他'),
    new ListData($r('app.media.application_exception'), '异常处理', 'fault', 2, false, '25%', '其他'),
    new ListData($r('app.media.fit_for_dark_mode'), '深浅模式', 'darkMode', 2, false, '35%', 'UI布局'),
    new ListData($r('app.media.marquee'), '跑马灯', 'marquee', 3, true, '25%', '动效'),
    new ListData($r('app.media.pull_to_refresh_news'), '下拉刷新上滑加载', 'pulltorefresh', 2, false, '35%', '动效'),
    new ListData($r('app.media.page_turning_animation'), '翻页动效', 'pageturninganimation', 3, true, '25%', '动效'),
    new ListData($r("app.media.verify_code"), '验证码布局案例', 'verifyCode', 3, true, '25%', 'UI布局'),
    new ListData($r('app.media.native_progress_notify'), 'Native进度通知案例', 'nativeProgressNotify', 2, false, '25%', 'Native'),
    new ListData($r('app.media.vibrate_effect'), '抖动动画及手机振动效果', 'vibrateEffect', 1, false, '25%', '动效'),
    new ListData($r("app.media.swiper_smooth_variation"), 'Swiper高度可变化效果实现', 'swiperSmoothVariation', 2, false, '25%', '动效')
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
      } else if (name === 'photopickandsave') {
        // 图片选择和下载保存
        PictureManager()
      } else if (name === 'pageturninganimation') {
        // 翻页动效案例
        PageTurningAnimation()
      } else if (name === 'fault') {
        ApplicationExceptionView()
      } else if (name === 'darkMode') {
        FitForDarkMode()
      } else if (name === 'marquee') {
        MarqueeView()
      } else if (name === 'pulltorefresh') {
        PullToRefreshNews()
      } else if (name === 'darkMode') {
        FitForDarkMode()
      } else if (name === 'verifyCode') {
        VerifyCodeView()
      } else if (name === 'nativeProgressNotify') {
        NativeProgressNotify()
      } else if (name === 'vibrateEffect') {
        // 抖动动画及手机振动效果
        VibrateEffectView()
      } else if (name === 'swiperSmoothVariation') {
        // Swiper高度可变化效果实现
        SwiperSmoothVariation()
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