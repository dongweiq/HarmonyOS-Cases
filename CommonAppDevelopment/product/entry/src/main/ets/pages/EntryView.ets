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
import { DynamicsRouter, RouterNameConstants, RouterPathConstants } from '@ohos/dynamicsRouter/Index';
import { FunctionalScenes, ListData, } from '@ohos/functionalscenes';
import { UserBookingInfo } from '@ohos/NavigationParameterTransferView/Index';

@Entry
@Component
struct EntryView {
  // Navigation路由栈,控制页面跳转
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  private userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
  @State strUserBooking: string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', RouterNameConstants.ROUTER_NAME_BAR_CHAT, 1, true, '30%', RouterPathConstants.ROUTER_PATH_BAR_CHAT, '三方库'),
    new ListData($r("app.media.address_exchange"), '地址交换动画', RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE, 2, true, '25%', RouterPathConstants.ROUTER_PATH_ADDRESS_EXCHANGE, '动效'),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', RouterNameConstants.ROUTER_NAME_CUSTOM_TAB_BAR, 2, true, '25%', RouterPathConstants.ROUTER_PATH_CUSTOM_TAB_BAR, '动效'),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', RouterNameConstants.ROUTER_NAME_SECONDARY_LINKAGE, 1, false, '30%', RouterPathConstants.ROUTER_PATH_SECONDARY_LINKAGE, 'UI布局'),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', RouterNameConstants.ROUTER_NAME_READ_RAW_FILE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_READ_RAW_FILE, 'Native'),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION, 1, false, '40%', RouterPathConstants.ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION, '其他'),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', RouterNameConstants.ROUTER_NAME_IMAGE_VIEWER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_IMAGE_VIEWER, '其他'),
    new ListData($r("app.media.todo_list"), '列表编辑', RouterNameConstants.ROUTER_NAME_PENDING_ITEMS, 1, false, '40%', RouterPathConstants.ROUTER_PATH_PENDING_ITEMS, 'UI布局'),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', RouterNameConstants.ROUTER_NAME_HANDLE_TABS, 2, false, '30%', RouterPathConstants.ROUTER_PATH_HANDLE_TABS, 'UI布局'),
    new ListData($r("app.media.modal_window"), '全屏登录页面', RouterNameConstants.ROUTER_NAME_MODAL_WINDOW, 2, false, '40%', RouterPathConstants.ROUTER_PATH_MODAL_WINDOW, 'UI布局'),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', RouterNameConstants.ROUTER_NAME_SLIDE_TO_HIDE_AND_DISPLACE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_SLIDE_TO_HIDE_AND_DISPLACE, 'UI布局'),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', RouterNameConstants.ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_NAVIGATION_PARAMETER_TRANSFER, '其他', this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', RouterNameConstants.ROUTER_NAME_AKI_USE_PRACTICE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_AKI_USE_PRACTICE, '其他'),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', RouterNameConstants.ROUTER_NAME_VARIABLE_WATCH, 2, false, '25%', RouterPathConstants.ROUTER_PATH_VARIABLE_WATCH, '其他'),
    new ListData($r('app.media.friends_book'), 'GBK文本格式解码', RouterNameConstants.ROUTER_NAME_GBK_TRANSCODING, 2, false, '25%', RouterPathConstants.ROUTER_PATH_GBK_TRANSCODING, '其他'),
    new ListData($r("app.media.photo_pick_and_save"), '图片选择和下载保存', RouterNameConstants.ROUTER_NAME_PHOTO_PICK_AND_SAVE, 1, false, '25%', RouterPathConstants.ROUTER_PATH_PHOTO_PICK_AND_SAVE, '其他'),
    new ListData($r('app.media.application_exception'), '异常处理', RouterNameConstants.ROUTER_NAME_FAULT, 2, false, '25%', RouterPathConstants.ROUTER_PATH_FAULT, '其他'),
    new ListData($r('app.media.fit_for_dark_mode'), '深浅模式', RouterNameConstants.ROUTER_NAME_DARK_MODE, 2, false, '35%', RouterPathConstants.ROUTER_PATH_DARK_MODE, 'UI布局'),
    new ListData($r('app.media.marquee'), '跑马灯', RouterNameConstants.ROUTER_NAME_MARQUEE, 3, true, '25%', RouterPathConstants.ROUTER_PATH_MARQUEE, '动效'),
    new ListData($r('app.media.pull_to_refresh_news'), '下拉刷新上滑加载', RouterNameConstants.ROUTER_NAME_PULL_TO_REFRESH, 2, false, '35%', RouterPathConstants.ROUTER_PATH_PULL_TO_REFRESH, '动效'),
    new ListData($r('app.media.page_turning_animation'), '翻页动效', RouterNameConstants.ROUTER_NAME_PAGE_TURNING_ANIMATION, 3, true, '25%', RouterPathConstants.ROUTER_PATH_PAGE_TURNING_ANIMATION, '动效'),
    new ListData($r("app.media.verify_code"), '验证码布局案例', RouterNameConstants.ROUTER_NAME_VERIFY_CODE, 3, true, '25%', RouterPathConstants.ROUTER_PATH_VERIFY_CODE, 'UI布局'),
    new ListData($r('app.media.native_progress_notify'), '在Native侧实现进度通知功能', RouterNameConstants.ROUTER_NAME_NATIVE_PROGRESS_NOTIFY, 2, false, '25%', RouterPathConstants.ROUTER_PATH_NATIVE_PROGRESS_NOTIFY, 'Native'),
    new ListData($r('app.media.vibrate_effect'), '使用弹簧曲线实现抖动动画及手机振动效果案例', RouterNameConstants.ROUTER_NAME_VIBRATE_EFFECT, 1, false, '25%', RouterPathConstants.ROUTER_PATH_VIBRATE_EFFECT, '动效'),
    new ListData($r("app.media.swiper_smooth_variation"), 'Swiper高度可变化效果实现', RouterNameConstants.ROUTER_NAME_SWIPER_SMOOTH_VARIATION, 2, false, '25%', RouterPathConstants.ROUTER_PATH_SWIPER_SMOOTH_VARIATION, '动效'),
    new ListData($r("app.media.navigation_bar_change"), '状态栏显隐变化', RouterNameConstants.ROUTER_NAME_NAVIGATION_BAR_CHANGE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_NAVIGATION_BAR_CHANGE, '动效'),
    new ListData($r("app.media.media_fullscreen"), '视频全屏切换', RouterNameConstants.ROUTER_NAME_MEDIA_FULL_SCREEN, 2, false, '25%', RouterPathConstants.ROUTER_PATH_MEDIA_FULL_SCREEN, 'UI布局'),
    new ListData($r("app.media.city_search"), '选择城市', RouterNameConstants.ROUTER_NAME_CITY_SEARCH, 2, false, '25%', RouterPathConstants.ROUTER_PATH_CITY_SEARCH, 'UI布局'),
    new ListData($r("app.media.water_ripples"), '听歌识曲水波纹案例', RouterNameConstants.ROUTER_NAME_WATER_RIPPLES, 1, false, '25%', RouterPathConstants.ROUTER_PATH_WATER_RIPPLES, '动效'),
    new ListData($r("app.media.music_player"), '折叠屏适配音乐播放器', RouterNameConstants.ROUTER_NAME_FOLDABLE_SCREEN_CASES, 3, false, '25%', RouterPathConstants.ROUTER_PATH_MUSIC_PLAYER, '动效'),
    new ListData($r("app.media.image_comment"), '发布图片评论', RouterNameConstants.ROUTER_NAME_IMAGE_COMMENT, 2, false, '25%', RouterPathConstants.ROUTER_PATH_IMAGE_COMMENT, '其他'),
    new ListData($r('app.media.native_image2sandbox'), 'native保存图片到沙箱', RouterNameConstants.ROUTER_NAME_PIC2SANDBOX, 2, false, '25%', RouterPathConstants.ROUTER_PATH_PIC2SANDBOX, 'Native'),
    new ListData($r("app.media.component_stack"), '组件堆叠', RouterNameConstants.ROUTER_NAME_COMPONENT_TACK, 2, false, '25%', RouterPathConstants.ROUTER_PATH_COMPONENT_TACK, 'UI布局'),
    new ListData($r("app.media.custom_view"), '自定义视图实现Tab效果', RouterNameConstants.ROUTER_NAME_CUSTOM_VIEW, 2, false, '25%', RouterPathConstants.ROUTER_PATH_CUSTOM_VIEW, 'UI布局'),
    new ListData($r("app.media.drag_and_exchange"), 'Grid和List内拖拽交换子组件位置', RouterNameConstants.ROUTER_NAME_DRAG_EXCHANGE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_DRAG_EXCHANGE, 'UI布局'),
  ];

  aboutToAppear(): void {
    // 注册动态router
    DynamicsRouter.createRouter(this.pageStack);
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
            SearchComponent({ listData: this.listData })
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