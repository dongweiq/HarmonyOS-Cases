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

import { CommodityText, BarModifier, ButtonModifier, CheckboxModifier,ImageModifier, TextType } from '../common/AttributeModifier';

const COLUMN_SPACE = 10; // column间隙
const TEXT_SIZE = 12 // 自定义组件中text大小

/**
 * 自定义封装公共文本组件
 */
@Component
export struct CommonText {
  @State textFour: CommodityText | null = null;

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

/**
 * 自定义封装底部bar组件
 */
@Component
export struct BottomBar {
  @State buttonModifier: ButtonModifier = new ButtonModifier();
  @State barModifier: BarModifier = new BarModifier();
  @State buttonName: Resource = $r('app.string.settlement');
  @State barType: BarType = BarType.SHOPPING_CART;

  build() {
    Row() {
      if (this.barType === BarType.DETAILS) {
        Button($r('app.string.add_cart'))
          .attributeModifier(this.buttonModifier)
          .margin({ right: $r('app.float.float_10') })
      }
      Button(this.buttonName)
        .attributeModifier(this.buttonModifier)
    }
    .attributeModifier(this.barModifier)
  }
}

/**
 * 自定义封装图文组件
 */
@Component
export struct ImageText {
  @Prop item: string
  @State textOne: CommodityText = new CommodityText('', TextType.TYPE_ONE, 0);
  @State textTwo: CommodityText = new CommodityText('', TextType.TYPE_TWO, 0);
  @State textThree: CommodityText = new CommodityText('', TextType.TYPE_Three, 0);
  @State imageModifier: ImageModifier = new ImageModifier(0,0,$r('app.media.icon'));
  @State checkboxModifier: CheckboxModifier = new CheckboxModifier();

  build() {
    Row() {
      Row() {
        Checkbox()
          .attributeModifier(this.checkboxModifier)

       Image(this.imageModifier.src)
         .attributeModifier(this.imageModifier)

      }
      .margin({ right: $r('app.float.float_10'), bottom: $r('app.float.float_15') })

      Column({ space: COLUMN_SPACE }) {
        // TODO：高性能知识点：动态设置组件的属性
        Text(this.item)
          .attributeModifier(this.textTwo)

        Text(this.textThree.textContent)
          .attributeModifier(this.textThree)

        CommonText({ textFour: new CommodityText('', TextType.TYPE_FOUR, TEXT_SIZE) })

        Text(this.textOne.textContent)
          .attributeModifier(this.textOne)
          .fontColor($r('app.color.orange'))
      }
    }
    .padding({ top: $r('app.float.float_5') })
    .width($r('app.string.max_size'))
    .height($r('app.string.max_size'))
  }
}

/*
  枚举底部bar类型
*/
export enum BarType {
  SHOPPING_CART, // 购物车
  DETAILS, // 详情页
}
