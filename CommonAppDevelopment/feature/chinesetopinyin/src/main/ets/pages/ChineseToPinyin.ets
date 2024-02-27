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
 * 实现步骤
 * 1. 安装并引入pinyin4js三方库
 * 2. 使用convertToPinyinString方法将汉字转换成拼音字母
 */

// TODO: 知识点: 引入pinyin4js三方库
import { pinyin4js } from '@ohos/pinyin4js';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

const LAYOUT_WEIGHT: number = 1; // 自动分配剩余空间
const LIST_SPACE: number = 16;
const PINYIN_ARRAY: number = 0; // 拼音列表项在数组中的位置
const STROKE_WIDTH: number = 1;

// 列表结构对象
@Observed
class ListConstruction {
  public id: Resource; // 唯一id
  public title: Resource; // 列表标题
  public content: Resource | string; // 列表内容

  constructor(id: Resource, title: Resource, content: Resource | string) {
    this.id = id;
    this.title = title;
    this.content = content;
  }
}

@Component
export struct ChineseToPinyin {
  @State userName: string | Resource = $r('app.string.name_content');
  // 个人信息分组
  @State userGroup: ListConstruction[] = [
    new ListConstruction($r('app.string.pinyin_id'), $r('app.string.name_pinyin_title'), $r('app.string.name_pinyin_content')),
    new ListConstruction($r('app.string.sex_id'), $r('app.string.sex_title'), $r('app.string.sex_content'))
  ];
  // 证件信息分组
  @State idGroup: ListConstruction[] = [
    new ListConstruction($r('app.string.country_id'), $r('app.string.country_title'), $r('app.string.country_content')),
    new ListConstruction($r('app.string.type_id'), $r('app.string.id_type_title'), $r('app.string.id_type_content')),
    new ListConstruction($r('app.string.card_id'), $r('app.string.id_title'), $r('app.string.id_content')),
    new ListConstruction($r('app.string.validity_id'), $r('app.string.id_validity_title'), $r('app.string.id_validity_content'))
  ];

  build() {
    Column() {
      Row() {
        Text($r('app.string.title_content'))
          .fontSize($r('app.integer.title_font_size'))
          .fontColor($r('app.color.title_font_color'))
          .fontWeight(FontWeight.Bold)
          .width($r('app.string.title_width'))
          .height($r('app.integer.title_text_height'))
          .lineHeight($r('app.integer.title_line_height'))
          .textAlign(TextAlign.Center)
      }
      .height($r('app.integer.title_height'))
      .width($r('app.string.title_width'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      List({ space: LIST_SPACE }) {
        ListItem() {
          Row() {
            Text($r('app.string.name_title'))
              .width($r('app.string.name_title_width'))
              .fontColor($r('app.color.list_title_color'))
              .fontSize($r('app.integer.list_title_size'))
              .layoutWeight(LAYOUT_WEIGHT)
              .lineHeight($r('app.integer.list_line_height'))
            TextInput({ text: this.userName })
              .textAlign(TextAlign.End)
              .backgroundColor($r('app.color.text_input_background'))
              .fontSize($r('app.integer.list_content_size'))
              .layoutWeight(LAYOUT_WEIGHT)
              .padding({ right: $r('app.integer.text_input_margin_right') })
              .onChange((value: string) => {
                /** TODO: 知识点: 使用convertToPinyinString方法将汉字转换成拼音字母。
                 其中参数1为待转数据，参数2为拼音间隔字符，参数3设置是否带声调符号。
                 */
                const pinyin: string = pinyin4js.convertToPinyinString(value, '', pinyin4js.WITHOUT_TONE);
                this.userGroup[PINYIN_ARRAY].content = pinyin.toUpperCase();
              })
          }
          .height($r('app.integer.pinyin_height'))
          .borderRadius($r('app.integer.list_radius'))
          .backgroundColor($r('app.color.list_background'))
          .margin({
            left: $r('app.integer.pinyin_margin_left'),
            right: $r('app.integer.pinyin_margin_right')
          })
          .padding({
            left: $r('app.integer.pinyin_padding_left'),
            right: $r('app.integer.pinyin_padding_right')
          })
        }

        ListItem() {
          ForEachItem({ dataGroup: this.userGroup })
        }
        .margin({
          left: $r('app.integer.list_item_margin_left'),
          right: $r('app.integer.list_item_margin_right')
        })

        ListItem() {
          ForEachItem({ dataGroup: this.idGroup })
        }
        .margin({
          left: $r('app.integer.list_item_margin_left'),
          right: $r('app.integer.list_item_margin_right')
        })
      }
      .width($r('app.string.list_width'))
      .margin({ top: $r('app.integer.list_margin_top') })

      Button($r('app.string.button_content'))
        .width($r('app.string.button_width'))
        .margin({ top: $r('app.integer.button_margin_top') })
    }
    .backgroundColor($r('app.color.body_background'))
    .height($r('app.string.body_height'))
    .width($r('app.string.body_width'))
  }
}

// 循环遍历列表
@Component
export struct ForEachItem {
  // 需要遍历的数据数组
  private dataGroup: ListConstruction[] = [];

  build() {
    Row() {
      List({ space: LIST_SPACE }) {
        // TODO: 性能知识点：使用ForEach组件循环渲染数据
        ForEach(this.dataGroup, (item: ListConstruction) => {
          ListItem() {
            UserItemView({ text: item });
          }
        }, (item: ListConstruction) => JSON.stringify(item))
      }
      .divider({
        strokeWidth: STROKE_WIDTH,
        color: $r('app.color.divider_color'),
        startMargin: $r('app.integer.divider_start_margin'),
        endMargin: $r('app.integer.divider_end_margin')
      })
    }
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.list_background'))
    .borderRadius($r('app.integer.list_radius'))
  }
}

// 列表组件
@Component
export struct UserItemView {
  // 列表项
  @ObjectLink text: ListConstruction;

  build() {
    Row() {
      Text(this.text.title)
        .fontSize($r('app.integer.list_title_size'))
        .fontColor($r('app.color.list_title_color'))
        .layoutWeight(LAYOUT_WEIGHT)
        .lineHeight($r('app.integer.list_line_height'))
      Text(this.text.content)
        .fontSize($r('app.integer.list_content_size'))
        .fontColor($r('app.color.list_content_color'))
        .layoutWeight(LAYOUT_WEIGHT)
        .lineHeight($r('app.integer.list_line_height'))
        .textAlign(TextAlign.End)
    }
    .width($r('app.string.list_width'))
    .height($r('app.integer.setting_item_height'))
    .padding({
      left: $r('app.integer.setting_item_padding_left'),
      right: $r('app.integer.setting_item_padding_right')
    })
    .alignItems(VerticalAlign.Center)
    .width($r('app.string.list_width'))
    .alignSelf(ItemAlign.Center)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getMapCharts(): void {
  ChineseToPinyin();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
const builderName = RouterInfo.CHINESE_TO_PINYIN[0];
if (!DynamicsRouter.getBuilder(builderName)) {
  let builder: WrappedBuilder<[object]> = wrapBuilder(getMapCharts);
  DynamicsRouter.registerBuilder(builderName, builder);
}