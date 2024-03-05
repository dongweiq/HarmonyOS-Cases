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

import { MyTextModifier, MyRowModifier, MyButtonModifier } from '../common/AttributeModifier';

// 自定义公共组件
@Component
export struct CommonText {
  @State textFour: MyTextModifier | null = null;

  build() {
    Row() {
      Text($r('app.string.text_one'))
        .attributeModifier(this.textFour)

      Text($r('app.string.text_two'))
        .attributeModifier(this.textFour)

      Text($r('app.string.text_three'))
        .attributeModifier(this.textFour)
    }
    .width($r('app.string.max_size'))
  }
}

@Component
export struct BottomRow {
  @State buttonModifie: MyButtonModifier = new MyButtonModifier();
  @State rowModifie: MyRowModifier = new MyRowModifier();
  @State buttonName: Resource = $r('app.string.settlement')
  @State barType: BarType = BarType.SHOPPING_CART

  build() {
    Row() {
      if (this.barType === BarType.DETAILS) {
        Button($r('app.string.add_cart'))
          .attributeModifier(this.buttonModifie)
          .margin({ right: $r('app.float.float_10') })
      }
      Button(this.buttonName)
        .attributeModifier(this.buttonModifie)
    }
    .attributeModifier(this.rowModifie)
  }
}

/*
  枚举底部bar类型
*/
export enum BarType {
  SHOPPING_CART, // 购物车
  DETAILS, // 详情页
}
