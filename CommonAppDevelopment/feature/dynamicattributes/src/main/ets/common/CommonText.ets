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
const COLUMN_SPACE = 10; // column间隙

/**
 * 自定义封装公共文本组件
 */
@Component
export struct CommonText {
  @State textFour: AttributeModifier<TextAttribute> = new TextModifier();

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
  @State buttonModifier: AttributeModifier<ButtonAttribute> = new ButtonModifier();
  @State barModifier: AttributeModifier<RowAttribute> = new BarModifier();
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
  @State item: string | Resource = $r('app.string.text');
  @State textOneContent: string | Resource = $r('app.string.text');
  @State textTwoContent: string | Resource = $r('app.string.text');
  @State textThreeContent: string | Resource = $r('app.string.text');
  @State imageSrc: PixelMap | ResourceStr | DrawableDescriptor = $r('app.media.icon');
  // TODO：知识点：接受外部传入的AttributeModifier类实例,可以只定制部分组件，选择性传入参数。
  @State textOne: AttributeModifier<TextAttribute> = new TextModifier();
  @State textTwo: AttributeModifier<TextAttribute> = new TextModifier();
  @State textThree: AttributeModifier<TextAttribute> = new TextModifier();
  @State imageModifier: AttributeModifier<ImageAttribute> = new ImageModifier();
  @State checkboxModifier: AttributeModifier<CheckboxAttribute> = new CheckboxModifier();

  build() {
    Row() {
      Row() {
        Checkbox()
          .attributeModifier(this.checkboxModifier)

        // TODO：知识点：AttributeModifier不支持入参为CustomBuilder或Lamda表达式的属性，且不支持事件和手势。image和text只能单独通过入参传递使用
        Image(this.imageSrc)
          .attributeModifier(this.imageModifier)
      }

      .margin({ right: $r('app.float.float_10'), bottom: $r('app.float.float_15') })

      Column({ space: COLUMN_SPACE }) {
        // TODO：知识点：将入参的AttributeModifier类实例与系统组件绑定
        Text(this.item)
          .attributeModifier(this.textTwo)

        Text(this.textThreeContent)
          .attributeModifier(this.textThree)

        CommonText({ textFour: new TextModifier() })

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
  自定义class实现button的AttributeModifier接口，用于初始化
*/
export class ButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.width($r('app.float.float_30'));
    instance.height($r('app.float.float_15'));
  }
}

/*
  自定义class实现text的AttributeModifier接口，用于初始化
*/
class TextModifier implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize($r('app.float.float_12'));
    instance.fontColor($r('app.color.orange'));
    instance.textAlign(TextAlign.Center);
    instance.border({ width: $r('app.float.float_1'), color: $r('app.color.orange'), style: BorderStyle.Solid });
    instance.margin({ right: $r('app.float.float_10') });
  }
}

/*
  自定义class实现image的AttributeModifier接口，用于初始化
*/
class ImageModifier implements AttributeModifier<ImageAttribute> {
  applyNormalAttribute(instance: ImageAttribute): void {
    instance.width($r('app.float.float_100'));
    instance.height($r('app.float.float_100'));
  }
}

/*
  自定义class实现row的AttributeModifier接口，用于初始化
*/
class BarModifier implements AttributeModifier<RowAttribute> {
  applyNormalAttribute(instance: RowAttribute): void {
    instance.width($r('app.float.float_30'));
    instance.height($r('app.float.float_15'));
  }
}

/*
  自定义class实现checkbox的AttributeModifier接口，用于初始化
*/
class CheckboxModifier implements AttributeModifier<CheckboxAttribute> {
  applyNormalAttribute(instance: CheckboxAttribute): void {
    instance.width($r('app.float.float_15'));
    instance.height($r('app.float.float_15'));
  }
}

/*
  枚举底部bar类型
*/
export enum BarType {
  SHOPPING_CART, // 购物车
  DETAILS, // 详情页
}
