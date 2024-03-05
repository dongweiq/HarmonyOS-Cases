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
import { MyButtonModifier, MyRowModifier, MyTextModifier, TextType } from '../common/AttributeModifier';
import { CommonText, BottomRow, BarType } from '../common/CommonText';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

const COLUMN_SPACE = 20; // column间隙
const TEXT_SIZE = 15 // 自定义组件中text大小

@Component
export struct Details {
  // TODO：知识点：实例化自定义的样式类
  @State buttonModifie: MyButtonModifier = new MyButtonModifier();
  @State rowModifie: MyRowModifier = new MyRowModifier();
  @State textOne: MyTextModifier = new MyTextModifier(TextType.TYPE_ONE, 30);
  @State textTwo: MyTextModifier = new MyTextModifier(TextType.TYPE_TWO, 20);
  @State textThree: MyTextModifier = new MyTextModifier(TextType.TYPE_Three, 20);
  @State textFour: MyTextModifier = new MyTextModifier(TextType.TYPE_FOUR, 15);

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 商品图片区（用色块代替）
        Row()
          .width($r('app.string.max_size'))
          .height($r('app.string.image_proportion'))
          .backgroundColor($r('app.color.imageColor'))

        // 商品详情区
        Row() {
          Column({ space: COLUMN_SPACE }) {
            Row() {
              Text($r('app.string.commodity_price'))
                .attributeModifier(this.textOne)
                .width($r('app.float.float_100'))
              Text($r('app.string.sold'))
                .attributeModifier(this.textThree)
                .fontSize($r('app.float.float_15'))
                .width($r('app.float.float_60'))
            }
            .width($r('app.string.max_size'))
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text($r('app.string.full_reduction'))
                .attributeModifier(this.textFour)
                .fontColor($r('app.color.red'))

              Button($r('app.string.coupon_collection'))
                .height($r('app.float.float_15'))
                .backgroundColor($r('app.color.red'))
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width($r('app.string.max_size'))

            Text($r('app.string.commodity_name'))
              .attributeModifier(this.textTwo)

            Text($r('app.string.commodity_model'))
              .attributeModifier(this.textThree)

            CommonText({ textFour: new MyTextModifier(TextType.TYPE_FOUR, TEXT_SIZE) })
          }
          .backgroundColor($r('app.color.white'))
          .padding($r('app.float.float_10'))
          .borderRadius($r('app.float.float_10'))
          .height($r('app.string.max_size'))
        }
        .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
        .padding($r('app.float.float_10'))
        .height($r('app.string.text_proportion'))
        .width($r('app.string.max_size'))
      }
      .width($r('app.string.max_size'))
      .height($r('app.string.max_size'))

      // 底部购买区
      BottomRow({ buttonName: $r('app.string.buy_now'), barType: BarType.DETAILS })
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getDetails(): void {
  Details();
}

DynamicsRouter.registerRouterPage(RouterInfo.DYNAMIC_ATTRIBUTES_DETAILS, wrapBuilder(getDetails))
