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

import { CityType, CITY_DATA, HOT_CITY, TAB_VALUE } from '../model/DetailData';
import promptAction from '@ohos.promptAction';

@Component
export struct CityView {
  private scroller: Scroller = new Scroller();
  @State stabIndex: number = 0;
  @State location: boolean = true;
  @Link isSearchState: boolean;
  @Link changeValue: string;
  curCity: string = '';
  controller: SearchController = new SearchController();

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        Text($r('app.string.hotCity'))
          .fontSize($r('app.integer.text_font'))
          .fontColor($r('app.color.text_font_color'))
          .opacity(0.6)
          .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.row_margin_bottom') })

        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
          ForEach(HOT_CITY, (item: string) => {
            // 这里规定每行占四个城市
            Text(`${item}`)
              .margin({ bottom: $r('app.integer.text_margin_bottom'), left: $r('app.integer.text_margin_left2') })
              .width('22%')
              .height($r('app.integer.text_height'))
              .textAlign(TextAlign.Center)
              .fontSize($r('app.integer.text_font'))
              .maxLines(3)
              .fontColor($r('app.color.text_font_color2'))
              .backgroundColor($r('app.color.text_bgc'))
              .borderRadius($r('app.integer.text_border_radius'))
              .onClick(() => {
                this.changeValue = item;
              })
          })
        }
        .width('100%')

        List({ space: 14, initialIndex: 0, scroller: this.scroller }) {
          ForEach(CITY_DATA, (index: CityType) => {
            ListItem() {
              Column() {
                Text(`${index.name}`)
                  .height($r('app.integer.list_item_height'))
                  .fontSize($r('app.integer.font_size'))
                  .fontColor($r('app.color.text_font_color'))
                  .width('100%')
                ForEach(index.city, (item: string) => {
                  Text(item)
                    .height($r('app.integer.list_item_height'))
                    .fontSize($r('app.integer.text_font'))
                    .width('100%')
                    .onClick(() => {
                      // 调用Toast显示提示:此样式仅为案例展示
                      promptAction.showToast({ message: $r('app.string.only_show_ui') });
                    })
                })
              }
            }
          })
        }
        .width('100%')
        .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.txt_margin_bottom') })
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
        .divider({
          strokeWidth: $r('app.integer.divider_strokeWidth'), color: $r('app.color.divider_color'),
          startMargin: $r('app.integer.divider_start'), endMargin: $r('app.integer.divider_end')
        })
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.stabIndex = firstIndex;
        })
      }
      .alignItems(HorizontalAlign.Start)

      /* TODO：知识点：可以与容器组件联动用于按逻辑结构快速定位容器显示区域的组件，arrayValue为字母索引字符串数组，selected为初始选中项索引值。
       * 1. 当用户滑动List组件，list组件onScrollIndex监听到firstIndex的改变，绑定赋值给AlphabetIndexer的selected属性，从而定位到字母索引。
       * 2. 当点击AlphabetIndexer的字母索引时，通过scrollToIndex触发list组件滑动并指定firstIndex，从而实现List列表与AlphabetIndexer组件
       * 首字母联动吸顶展示。
       */
      AlphabetIndexer({ arrayValue: TAB_VALUE, selected: this.stabIndex })
        .height('100%')
        .selectedColor($r('app.color.alphabet_select_color')) // 选中项文本颜色
        .popupColor($r('app.color.alphabet_pop_color')) // 弹出框文本颜色
        .selectedBackgroundColor($r('app.color.alphabet_selected_bgc')) // 选中项背景颜色
        .popupBackground($r('app.color.alphabet_pop_bgc')) // 弹出框背景颜色
        .popupPosition({ x: $r('app.integer.pop_position_x'), y: $r('app.integer.pop_position_y') })
        .usingPopup(true) // 是否显示弹出框
        .selectedFont({ size: $r('app.integer.select_font'), weight: FontWeight.Bolder }) // 选中项字体样式
        .popupFont({ size: $r('app.integer.pop_font'), weight: FontWeight.Bolder }) // 弹出框内容的字体样式
        .alignStyle(IndexerAlign.Right) // 弹出框在索引条左侧弹出
        .itemSize(20) // 每一项的尺寸大小
        .margin({ right: -8 })
        .onSelect((tabIndex: number) => {
          this.scroller.scrollToIndex(tabIndex);
        })
    }
    .flexShrink(1)
    .flexGrow(1)
    .padding({ bottom: $r('app.integer.padding_bottom') })
    /* 性能知识点：由于需要通过搜索按钮频繁的控制自定义组件的显隐状态，因此推荐使用显隐控制替代条件渲染，
     * 参考合理选择条件渲染和显隐控制文章：
     * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/proper-choice-between-if-and-visibility.md/
     */
    .visibility(this.isSearchState ? Visibility.None : Visibility.Visible)
    .margin({ top: $r('app.integer.margin_top') })

  }
}