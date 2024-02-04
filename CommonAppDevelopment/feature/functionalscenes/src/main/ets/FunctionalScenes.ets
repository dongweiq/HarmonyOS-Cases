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
import { ListData } from './model/ListData';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';
import { TabDataModel, TAB_DATA, TabDataSource } from './model/TabsData';
import { SwiperData, SwiperDataSource } from './model/SwiperData';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Consume('pageStack') pageStack: NavPathStack;
  @Link listData: ListData[];
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  @State tabsIndex: number = 0;
  @State isMask: boolean = true
  scroller: Scroller = new Scroller();
  tabsController: TabsController = new TabsController();
  swiperDataSource: SwiperDataSource = new SwiperDataSource();
  tabDataSource: TabDataSource = new TabDataSource()
  waterFlowScroller: Scroller = new Scroller();
  @State swiperData: SwiperData[] = [
    new SwiperData($r('app.media.bar_chart_top'), 'MpChart图表实现案例', RouterNameConstants.ROUTER_NAME_BAR_CHAT, RouterPathConstants.ROUTER_PATH_BAR_CHAT),
    new SwiperData($r('app.media.address_exchange'), '地址交换动画', RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE, RouterPathConstants.ROUTER_PATH_ADDRESS_EXCHANGE),
    new SwiperData($r('app.media.tab_bar'), '自定义TabBar', RouterNameConstants.ROUTER_NAME_CUSTOM_TAB_BAR, RouterPathConstants.ROUTER_PATH_CUSTOM_TAB_BAR),
  ];

  aboutToAppear(): void {
    // 主页轮播图初始化数据
    for (let index = 0; index < this.swiperData.length; index++) {
      this.swiperDataSource.pushData(this.swiperData[index]);
    }
    // 主页tabContent初始化数据
    for (let index = 0; index < TAB_DATA.length; index++) {
      this.tabDataSource.pushData(TAB_DATA[index]);
    }
  }

  /**
   * 主页轮播图组件
   */
  @Builder
  swiperComponent() {
    Swiper() {
      LazyForEach(this.swiperDataSource, (item: SwiperData) => {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(item.imageSrc)
            .objectFit(ImageFit.Auto)
            .width('100%')
            .height('100%')
            .borderRadius($r('app.string.main_page_top_borderRadius'))
          // 轮播图底部蒙层
          Stack() {
            Column() {
            }
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Black)
            .opacity(0.3)
            .borderRadius({
              topLeft: 0,
              topRight: 0,
              bottomLeft: $r('app.string.main_page_top_borderRadius'),
              bottomRight: $r('app.string.main_page_top_borderRadius')
            })

            Text(item.name)
              .width('100%')
              .height('100%')
              .fontSize($r('app.string.ohos_id_text_size_body1'))
              .fontColor(Color.White)
              .textAlign(TextAlign.Start)
              .padding($r('app.string.main_page_padding5'))
          }
          .height('17%')
        }
        .onClick(() => {
          // 点击轮播图Item时，根据点击的模块信息，将页面放入路由栈
          buildRouterModel(item.path, item.routerName, item.param);
        })
      })

    }
    .padding({
      left: $r('app.string.main_page_padding2'),
      right: $r('app.string.main_page_padding2'),
      top: $r('app.string.main_page_padding2')
    })
    .height($r('app.string.main_page_swiper_height'))
    .autoPlay(true)
    .indicator(
      Indicator
        .dot()
        .selectedColor('#ed394b')
        .color(Color.White)
    )
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
      buildRouterModel(listData.path, listData.routerName, listData.param);
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
      this.changeTabIndex(index);
    })
  }

  /**
   * 切换tabs的逻辑，触发更新列表信息
   *
   * @param index 当前的列表索引
   */
  changeTabIndex(index: number) {
    this.tabsIndex = index;
    this.tabsController.changeIndex(index);
    if (index !== 0) {
      let newListData: ListData[] = [];
      for (let i = 0; i < this.listData.length; i++) {
        if (this.listData[i].category === TAB_DATA[index].navData) {
          newListData.push(this.listData[i]);
        }
      }
      this.dataSource = new WaterFlowDataSource(newListData);
    }
  }

  /**
   * 主页通过瀑布流和LazyForeach加载
   * WaterFlow+LazyForEach详细用法可参考性能范例：
   * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/
   */
  build() {
    Column() {
      // 顶部搜索框
      Column() {
        Column() {
          TextInput({ placeholder: '搜索' })
            .backgroundColor('#E7E9E8')
            .width('100%')
        }
        .backgroundColor('#E7E9E8')
        .borderRadius($r('app.string.main_page_top_borderRadius'))
      }
      // TODO:需求：暂时隐藏待搜索功能完善后放开显示
      .visibility(Visibility.None)
      .padding({ left: $r('app.string.main_page_padding2'), right: $r('app.string.main_page_padding2') })

      Scroll(this.scroller) {
        Column() {
          this.swiperComponent()

          Tabs({ controller: this.tabsController }) {
            LazyForEach(this.tabDataSource, (tabItem: TabDataModel) => {
              TabContent() {
                WaterFlow({ scroller: this.waterFlowScroller }) {
                  LazyForEach(this.dataSource, (waterFlowItem: ListData) => {
                    FlowItem() {
                      this.methodPoints(waterFlowItem)
                    }
                  })
                }
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
          .padding({
            left: $r('app.string.main_page_padding2'),
            right: $r('app.string.main_page_padding2')
          })
          .barWidth('100%')
          .barHeight('6%')
          .onChange((index: number) => {
            this.changeTabIndex(index);
          })
        }
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .height('100%')
    }
    .height('100%')
    .backgroundColor("#F1F1F1")
  }
}

// 创建路由信息，并放到路由栈中
function buildRouterModel(path: string, routerName: string, param: string) {
  let router: RouterModel = new RouterModel();
  router.path = path;
  router.routerName = routerName;
  router.param = param;
  DynamicsRouter.push(router);
}
