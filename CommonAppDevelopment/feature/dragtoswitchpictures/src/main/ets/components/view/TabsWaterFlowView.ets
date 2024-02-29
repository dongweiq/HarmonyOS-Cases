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

/**
 * 瀑布流列表
 */
import { WaterFlowModule } from '../model/DragToSwitchPicturesModule';
import { WaterFlowDataSource } from '../datasource/DragToSwitchPicturesDataSource';
import { TAB_DATA } from '../data/DragToSwitchPicturesData';
import { CONFIGURATION } from '../common/Constants';
import { TabDataModel } from '../model/DragToSwitchPicturesModule';
import { waterFlowData } from '../data/DragToSwitchPicturesData';
import { TabDataSource } from '../datasource/DragToSwitchPicturesDataSource';

@Component
export struct TabsWaterFlowView {
  @State listData: WaterFlowModule[] = waterFlowData;
  @State tabsIndex: number = 0;
  private dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  private tabsController: TabsController = new TabsController();
  private tabDataSource: TabDataSource = new TabDataSource();
  private waterFlowScroller: Scroller = new Scroller();

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
    let newListData: WaterFlowModule[] = []; // 用于接收筛选到的数据
    for (let i = CONFIGURATION.INIT_VALUE; i < this.listData.length; i++) {
      newListData.push(this.listData[i]);
    }
    // 更新数据控制器数据
    this.dataSource.modifyAllData(newListData);
    // 通知数据控制器重新加载数据
    this.dataSource.notifyDataReload();
  }

  aboutToAppear(): void {
    // tabContent初始化数据
    for (let index = CONFIGURATION.INIT_VALUE; index < TAB_DATA.length; index++) {
      this.tabDataSource.pushData(TAB_DATA[index]);
    }
    this.filterData(0)
  }

  /**
   * 瀑布流列表项组件布局
   *
   * @param listData 组件列表信息
   */
  @Builder
  methodPoints(listData: WaterFlowModule) {
    Column() {
      Image(listData.imageSrc)
        .borderRadius($r('app.integer.waterflow_image_borderradius'))
        .objectFit(ImageFit.Contain)
        .width($r('app.string.full_size'))
      Text(listData.name)
        .width($r('app.string.90_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(CONFIGURATION.WATERFLOW_TEXT_MAXLINES)
        .fontSize($r('app.integer.tabbar_text_fontsize'))
        .margin({ top: $r('app.integer.margin_length') })
      Text(listData.area)
        .width($r('app.string.90_size'))
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize($r('app.integer.10s_fontsize'))
        .margin({ top: $r('app.integer.swipercontentview_row_column_margin_length') })
    }
    .linearGradient({
      angle: CONFIGURATION.WATERFLOW_TABBAR_LINEARGRADIENT_ANGLE,
      colors: [[$r('app.color.tabbar_lineargradient_color0'), CONFIGURATION.TABBAR_LINEARGRADIENT_COLOR_ZERO],
        [$r('app.color.tabbar_lineargradient_color1'), CONFIGURATION.TABBAR_LINEARGRADIENT_COLOR_ONE]]
    })
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
    .width($r('app.string.49_size'))
    .borderRadius($r('app.integer.waterflow_image_borderradius'))
    .margin({
      top: $r('app.integer.waterflow_column_margin_length'),
      bottom: $r('app.integer.waterflow_column_margin_length')
    })
    .backgroundColor(Color.White)
  }

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Row() {
      Text(name)
        .fontSize($r('app.integer.tabbar_text_fontsize'))
        .fontColor(Color.Black)
        .opacity(this.tabsIndex === index ? CONFIGURATION.TABBAR_TEXT_OPACITY_SELECTED : CONFIGURATION.TABBAR_TEXT_OPACITY)
        .fontWeight(this.tabsIndex === index ? CONFIGURATION.TABBAR_TEXT_FONT_WEIGHT_SELECTED : CONFIGURATION.TABBAR_TEXT_FONT_WEIGHT)
        .height($r('app.string.full_size'))
        .border(this.tabsIndex === index ? {
          width: {
            left: CONFIGURATION.TABBAR_TEXT_BODER_WIDTH,
            right: CONFIGURATION.TABBAR_TEXT_BODER_WIDTH,
            top: CONFIGURATION.TABBAR_TEXT_BODER_WIDTH,
            bottom: CONFIGURATION.TABBAR_TEXT_BODER_WIDTH_BOTTOM
          },
          color: { bottom: Color.Black },
          style: BorderStyle.Solid
        } :
          {
            width: CONFIGURATION.TABBAR_TEXT_BODER_WIDTH
          })
    }
    .justifyContent(FlexAlign.Center)
    .width($r('app.string.full_size'))
    .backgroundColor(Color.White)
    .height($r('app.string.full_size'))
    .align(Alignment.Center)
    .onClick(() => {
      this.tabsIndex = index;
      this.tabsController.changeIndex(index);
      this.filterData(index);
    })
  }

  /**
   * 通过瀑布流和LazyForeach加载
   * WaterFlow+LazyForEach详细用法可参考性能范例：
   * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/
   */
  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        LazyForEach(this.tabDataSource, (tabItem: TabDataModel) => {
          TabContent() {
            WaterFlow({ scroller: this.waterFlowScroller }) {
              // TODO: 高性能知识点: 使用了LazyForEach进行数据懒加载，WaterFlow布局时会根据可视区域按需创建FlowItem组件，并在FlowItem滑出可视区域外时销毁以降低内存占用。
              LazyForEach(this.dataSource, (waterFlowItem: WaterFlowModule) => {
                FlowItem() {
                  this.methodPoints(waterFlowItem)
                }
              }, (waterFlowItem: WaterFlowModule) => JSON.stringify(waterFlowItem))
            }
            .margin({ top: $r('app.integer.margin_length') })
            .nestedScroll({ // WaterFlow嵌套滚动选项。设置向前向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。
              scrollForward: NestedScrollMode.PARENT_FIRST, // 可滚动组件往末尾端滚动时父组件先滚动，父组件滚动到边缘以后自身滚动。
              scrollBackward: NestedScrollMode.SELF_FIRST // 可滚动组件往起始端滚动时自身先滚动，父自身滚动到边缘以后父组件滚动。
            })
            // TODO: 高性能知识点: 使用了cachedCount设置预加载的FlowItem的数量，只在LazyForEach中生效，设置该属性后会缓存cachedCount个FlowItem，LazyForEach超出显示和缓存范围的FlowItem会被释放。
            .cachedCount(CONFIGURATION.WATERFLOW_CACHEDCOUNT)
            .columnsTemplate('1fr 1fr')
            .columnsGap($r('app.integer.waterflow_columnsgap'))
            .width($r('app.string.full_size'))
          }
          .tabBar(this.tabBuilder(tabItem.id, tabItem.navData))
        })
      }
      .margin({ top: $r('app.integer.margin_length') })
      .padding({
        left: $r('app.integer.padding_length'),
        right: $r('app.integer.padding_length')
      })
      .barWidth($r('app.string.full_size'))
      .barHeight($r('app.string.6_size'))
      .onChange((index: number) => {
        this.tabsIndex = index;
        this.filterData(index);
      })
    }
    .height($r('app.string.full_size'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.waterflow_column_backgroundcolor'))
  }
}

