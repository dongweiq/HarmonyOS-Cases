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

import { buildRouterModel } from '@ohos/dynamicsRouter';
import { SceneModuleInfo } from './model/WaterFlowDataModel';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';
import { TabDataModel, TAB_DATA, TabDataSource } from './model/TabsData';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Link @Watch('dataChange') listData: SceneModuleInfo[];
  @Consume('pageStack') pageStack: NavPathStack;
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  @State tabsIndex: number = 0;
  @State isMask: boolean = true
  scroller: Scroller = new Scroller();
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
    let newListData: SceneModuleInfo[] = []; // 用于接收筛选到的数据
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
  }

  aboutToAppear(): void {
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
  methodPoints(listData: SceneModuleInfo) {
    Column() {
      Image(listData.imageSrc)
        .borderRadius($r('app.string.main_page_list_borderRadius'))
        .objectFit(ImageFit.Contain)
        .width('100%')
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
      buildRouterModel(listData.routerInfo[1], listData.routerInfo[0], listData.param);
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
              LazyForEach(this.dataSource, (waterFlowItem: SceneModuleInfo) => {
                FlowItem() {
                  this.methodPoints(waterFlowItem)
                }
              }, (waterFlowItem: SceneModuleInfo) => JSON.stringify(waterFlowItem))
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
        this.tabsIndex = index;
        this.filterData(index);
      })
    }
    .height('100%')
    .backgroundColor("#F1F1F1")
  }
}

