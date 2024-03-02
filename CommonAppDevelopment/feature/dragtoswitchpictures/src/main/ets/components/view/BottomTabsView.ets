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
 * 底部Tabs视图
 */
import { CONFIGURATION } from '../common/Constants';

@Component
export struct BottomTabsView {
  @State fontColor: string = '#182431'; // TabBar默认字体颜色
  @State selectedFontColor: string = '#007DFF'; // TabBar选中字体颜色
  @State currentIndex: number = 0; // 当前选中的index

  @Builder
  tabBuilder(index: number, name: string | Resource) { // 自定义TabBar
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize($r('app.integer.tabbar_text_fontsize'))
        .fontWeight(this.currentIndex === index ? CONFIGURATION.TABBAR_TEXT_CURRENTINDEX_FONTWEIGHT : CONFIGURATION.TABBAR_TEXT_FONTWEIGHT)
        .lineHeight($r('app.integer.tabbar_text_lineheight'))
      Divider()
        .strokeWidth(CONFIGURATION.BOTTOM_TABS_TABBUILDER_DIVIDER_STROKEWIDTH)
        .margin({ top: $r('app.integer.tabbar_divider_margin_top') })
        .color($r('app.color.tabbar_divider_color'))
        .opacity(this.currentIndex === index ? $r('app.integer.tabbar_divider_opacity1') : $r('app.integer.tabbar_divider_opacity0'))
    }.width($r('app.string.full_size'))
  }

  build() {
    Row() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
        }.tabBar(this.tabBuilder(CONFIGURATION.TABS_TABBAR_INDEX0, $r('app.string.home_page')))

        TabContent() {
        }.tabBar(this.tabBuilder(CONFIGURATION.TABS_TABBAR_INDEX1, $r('app.string.look_at')))

        TabContent() {
        }.tabBar(this.tabBuilder(CONFIGURATION.TABS_TABBAR_INDEX2, $r('app.string.my_home')))

        TabContent() {
        }.tabBar(this.tabBuilder(CONFIGURATION.TABS_TABBAR_INDEX3, $r('app.string.message')))

        TabContent() {
        }.tabBar(this.tabBuilder(CONFIGURATION.TABS_TABBAR_INDEX4, $r('app.string.personal_center')))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth($r('app.integer.bottom_tabs_barwidth'))
      .barHeight($r('app.integer.bottom_tabs_barheight'))
      .animationDuration(CONFIGURATION.BOTTOM_TABS_ANIMATIONDURATION)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .scrollable(false)
      .width($r('app.string.full_size'))
      .height($r('app.integer.bottom_tabs_height'))
      .borderRadius({
        topLeft: $r('app.integer.borderradius'),
        topRight: $r('app.integer.borderradius')
      }) // Tabs左上角和右上角的弧度
      .backgroundColor($r('app.color.bottom_tabs_backgroundcolor'))
    }
    .width($r('app.string.full_size'))
    .backgroundColor($r('app.color.bottomtabsview_row_backgroundcolor'))
  }
}