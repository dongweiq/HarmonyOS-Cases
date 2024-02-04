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

import { DynamicsRouter, RouterModel, RouterNameConstants, RouterPathConstants } from '@ohos/dynamicsRouter';
import { UserBookingInfo } from '@ohos/NavigationParameterTransferView/Index';
import { ListData } from './model/ListData';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';
import { TabDataModel, TAB_DATA, TabDataSource } from './model/TabsData';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {

  @Link @Watch('dataChange') listData: ListData[];
  @Consume('pageStack') pageStack: NavPathStack;
  @State tabsIndex: number = 0;
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  tabsController: TabsController = new TabsController();
  tabDataSource: TabDataSource = new TabDataSource();
  waterFlowScroller: Scroller = new Scroller();

  // 监听数据变化
  dataChange() {
    this.filterData(this.tabsIndex)
  }

  /**
   * 筛选数据逻辑，触发更新列表信息，用于切换tabs和搜索
   *
   * @param index 当前的列表索引
   */
  filterData(index: number) {
    let newListData: ListData[] = [];// 用于接收筛选到的数据
    // index为0时分类为全部，全部类别情况下不需要筛选
    if (index !== 0) {
      for (let i = 0; i < this.listData.length; i++) {
        // 判断类别
        if (this.listData[i].category === TAB_DATA[this.tabsIndex].navData) {
          newListData.push(this.listData[i]);
        }
      }
      // 更新数据控制器数据
      this.dataSource.modifyAllData(newListData);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    } else {
      // 更新数据控制器数据
      this.dataSource.modifyAllData(this.listData);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    }
  @Consume('pageStack') pageStack: NavPathStack;
  private userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
  @State strUserBooking: string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', RouterNameConstants.ROUTER_NAME_BAR_CHAT, 1, true, '30%', RouterPathConstants.ROUTER_PATH_BAR_CHAT),
    new ListData($r("app.media.address_exchange"), '地址交换动画', RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE, 2, true, '25%', RouterPathConstants.ROUTER_PATH_ADDRESS_EXCHANGE),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', RouterNameConstants.ROUTER_NAME_CUSTOM_TAB_BAR, 2, true, '25%', RouterPathConstants.ROUTER_PATH_CUSTOM_TAB_BAR),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', RouterNameConstants.ROUTER_NAME_SECONDARY_LINKAGE, 1, false, '30%', RouterPathConstants.ROUTER_PATH_SECONDARY_LINKAGE),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', RouterNameConstants.ROUTER_NAME_READ_RAW_FILE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_READ_RAW_FILE),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION, 1, false, '40%', RouterPathConstants.ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', RouterNameConstants.ROUTER_NAME_IMAGE_VIEWER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_IMAGE_VIEWER),
    new ListData($r("app.media.todo_list"), '列表编辑', RouterNameConstants.ROUTER_NAME_PENDING_ITEMS, 1, false, '40%', RouterPathConstants.ROUTER_PATH_PENDING_ITEMS),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', RouterNameConstants.ROUTER_NAME_HANDLE_TABS, 2, false, '30%', RouterPathConstants.ROUTER_PATH_HANDLE_TABS),
    new ListData($r("app.media.launch_advert"), '应用广告页', RouterNameConstants.ROUTER_NAME_LAUNCH_AVERT, 2, false, '25%', RouterPathConstants.ROUTER_PATH_LAUNCH_AVERT),
    new ListData($r("app.media.modal_window"), '全屏登录页面', RouterNameConstants.ROUTER_NAME_MODAL_WINDOW, 2, false, '40%', RouterPathConstants.ROUTER_PATH_MODAL_WINDOW),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', RouterNameConstants.ROUTER_NAME_SLIDE_TO_HIDE_AND_DISPLACE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_SLIDE_TO_HIDE_AND_DISPLACE),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', RouterNameConstants.ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_NAVIGATION_PARAMETER_TRANSFER, this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', RouterNameConstants.ROUTER_NAME_AKI_USE_PRACTICE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_AKI_USE_PRACTICE),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', RouterNameConstants.ROUTER_NAME_VARIABLE_WATCH, 2, false, '25%', RouterPathConstants.ROUTER_PATH_VARIABLE_WATCH),
    new ListData($r('app.media.friends_book'), 'GBK文本格式解码', RouterNameConstants.ROUTER_NAME_GBK_TRANSCODING, 2, false, '25%', RouterPathConstants.ROUTER_PATH_GBK_TRANSCODING),
  ];
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);

  aboutToAppear(): void {
    // 注册动态router
    DynamicsRouter.createRouter(this.pageStack);
    // 主页tabContent初始化数据
    for (let index = 0; index < TAB_DATA.length; index++) {
      this.tabDataSource.pushData(TAB_DATA[index]);
    }
  }

  /**
   * 瀑布流列表项组件布局
   *
   * @param listData 组件列表信息
   */
  @Builder
  methodPoints(listData: ListData) {
    Column() {
      if (listData.isCropping) {
        Image(listData.imageSrc)
          .borderRadius($r('app.string.main_page_list_borderRadius'))
          .objectFit(ImageFit.Fill)
          .width('100%')
      } else {
        Image(listData.imageSrc)
          .borderRadius($r('app.string.main_page_list_borderRadius'))
          .objectFit(listData.isCropping ? ImageFit.Contain : ImageFit.Cover)
          .width('100%')
          .height(listData.imageHeight)
      }
      Text(listData.name)
        .padding({ left: $r('app.string.main_page_padding1') })
        .width('100%')
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .height($r('app.string.main_page_text_height'))
        .fontSize($r('app.string.ohos_id_text_size_body1'))
        .margin({ top: $r('app.string.main_page_margin1'), bottom: $r('app.string.main_page_margin1') })
      Row() {
        Text($r('app.string.difficulty'))
          .padding({ left: $r('app.string.main_page_padding1') })
          .fontColor('#B7B9B8')
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .height($r('app.string.main_page_text_height'))
          .fontSize($r('app.string.main_page_text_font_size'))
        Rating({
          rating: listData.ratingNumber,
          indicator: true
        })
          .stars(5)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .linearGradient({
      angle: 180,
      colors: [['#CCDFFF', 0], ['#F3F4F7', 1]]
    })
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
    .width('49%')
    .borderRadius($r('app.string.main_page_list_borderRadius'))
    .margin({ top: $r('app.string.item_gap_half'), bottom: $r('app.string.item_gap_half') })
    .backgroundColor(Color.White)
    .onClick(() => {
      // 点击瀑布流Item时，根据点击的模块信息，将页面放入路由栈
      let router: RouterModel = new RouterModel();
      router.path = listData.path;
      router.routerName = listData.routerName;
      router.param = listData.param;
      DynamicsRouter.push(router);
    })
  }

  @Builder
  tabBuilder(index: number, name: string | undefined) {
    Row() {
      Text(name)
        .fontSize($r('app.string.ohos_id_text_size_body1'))
        .fontColor(Color.Black)
        .opacity(this.tabsIndex === index ? 1 : 0.8)
        .fontWeight(this.tabsIndex == index ? 600 : 400)
        .height('100%')
        .border(this.tabsIndex === index ? {
          width: { left: 0, right: 0, top: 0, bottom: $r('app.string.main_page_tab_text_underline') },
          color: { bottom: Color.Black },
          style: BorderStyle.Solid
        } :
          {
            width: 0
          })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor(Color.White)
    .height('100%')

    .align(Alignment.Center)
    .onClick(() => {
      this.tabsIndex = index;
      this.tabsController.changeIndex(index);
      this.filterData(index);
    })
  }

  /**
   * 主页通过瀑布流和LazyForeach加载
   * WaterFlow+LazyForEach详细用法可参考性能范例：
   * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/
   */
  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        LazyForEach(this.tabDataSource, (tabItem: TabDataModel) => {
          TabContent() {
            WaterFlow({ scroller: this.waterFlowScroller }) {
              LazyForEach(this.dataSource, (waterFlowItem: ListData) => {
                FlowItem() {
                  this.methodPoints(waterFlowItem)
                }
              }, (waterFlowItem: ListData) => JSON.stringify(waterFlowItem))
            }
            .margin({ top: $r('app.string.main_page_padding2') })
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .cachedCount(6)
            .columnsTemplate('1fr 1fr')
            .columnsGap($r('app.string.main_page_water_flow_gap'))
            .width('100%')
          }
          .tabBar(this.tabBuilder(tabItem.id, tabItem.navData))
        })
      }
      .margin({ top: $r('app.string.main_page_padding2') })
      .padding({
        left: $r('app.string.main_page_padding2'),
        right: $r('app.string.main_page_padding2')
      })
      .barWidth('100%')
      .barHeight('6%')
      .onChange((index: number) => {
        this.filterData(index);
      })
    }
    .height('100%')
    .backgroundColor("#F1F1F1")
  }
}

@Builder
export function pageMap(name: string, param: ESObject) {
  NavDestination() {
    // 根据模块名，获取WrappedBuilder对象，通过builder接口创建页面
    DynamicsRouter.getBuilder(name).builder(param);
  }
  .hideTitleBar(true)
}
