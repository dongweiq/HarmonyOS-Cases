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

import { ThirdGoodsItem, SecondGoodsItemList, FistGoodsModel } from '../model/GoodsModel'

const OHOS_CARD_MARGIN = 8; // 文字和图片之间的间距

@Component
export default struct GoodViewStruct {
  @Link model: FistGoodsModel; // 与父组件VariableWatchView建立双向数据同步

  build() {
    Column() {
      SecondViews({ data: this.model.itemList})
    }
  }
}

@Component
struct SecondViews {
  // TODO: 知识点：@ObjectLink装饰器装饰的状态变量用于接收@Observed装饰的类的实例，和父组件中对应的状态变量建立双向数据绑定
  @ObjectLink data: SecondGoodsItemList;

  build() {
    Grid() {
      // 实际场景列表项确定且数量较少，使用了ForEach
      ForEach(this.data.itemList, (item: ThirdGoodsItem, index: number) => {
        GridItem() {
          ThirdView({ item: this.data.itemList[index] })
        }
        .backgroundColor($r('app.color.ohos_id_color_background'))
        .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      })
    }
    .columnsTemplate('1fr 1fr') // 2列
    .rowsTemplate('1fr 1fr') // 2行
    .rowsGap($r('app.string.ohos_id_elements_margin_vertical_m')) // 行间距
    .columnsGap($r('app.string.ohos_id_elements_margin_vertical_m')) // 列间距
    .width($r('app.string.full_size'))
    .height($r('app.string.picture_size'))
  }
}

@Component
struct ThirdView {
  // TODO: 知识点：@ObjectLink装饰器装饰的状态变量用于接收@Observed装饰的类的实例，和父组件中对应的状态变量建立双向数据绑定
  @ObjectLink item: ThirdGoodsItem;

  build() {
    Column({ space: OHOS_CARD_MARGIN }) {
      Image(this.item.imgSrc).width($r('app.integer.picture_width'))
      Text(this.item.price.toString()).fontSize($r('app.string.ohos_id_text_size_body2'))
    }
    .alignItems(HorizontalAlign.Center)
    .width($r('app.string.full_size'))
    .padding($r('app.string.ohos_id_elements_margin_vertical_m'))
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
  }
}