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

// 设置项的数据类
class ProductDataModel {
  id: number = 0;
  uri: ResourceStr = '';
  title: ResourceStr = '';
  price: ResourceStr = '';
  views: ResourceStr = '';

  constructor(id: number, uri: ResourceStr, title: ResourceStr, price: ResourceStr, views: ResourceStr) {
    this.id = id;
    this.uri = uri;
    this.title = title;
    this.price = price;
    this.views = views;
  }
}

@Component
export struct GoodsList {
  private productData: Array<ProductDataModel> = [
    new ProductDataModel(0, $r('app.media.product00'), $r('app.string.product_title00'), $r('app.string.product_price00'), $r('app.string.product_view00')),
    new ProductDataModel(1, $r('app.media.product01'), $r('app.string.product_title01'), $r('app.string.product_price01'), $r('app.string.product_view01')),
    new ProductDataModel(2, $r('app.media.product02'), $r('app.string.product_title02'), $r('app.string.product_price02'), $r('app.string.product_view02')),
    new ProductDataModel(3, $r('app.media.product03'), $r('app.string.product_title03'), $r('app.string.product_price03'), $r('app.string.product_view03')),
    new ProductDataModel(4, $r('app.media.product04'), $r('app.string.product_title04'), $r('app.string.product_price04'), $r('app.string.product_view04')),
    new ProductDataModel(5, $r('app.media.product05'), $r('app.string.product_title05'), $r('app.string.product_price05'), $r('app.string.product_view05'))
  ];

  build() {
    GridRow({ gutter: { x: 8, y: 8 }, }) {
      ForEach(this.productData, (item: ProductDataModel) => {
        GridCol({ span: { sm: 6, md: 6, lg: 4 } }) {
          Column() {
            // 此处的商品图片需要根据父组件的宽度而变化，这里使用70%
            Image(item.uri)
              .width('70%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .margin({ bottom: 12 })

            Column() {
              Text(item.title)
                .width('100%')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_sub_background_dark'))
              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                // TODO: 知识点3：UI组件颜色属性是系统中的颜色（即分层参数颜色资源），深浅模式自动切换色值。
                // 用系统提供的分层参数颜色资源方式设置色值
                Text(item.price)
                  .fontSize(16)
                  .offset({ x: -3 })// 因为￥是中文字符，上面的是中文字符，占的宽度不一样，所以需要对齐，添加offset
                  .fontColor($r('sys.color.ohos_id_color_sub_background_dark'))
                Row() {
                  // TODO: 知识点4：SVG格式在resources目录下新增dark/element目录，创建深色模式color.json文件，设置深色模式图片fillColor颜色。（注意事项:颜色name必须相同）
                  // SVG格式图片fillColor颜色资源ID方式设置（浅色模式色值为'#000000'、深色模式色值为'#FFFFFF'）
                  Image($r('app.media.view'))
                    .fillColor($r('app.color.view_fill_color'))
                    .width(20)
                    .aspectRatio(1)
                    .objectFit(ImageFit.Contain)

                  Text(item.views)
                    .fontSize(16)
                    .margin({  left: 5 })
                    .offset({ x: -3 })// 因为￥是中文字符，上面的是中文字符，占的宽度不一样，所以需要对齐，添加offset
                    .fontColor($r('sys.color.ohos_id_color_sub_background_dark'))
                }.alignItems(VerticalAlign.Center)
              }.margin({ top: 6 })

            }
            .margin({ left: 10 })
            .alignItems(HorizontalAlign.Start)
          }
          .borderRadius(10)
          .padding(12)
          .backgroundColor($r("app.color.product_bg_color"))
        }
      }, (item: ProductDataModel) => item.id.toString())
    }
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor($r("app.color.list_bg_color"))
  }
}