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

import { PRODUCT_DATA } from '../model/ProductsData';
import { Goods } from '../model/GoodsModel';
import { loggerInfo } from '../utils/LoggerUtil';
import { DynamicsImportConstants } from '../constants/DynamicsImportConstants';
import promptAction from '@ohos.promptAction';

// 商品列表页面
@Component
export struct GoodsListView {
  build() {
    Grid() {
      // 通过ForEach将模拟数据添加到Grid中。
      ForEach(PRODUCT_DATA, (item: Goods) => {
        GridItem() {
          // 创建Grid中的单个商品View。
          this.buildGridItemView(item);
        }.onClick(() => {
          // 点击时打印日志，输出被点击的商品的名字。
          loggerInfo(`${item.title}`);
          // 弹出Toast，显示动态加载Logger成功。
          promptAction.showToast({
            message: DynamicsImportConstants.DYNAMICS_IMPORT_LOGGER_SUCCESS,
            duration: DynamicsImportConstants.TOAST_DURATION
          });
        })
      }, (item: Goods) => item.id.toString())
    }
    .rowsGap(DynamicsImportConstants.PRODUCT_GRID_ROWS_GAP)
    .columnsGap(DynamicsImportConstants.PRODUCT_GRID_COLUMNS_GAP)
    .columnsTemplate('1fr 1fr')
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.product_page_background'))
    .padding({
      left: $r('app.integer.product_grid_padding_left'),
      right: $r('app.integer.product_grid_padding_right'),
      top: $r('app.integer.product_grid_padding_top'),
      bottom: $r('app.integer.product_grid_padding_bottom')
    })
    .layoutWeight(DynamicsImportConstants.PRODUCT_GRID_LAYOUT_WEIGHT)
  }

  // 构建商品视图，加载商品的简要信息。
  @Builder
  buildGridItemView(item: Goods) {
    Column() {
      Image(item.uri)
        .id(DynamicsImportConstants.PRODUCT_VIEW_ID + item.id)
        .width($r('app.string.width_size_percent_70'))
        .aspectRatio(DynamicsImportConstants.PRODUCT_IMAGE_ASPECT_RATIO)
        .clip(true)
        .objectFit(ImageFit.Contain)

      Column() {
        Text(item.title)
          .width($r('app.string.width_size_percent_100'))
          .fontSize($r('app.integer.product_title_font_size'))
          .margin({ top: $r('app.integer.product_title_margin_top') })

        Text(item.info)
          .width($r('app.string.width_size_percent_100'))
          .fontSize($r('app.integer.product_info_font_size'))
          .fontColor($r("app.color.product_info_font_color"))
          .margin({ top: $r('app.integer.product_info_margin_top') })

        Text(item.price)
          .fontColor($r('app.color.product_price_font_color'))
          .fontSize($r('app.integer.product_price_font_size'))
          .margin({ top: $r('app.integer.product_price_margin_top') })
          .offset({ x: DynamicsImportConstants.PRODUCT_PRICE_OFFSET }) // 因为￥是中文字符，上面的xx是中文字符，占的宽度不一样，所以需要对齐，添加offset

        Text(item.labels)
          .fontSize($r('app.integer.product_label_font_size'))
          .fontColor($r('app.color.product_label_font_color'))
          .borderRadius($r('app.integer.product_label_border_radius'))
          .padding({
            left: $r('app.integer.product_label_padding_left'),
            right: $r('app.integer.product_label_padding_right'),
            top: $r('app.integer.product_label_padding_top'),
            bottom: $r('app.integer.product_label_padding_bottom')
          })
          .backgroundColor($r('app.color.product_label_background'))
          .margin({ top: $r('app.integer.product_label_margin_top') })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .borderRadius($r('app.integer.product_item_view_border_radius'))
    .padding($r('app.integer.product_item_view_border_radius'))
    .backgroundColor($r("app.color.product_item_view_background"))
  }
}
