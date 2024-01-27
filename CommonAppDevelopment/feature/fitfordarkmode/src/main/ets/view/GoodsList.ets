/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { PRODUCT_DATA } from '../mock/GoodsMock'
import { ProductDataModel } from '../model/GoodsModel'

const GUTTER_X: number = 8; // 商品上下间隔
const GUTTER_Y: number = 8; // 商品左右间隔
const IMAGE_ASPECT_RATIO: number = 1; // 图片的宽高比
const OFFSET: number = -3; // 价格控件偏移量
const SPAN: number = 6; // 超过规定列数6时自动换行


@Component
export struct GoodsList {
  build() {
    GridRow({ gutter: { x: GUTTER_X, y: GUTTER_Y }, }) {
      // GridRow组件不支持LazyForEach方法
      ForEach(PRODUCT_DATA, (item: ProductDataModel) => {
        GridCol({ span: SPAN }) {
          Column() {
            // 此处的商品图片需要根据父组件的宽度而变化，这里使用70%
            Image(item.uri)
              .width('70%')
              .aspectRatio(IMAGE_ASPECT_RATIO)
              .objectFit(ImageFit.Contain)
              .margin({ bottom: $r('app.integer.goods_image_margin_bottom') })

            Column() {
              Text(item.title)
                .width('100%')
                .fontSize($r('app.integer.goods_font'))
                .fontColor($r('sys.color.ohos_id_color_foreground'))
              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                // TODO: 知识点：UI组件颜色属性是系统中的颜色（即分层参数颜色资源），深浅模式自动切换色值。
                // 用系统提供的分层参数颜色资源方式设置色值
                Text(item.price)
                  .fontSize($r('app.integer.goods_font'))
                  .offset({ x: OFFSET })// 因为￥是中文字符，上面的是中文字符，占的宽度不一样，所以需要对齐，添加offset
                  .fontColor($r('sys.color.ohos_id_color_foreground'))
                Row() {
                  // TODO: 知识点：SVG格式在resources目录下新增dark/element目录，创建深色模式color.json文件，设置深色模式图片fillColor颜色。（注意事项:颜色name必须相同）
                  // SVG格式图片fillColor颜色资源ID方式设置（浅色模式色值为'#000000'、深色模式色值为'#FFFFFF'）
                  Image($r('app.media.view'))
                    .fillColor($r('app.color.view_fill_color'))
                    .width($r('app.integer.view_image_width'))
                    .aspectRatio(IMAGE_ASPECT_RATIO)
                    .objectFit(ImageFit.Contain)

                  Text(item.views)
                    .fontSize($r('app.integer.view_font'))
                    .margin({ left: $r('app.integer.view_margin_left') })
                    .fontColor($r('sys.color.ohos_id_color_foreground'))
                }.alignItems(VerticalAlign.Center)
              }.margin({ top: $r('app.integer.flex_margin_top') })

            }
            .margin({ left: $r('app.integer.goods_column_padding_left') })
            .alignItems(HorizontalAlign.Start)
          }
          .borderRadius($r('app.integer.goods_border_radius'))
          .padding($r('app.integer.column_padding'))
          .backgroundColor($r("app.color.product_bg_color"))
        }
      }, (item: ProductDataModel) => item.id.toString())
    }
    .padding({
      left: $r('app.integer.grid_row_padding'),
      right: $r('app.integer.grid_row_padding'),
      top: $r('app.integer.grid_row_padding'),
      bottom: $r('app.integer.grid_row_padding')
    })
    .backgroundColor($r("app.color.list_bg_color"))
  }
}