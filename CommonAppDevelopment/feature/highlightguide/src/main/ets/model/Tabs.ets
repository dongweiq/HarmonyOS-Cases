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
const FONT_WEIGHT: number = 400;
const FONT_WEIGHT_SELECT: number = 500;
const SELECT_INDEX = 6;
const SPACE = 5;
const RADIUS = 2;

@Component
export struct Tab {
  @State fontColor: Resource = $r('app.color.unselect_font_color');
  @State selectedFontColor: Resource = $r('app.color.select_font_color');
  @State currentIndex: number = 0;
  @State changeValue: string = '';
  @State numbers: Resource[] = [
    $r('app.media.ic_gallery_blur_filled'),
    $r('app.media.ic_gallery_shortcut_discover'),
    $r('app.media.ic_gallery_shortcut_favorite'),
    $r('app.media.ic_gallery_shortcut_gallery'),
    $r('app.media.ic_desktop_widgets'),
    $r('app.media.ic_files_cloud_browse'),
    $r('app.media.ic_files_presentation_drive'),
    $r('app.media.ic_files_spreadsheet_drive'),
  ]; // Grid基础布局
  private TabsController: TabsController = new TabsController();
  controller: SearchController = new SearchController();
  @Consume PosX: number;
  @Consume PosY: number;

  @Builder
  tabBuilder(index: number, name: Resource, icon: Resource) {
    Column() {
      Image(icon)
        .width($r('app.integer.builder_size'))
        .height($r('app.integer.builder_size'))

      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontWeight(this.currentIndex === index ? FONT_WEIGHT_SELECT : FONT_WEIGHT)
        .fontSize($r('app.integer.access_font_size'))
        .lineHeight($r('app.integer.line_height'))
    }
    .width('100%')
  }

  build() {
    // 自定义业务样式布局
    Tabs({
      barPosition: BarPosition.End,
      index: this.currentIndex,
      controller: this.TabsController
    }) {
      TabContent() {
        Column() {
          Search({
            value: this.changeValue,
            placeholder: 'Type to search...',
            controller: this.controller
          })
            .width($r('app.integer.swiper_width'))
            .height($r('app.integer.search_height'))
            .backgroundColor($r('app.color.module_back_ground'))
            .placeholderColor(Color.Grey)
            .placeholderFont({
              size: $r('app.integer.access_font_size'),
              weight: FONT_WEIGHT
            })
            .textFont({
              size: $r('app.integer.access_font_size'),
              weight: FONT_WEIGHT
            })
            .enableKeyboardOnFocus(false)

          Row()
            .width($r('app.integer.swiper_width'))
            .height($r('app.integer.high_light_swiper_height'))
            .backgroundColor($r('app.color.module_back_ground'))
            .borderRadius($r('app.integer.border_radius'))

          Grid() {
            // TODO：知识点：使用ForEach加载简易布局，数据源不变，自动为组件生成键值
            ForEach(this.numbers, (day: Resource) => {
              GridItem() {
                Column() {
                  Image(day)
                    .width($r('app.integer.sort_order_width'))
                    .height($r('app.integer.sort_order_height'))

                  Text() {
                    Span($r('app.string.grid_module'))
                    Span(this.numbers.indexOf(day) + '')
                  }
                  .fontSize($r('app.integer.access_font_size'))
                  .margin({
                    top: $r('app.integer.common_margin_top')
                  })
                }
              }
              .id(this.numbers.indexOf(day) === SELECT_INDEX ? 'test' : '')
              .onAreaChange((oldValue: Area, newValue: Area) => {
                if (this.numbers.indexOf(day) === SELECT_INDEX) {
                  this.PosX = Number(newValue.width) / RADIUS;
                  this.PosY = Number(newValue.globalPosition.y);
                }
              })
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .columnsGap(10)
          .width($r('app.integer.grid_width'))
          .height($r('app.integer.high_light_swiper_height'))
          .margin({
            top: $r('app.integer.common_margin')
          })

          Row() {
            Row({
              space: SPACE
            }) {
              Text($r('app.string.module_text'))
                .margin({
                  left: $r('app.integer.text_left')
                })
              Text($r('app.string.test_number1'))
                .fontSize($r('app.integer.mid_font_size'))
                .fontColor(Color.Red)
            }

            Row({
              space: SPACE
            }) {
              Text($r('app.string.test_number2'))
                .fontSize($r('app.integer.mid_font_size'))
                .fontColor(Color.Red)
              Text($r('app.string.test_number3'))
                .fontSize($r('app.integer.mid_font_size'))
                .fontColor(Color.Red)
              Image($r('app.media.ic_public_arrow_right'))
                .width($r('app.integer.sort_order_width'))
                .height($r('app.integer.sort_order_height'))
                .margin({
                  right: $r('app.integer.image_right')
                })
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .padding($r('app.integer.common_margin'))

          Row()
            .width($r('app.integer.swiper_width'))
            .height($r('app.integer.high_light_swiper_height'))
            .backgroundColor($r('app.color.module_back_ground'))
            .borderRadius($r('app.integer.border_radius'))
          Row() {
            Text($r('app.string.module_text'))
              .margin({
                left: $r('app.integer.text_left')
              })
            Image($r('app.media.ic_public_arrow_right'))
              .width($r('app.integer.sort_order_width'))
              .height($r('app.integer.sort_order_height'))
              .margin({
                right: $r('app.integer.image_right')
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .padding($r('app.integer.common_margin'))
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
      }.tabBar(this.tabBuilder(0, $r('app.string.tab_bar1'), $r("app.media.ic_public_home_filled")))

      TabContent() {
        Text($r('app.string.custom_text'))
          .width('100%').height('100%')
      }
      .tabBar(this.tabBuilder(1, $r('app.string.tab_bar2'), $r('app.media.ic_contacts_company')))

      TabContent() {
        Text($r('app.string.custom_text'))
          .width('100%').height('100%')
      }
      .tabBar(this.tabBuilder(2, $r('app.string.tab_bar3'), $r('app.media.ic_gallery_puzzle')))

      TabContent() {
        Text($r('app.string.custom_text'))
          .width('100%').height('100%')
      }
      .tabBar(this.tabBuilder(3, $r('app.string.tab_bar4'), $r('app.media.ic_public_contacts')))
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .barWidth($r('app.integer.tab_bar_width'))
    .barHeight($r('app.integer.tab_bar_height'))
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width($r('app.integer.tab_bar_width'))
    .height('100%')
    .backgroundColor($r('app.color.tab_back_ground'))
  }
}