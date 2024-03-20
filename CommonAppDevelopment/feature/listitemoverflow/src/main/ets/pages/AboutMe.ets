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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import promptAction from '@ohos.promptAction';

/*
 * 实现步骤：
 * 1. 设置头像框超出父组件ListItem范围。
 * 2. 在List内部使用ListItem占位，包住超出的区域。
 *
 * 实现步骤（另一种方式）：
 * 1. 设置头像框超出父组件ListItem范围。
 * 2. 在List组件外部使用Row占位。
 * 3. 设置List.clip(false)，允许滚动时List内部组件上下溢出List组件的区域。
 */

const ITEMOVERFLOW_LIST_SPACING = 20

@Extend(Image)
function imageStyle() {
  .width($r("app.integer.itemoverflow_icon_size"))
  .height($r("app.integer.itemoverflow_icon_size"))
  .margin($r("app.integer.itemoverflow_default_margin"))
}

@Extend(ListItem)
function toastOnClick(msg: ResourceStr) {
  .clickEffect({ level: ClickEffectLevel.HEAVY })
  .onClick(() => {
    promptAction.showToast({ message: msg });
  })
}

@Preview
@Component
export struct AboutMe {
  build() {
    // TODO 知识点：List占满整个窗口或者不可滚动的情况下，也可以可以在List外部使用Row占位
    // Row().height($r("app.integer.itemoverflow_avatar_outer_padding_height")) // 占位组件
    List({ initialIndex: 0, space: ITEMOVERFLOW_LIST_SPACING }) {
      // TODO 知识点：在List内部使用ListItem占位，包住超出的区域
      ListItem().height($r("app.integer.itemoverflow_avatar_padding_height")).selectable(false) // 占位组件
      ListItemGroup({ style: ListItemGroupStyle.CARD }) {
        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            // TODO 知识点：通过设置负的margin值，移动头像框位置，使其超出父组件范围
            Image($r("app.media.io_user_portrait"))
              .width($r("app.integer.itemoverflow_avatar_size"))
              .height($r("app.integer.itemoverflow_avatar_size"))
              .margin({
                top: $r("app.integer.itemoverflow_avatar_top_margin"),
                left: $r("app.integer.itemoverflow_default_margin")
              })
              .borderRadius($r("app.integer.itemoverflow_avatar_border_radius"))
              .clip(true)
            Text($r("app.string.listitem_overflow_nickname"))
              .fontSize($r("sys.float.ohos_id_text_size_sub_title1"))
              .margin($r("app.integer.itemoverflow_default_margin"))
              .fontWeight(FontWeight.Bold)
          }.width("100%")
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_no_edit"))

        ListItem({ style: ListItemStyle.CARD }) {
          Text($r("app.string.listitem_overflow_signature"))
            .width("100%")
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor(Color.Grey)
            .margin($r("app.integer.itemoverflow_default_margin"))
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_no_edit"))
      }
      .divider({ strokeWidth: 1, color: $r('app.color.aboubtme_pageBcColor') })

      ListItemGroup({ style: ListItemGroupStyle.CARD }) {
        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Image($r("app.media.io_bank_cards")).imageStyle()
            Text($r("app.string.listitem_overflow_purse"))
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .margin($r("app.integer.itemoverflow_default_margin"))
          }.width("100%")
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_no_card"))
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.aboubtme_pageBcColor'),
        startMargin: $r("app.integer.itemoverflow_divide_start_margin")
      })

      ListItemGroup({ style: ListItemGroupStyle.CARD }) {
        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Image($r("app.media.io_highlightsed")).imageStyle()
            Text($r("app.string.listitem_overflow_favorite"))
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .margin($r("app.integer.itemoverflow_default_margin"))
          }.width("100%")
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_no_favorite"))

        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Image($r("app.media.io_settings")).imageStyle()
            Text($r("app.string.listitem_overflow_settings"))
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .margin($r("app.integer.itemoverflow_default_margin"))
          }.width("100%")
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_no_settings"))

        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Image($r("app.media.io_about")).imageStyle()
            Text($r("app.string.listitem_overflow_about"))
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .margin($r("app.integer.itemoverflow_default_margin"))
          }.width("100%")
        }.height($r("app.integer.itemoverflow_default_item_height"))
        .toastOnClick($r("app.string.listitem_overflow_toast_about"))
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.aboubtme_pageBcColor'),
        startMargin: $r("app.integer.itemoverflow_divide_start_margin")
      })

      ListItem() {
        Row() {
          Text($r("app.string.listitem_overflow_logout"))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor(Color.Red)
            .margin($r("app.integer.itemoverflow_default_margin"))
            .onClick(() => {
              DynamicsRouter.pop()
            })
        }.justifyContent(FlexAlign.Center).width('100%')
      }.height($r("app.integer.itemoverflow_default_item_height"))
    }
    .layoutWeight(1)
    .listDirection(Axis.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor($r('app.color.aboubtme_pageBcColor'))
    .width('100%')
    .height('100%')

    // TODO 知识点：由于List组件clip属性默认为true，若使用在List外占位的方式，需同时设置List的clip属性为false：
    // 此时，List内组件将不再根据List进行形状裁剪，允许滚动时内部组件溢出List的布局范围
    // .clip(false)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getAboutMe(): void {
  AboutMe();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.LIST_ITEM_OVERFLOW, wrapBuilder(getAboutMe));