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
import { ButtonModifier, BarModifier, CommodityText, TextType } from './AttributeModifier';

const COLUMN_SPACE = 10; // column间隙
const TEXT_SIZE = 12 // 自定义组件中text大小

/**
 * 自定义封装公共文本组件
 */
@Component
export struct CommonText {
  @Prop textFour: AttributeModifier<TextAttribute>;

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
  @Prop buttonModifier: AttributeModifier<ButtonAttribute>;
  @Prop barModifier: AttributeModifier<RowAttribute>;
  @Prop buttonName: Resource = $r('app.string.settlement');
  @Prop barType: BarType = BarType.SHOPPING_CART;

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
  @Prop item: string;
  // 接受外部传入的AttributeModifier类实例
  @Prop textOne: AttributeModifier<TextAttribute>;
  @Prop textTwo: AttributeModifier<TextAttribute>;
  @Prop textThree: AttributeModifier<TextAttribute>;
  @Prop imageModifier: AttributeModifier<ImageAttribute>;
  @Prop checkboxModifier: AttributeModifier<CheckboxAttribute>;
  @Prop imageSrc: PixelMap | ResourceStr | DrawableDescriptor;
  @Prop textOneContent: string | Resource;
  @Prop textTwoContent: string | Resource;
  @Prop textThreeContent: string | Resource;

  build() {
    Row() {
      Row() {
        Checkbox()
          .attributeModifier(this.checkboxModifier)

        // TODO：知识点：AttributeModifier不支持入参为CustomBuilder或Lamda表达式的属性，且不支持事件和手势。image和text只能单独通过入参传递使用。
        Image(this.imageSrc)
          .attributeModifier(this.imageModifier)
      }

      .margin({ right: $r('app.float.float_10'), bottom: $r('app.float.float_15') })

      Column({ space: COLUMN_SPACE }) {
        // TODO：高性能知识点：将入参的AttributeModifier类实例与系统组件绑定
        Text(this.item)
          .attributeModifier(this.textTwo)

        Text(this.textThreeContent)
          .attributeModifier(this.textThree)

        CommonText({ textFour: new CommodityText(TextType.TYPE_FOUR, TEXT_SIZE) })

        Text(this.textOneContent)
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
