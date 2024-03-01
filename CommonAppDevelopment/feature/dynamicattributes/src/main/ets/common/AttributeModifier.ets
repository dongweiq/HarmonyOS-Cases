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

// 动态设置按钮样式
export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height(30);
    instance.width(90);
    instance.linearGradient({
      angle: 90,
      colors: [[$r('app.color.buttonColor'), 0.5], [$r('app.color.orange'), 1.0]]
    });
  }
}

// 动态设置文本样式
export class MyTextModifier implements AttributeModifier<TextAttribute> {
  textType: TextType = TextType.TYPE_ONE;
  textSize: number = 15;

  constructor(textType: TextType, textSize: number) {
    this.textType = textType;
    this.textSize = textSize;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    if (this.textType === TextType.TYPE_ONE) {
      instance.fontSize(this.textSize);
      instance.fontColor($r('app.color.orange'));
      instance.fontWeight(FontWeight.Bolder);
      instance.width($r('app.string.max_size'));
    } else if (this.textType === TextType.TYPE_TWO) {
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Bold);
      instance.fontColor($r('sys.color.ohos_id_counter_title_font_color'));
      instance.width($r('app.string.max_size'));
    } else if (this.textType === TextType.TYPE_Three) {
      instance.fontColor(Color.Gray);
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Normal);
      instance.width($r('app.string.max_size'));
    } else if (this.textType === TextType.TYPE_FOUR) {
      instance.fontSize(this.textSize);
      instance.fontColor($r('app.color.orange'));
      instance.textAlign(TextAlign.Center);
      instance.border({ width: 1, color: $r('app.color.orange'), radius: 0, style: BorderStyle.Solid });
      instance.margin({ right: $r('app.float.float_10') });
    }
  }
}

//枚举文本类型
export enum TextType {
  TYPE_ONE,
  TYPE_TWO,
  TYPE_Three,
  TYPE_FOUR
}



