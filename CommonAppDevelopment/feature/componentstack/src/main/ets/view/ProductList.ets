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

import { PRODUCT_DATA } from '../mock/IconMock';
import { ProductDataModel } from '../model/IconModel';
import { ProductDataSource } from '../model/DataSource';

const COLUMNSPACE: number = 5; // column各子组件间距
const ASPECT_RATIO: number = 1; // 图片的宽高比
const OFFSET: number = -4; // 价格控件偏移量
const COLUMNSGAP: number = 12; // WaterFlow组件纵向间距
const ROWSGAP: number = 12; // WaterFlow组件横向间距

@Component
export struct ProductList {
  private productData: ProductDataSource = new ProductDataSource();

  aboutToAppear() {
    this.productData.pushData(PRODUCT_DATA)
  }

  build() {
    // TODO: 知识点：瀑布流容器，由“行”和“列”分割的单元格所组成，通过容器自身的排列规则，将不同大小的“项目”自上而下，如瀑布般紧密布局。
    WaterFlow() {
      LazyForEach(this.productData, (item: ProductDataModel) => {
        FlowItem() {
          Column({ space: COLUMNSPACE }) {
            Image(item.uri)
              .width('65%')
              .aspectRatio(ASPECT_RATIO)
              .objectFit(ImageFit.Contain)
              .margin({ top: $r('app.integer.water_flow_image_margin_top') })

            Text(item.title)
              .width('100%')
              .fontSize($r('app.integer.water_flow_title_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)

            Text(item.price)
              .width('100%')
              .fontSize($r('app.integer.water_flow_price_font_size'))
              .offset({ x: OFFSET })// 因为￥是中文字符，上面的是中文字符，占的宽度不一样，所以需要对齐，添加offset
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ohos_id_color_warning'))

            Text(item.insurance)
              .fontSize($r('app.integer.water_flow_insurance_font_size'))
              .fontColor($r('app.color.ohos_id_color_list_alert'))
              .borderColor($r('app.color.ohos_id_color_list_alert'))
              .borderWidth($r('app.integer.water_flow_insurance_border_width'))
              .borderRadius($r('app.integer.water_flow_insurance_border_radius'))
              .padding({
                left: $r('app.integer.water_flow_insurance_padding_horizontal'),
                right: $r('app.integer.water_flow_insurance_padding_horizontal'),
                top: $r('app.integer.water_flow_insurance_padding_vertical'),
                bottom: $r('app.integer.water_flow_insurance_padding_vertical')
              })
              .margin({ top: $r('app.integer.water_flow_insurance_margin_top') })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: $r('app.integer.water_flow_column_padding_left') })
          .width('100%')
          .height($r('app.integer.water_flow_column_height'))
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.water_flow_column_border_radius'))
        }
      }, (item: ProductDataModel) => item.id.toString())
    }
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .columnsTemplate("1fr 1fr")
    .columnsGap(COLUMNSGAP)
    .rowsGap(ROWSGAP)
    .padding({ bottom: $r('app.integer.water_flow_padding_bottom') })
  }
}