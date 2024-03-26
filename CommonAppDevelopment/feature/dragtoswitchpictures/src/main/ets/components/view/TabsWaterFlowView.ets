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
import { promptAction } from '@kit.ArkUI';

@Component
export struct TabsWaterFlowView {
  @State listData: WaterFlowModule[] = waterFlowData;
  @State tabsIndex: number = 0;
  private dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  private tabsController: TabsController = new TabsController();

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
        .textAlign(TextAlign.Start)
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
      Blank()
        .width($r('app.string.full_size'))
        .height($r('app.integer.margin_length'))
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
    .onClick((event?: ClickEvent) => {
      promptAction.showToast({
        message: $r('app.string.dragtoswitchpictures_toast_one'),
        duration: CONFIGURATION.DRAGTOSWITCHPICTURES_DURATION
      })
    })
  }

  @Builder
  dragWaterFlow() {
    WaterFlow() {
      /**
       * TODO: 高性能知识点: 使用了LazyForEach进行数据懒加载，WaterFlow布局时会根据可视区域按需创建FlowItem组件，并在FlowItem滑出可视区域外时销毁以降低内存占用。
       * LazyForEach：数据懒加载:https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2
       */
      LazyForEach(this.dataSource, (waterFlowItem: WaterFlowModule) => {
        FlowItem() {
          this.methodPoints(waterFlowItem)
        }
      }, (waterFlowItem: WaterFlowModule) => JSON.stringify(waterFlowItem))
    }
    .margin({ top: $r('app.integer.margin_length') })
    .nestedScroll({
      // WaterFlow嵌套滚动选项。设置向前向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。
      scrollForward: NestedScrollMode.PARENT_FIRST, // 可滚动组件往末尾端滚动时父组件先滚动，父组件滚动到边缘以后自身滚动。
      scrollBackward: NestedScrollMode.SELF_FIRST // 可滚动组件往起始端滚动时自身先滚动，父自身滚动到边缘以后父组件滚动。
    })
    /**
     * TODO: 高性能知识点: 使用了cachedCount设置预加载的FlowItem的数量，只在LazyForEach中生效，设置该属性后会缓存cachedCount个FlowItem，LazyForEach超出显示和缓存范围的FlowItem会被释放。
     * 使用cachedCount参数的例子:https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/ui-ts-performance-improvement-recommendation-0000001477981001-V2
     */
    .cachedCount(CONFIGURATION.WATERFLOW_CACHEDCOUNT)
    .columnsTemplate('1fr 1fr')
    .columnsGap($r('app.integer.waterflow_columnsgap'))
    .width($r('app.string.full_size'))
  }

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Row() {
      Text(name)
        .fontSize($r('app.integer.tabbar_text_fontsize'))
        .fontColor(Color.Black)
        .fontWeight(this.tabsIndex === index ? CONFIGURATION.TABBAR_TEXT_FONT_WEIGHT_SELECTED : CONFIGURATION.TABBAR_TEXT_FONT_WEIGHT)
        .height($r('app.string.full_size'))
        .border(this.tabsIndex === index ? {
          width: {
            left: CONFIGURATION.TABBAR_TEXT_BORDER_WIDTH,
            right: CONFIGURATION.TABBAR_TEXT_BORDER_WIDTH,
            top: CONFIGURATION.TABBAR_TEXT_BORDER_WIDTH,
            bottom: CONFIGURATION.TABBAR_TEXT_BORDER_WIDTH_BOTTOM
          },
          color: { bottom: Color.Black },
          style: BorderStyle.Solid
        } :
          {
            width: CONFIGURATION.TABBAR_TEXT_BORDER_WIDTH
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
        ForEach(TAB_DATA, (tabItem: TabDataModel) => {
          TabContent() {
            this.dragWaterFlow();
          }
          .tabBar(SubTabBarStyle.of(tabItem.navData)
            .indicator({ color: Color.Black })
            .padding($r('app.integer.dragtoswitchpictures_padding_zero'))
            .labelStyle({ font: { size: $r('app.integer.dragtoswitchpictures_fontsize_14') } }))
        })
      }
      .margin({ top: $r('app.integer.margin_length') })
      .barBackgroundColor(Color.White)
      .padding({
        left: $r('app.string.2_5_size'),
        right: $r('app.string.2_5_size')
      })
      .barWidth($r('app.string.full_size'))
      .barHeight($r('app.string.6_size'))
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
    .height($r('app.string.full_size'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.waterflow_column_backgroundcolor'))
  }
}

