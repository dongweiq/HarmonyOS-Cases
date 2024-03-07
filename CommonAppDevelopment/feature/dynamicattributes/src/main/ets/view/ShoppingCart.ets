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
import { MyDataSource } from '../common/LazyForEach';
import { CommodityText,BarModifier,CheckboxModifier,TextType,ImageModifier,ButtonModifier } from '../common/AttributeModifier';
import { BottomBar, ImageText } from '../common/CommonText';
import { Details } from './Details';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/*
 * 实现步骤：
 * 一、跨文件样式复用
 * 1.提供方创建AttributeModifier接口的实现类。
 * 2.使用方创建提供方的AttributeModifier实现类实例，并作为系统组件attributeModifier属性方法的参数传入
 * 二、跨文件组件复用
 * 1.提供方在公共组件库中创建公用的自定义组件，该组件支持外部传入attributeModifier属性。
 * 2.使用方分别实现Image组件和Text组件的AttributeModifier接口实现类。
 * 3.使用方创建Image组件和Text组件的AttributeModifier接口实现类实例，并作为提供方自定义组件CustomImageText的入参传入。
 * */

@Component
export struct ShoppingCart {
  private data: MyDataSource = new MyDataSource();
  // TODO：知识点：使用方创建提供方的AttributeModifier实现类实例
  @State textOne: CommodityText = new CommodityText(TextType.TYPE_ONE, 15);
  @State textTwo: CommodityText = new CommodityText(TextType.TYPE_TWO, 17);
  @State textThree: CommodityText = new CommodityText(TextType.TYPE_Three, 15);
  @State imageModifier: ImageModifier = new ImageModifier($r('app.float.float_100'), $r('app.float.float_100'));
  @State checkboxModifier: CheckboxModifier = new CheckboxModifier();

  aboutToAppear() {
    for (let i = 1; i <= 20; i++) {
      this.data.pushData(`商品 ${i}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Text($r('app.string.shopping_cart'))
          .fontSize($r('app.float.float_20'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.ohos_id_counter_title_font_color'))
          .width($r('app.string.max_size'))
          .height($r('app.float.float_50'))
          .padding({ left: $r('app.float.float_20') })
          .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
          .align(Alignment.Bottom)
          .border({
            width: { top: $r('app.float.float_1') },
            color: { top: $r('sys.color.ohos_id_color_component_normal') },
          })

        List() {
          // TODO：高性能知识点：数据懒加载
          LazyForEach(this.data, (item: string) => {
            ListItem() {
              Column() {
                // 店铺信息
                Row() {
                  Checkbox()
                    .attributeModifier(this.checkboxModifier)

                  Row()
                    .borderRadius($r('app.float.float_5'))
                    .width($r('app.float.float_20'))
                    .height($r('app.float.float_20'))
                    .backgroundColor($r('app.color.iconColor'))
                    .margin({ right: $r('app.float.float_5') })
                  Text($r('app.string.store_name'))
                    .attributeModifier(this.textOne)
                    .fontColor($r('sys.color.ohos_id_counter_title_font_color'))
                }
                .width(($r('app.string.max_size')))
                .height($r('app.float.float_20'))

                // 商品信息
                // TODO：知识点 AttributeModifier实例作为提供方自定义组件ImageText的入参传入。
                ImageText({
                  item: item,
                  textOne: this.textOne,
                  textTwo: this.textTwo,
                  textThree: this.textThree,
                  imageModifier: this.imageModifier,
                  imageSrc: $r('app.media.icon'),
                  checkboxModifier: this.checkboxModifier,
                  textOneContent: $r('app.string.commodity_price'),
                  textTwoContent: $r('app.string.commodity_name'),
                  textThreeContent: $r('app.string.commodity_model')
                })
                  .onClick(() => {
                    // 动态路由跳转
                    DynamicsRouter.push(RouterInfo.DYNAMIC_ATTRIBUTES_DETAILS);
                  })
              }
              .padding($r('app.float.float_15'))
              .margin({
                top: $r('app.float.float_5'),
                bottom: $r('app.float.float_5'),
                right: $r('app.float.float_10'),
                left: $r('app.float.float_10')
              })
              .height($r('app.float.float_160'))
              .backgroundColor($r('app.color.white'))
              .borderRadius($r('app.float.float_20'))
            }
          }, (item: string) => item)
        }
        .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
      }

      BottomBar({
        buttonModifier: new ButtonModifier(),
        barModifier: new BarModifier(),
        buttonName: $r('app.string.settlement')
      })
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getShoppingCart(): void {
  ShoppingCart();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.DYNAMIC_ATTRIBUTES, wrapBuilder(getShoppingCart))

