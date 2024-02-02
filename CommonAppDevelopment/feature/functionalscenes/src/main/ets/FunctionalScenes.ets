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

import { ListData } from './model/ListData';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';
import { TabDataModel, TAB_DATA, TabDataSource } from './model/TabsData';
import { SwiperData, SwiperDataSource } from './model/SwiperData';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Link listData: ListData[];
  @Consume('pageStack') pageStack: NavPathStack;
  @State tabsIndex: number = 0;
  @State isMask: boolean = true
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  scroller: Scroller = new Scroller();
  tabsController: TabsController = new TabsController();
  swiperDataSource: SwiperDataSource = new SwiperDataSource();
  tabDataSource: TabDataSource = new TabDataSource()
  waterFlowScroller: Scroller = new Scroller();
  @State swiperData: SwiperData[] = [
    new SwiperData($r('app.media.bar_chart_top'), 'MpChart图表实现案例', 'barChartSolution'),
    new SwiperData($r('app.media.address_exchange'), '地址交换动画', 'addressExchange'),
    new SwiperData($r('app.media.tab_bar'), '自定义TabBar', 'customTabBar'),
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
  SwiperComponent() {
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
          this.pageStack.pushPath({ name: item.path, param: item.param });
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
  MethodPoints(listData: ListData) {
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
    .backgroundColor(Color.White)
    .onClick(() => {
      this.pageStack.pushPath({ name: listData.path, param: listData.param });
    })
  }

  @Builder
  TabBuilder(index: number, name: string | undefined) {
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
          style: BorderStyle.Solid } :
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
      if (index !== 0) {
        let newListData: ListData[] = []
        for (let i = 0; i < this.listData.length; i++) {
          if (this.listData[i].category === TAB_DATA[index].navData) {
            newListData.push(this.listData[i])
          }
        }
        this.dataSource = new WaterFlowDataSource(newListData)
      }
    })
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
      //TODO:暂时隐藏待搜索功能完善后放开显示
      .visibility(Visibility.None)
      .padding({ left: $r('app.string.main_page_padding2'), right: $r('app.string.main_page_padding2') })

      Scroll(this.scroller) {
        Column() {
          Column() {
            this.SwiperComponent()
          }

          Column() {
            Tabs({ controller: this.tabsController }) {
              LazyForEach(this.tabDataSource, (tabItem: TabDataModel) => {
                TabContent() {
                  WaterFlow({ scroller: this.waterFlowScroller }) {
                    LazyForEach(this.dataSource, (waterFlowItem: ListData) => {
                      FlowItem() {
                        this.MethodPoints(waterFlowItem)
                      }
                    })
                  }
                  .nestedScroll({
                    scrollForward: NestedScrollMode.PARENT_FIRST,
                    scrollBackward: NestedScrollMode.SELF_FIRST
                  })
                  .cachedCount(4)
                  .padding({
                    top: $r('app.string.main_page_padding2')
                  })
                  .rowsGap($r('app.string.main_page_water_flow_gap'))
                  .columnsTemplate('1fr 1fr')
                  .columnsGap($r('app.string.main_page_water_flow_gap'))
                  .width('100%')
                }
                .tabBar(this.TabBuilder(tabItem.id, tabItem.navData))
              })
            }
            .padding({
              left: $r('app.string.main_page_padding2'),
              right: $r('app.string.main_page_padding2')
            })
            .margin({ top: $r('app.string.main_page_margin2') })
            .barWidth('100%')
            .barHeight('6%')
            .scrollable(false)
          }
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
