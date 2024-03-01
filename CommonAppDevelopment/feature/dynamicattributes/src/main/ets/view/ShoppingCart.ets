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
import { MyButtonModifier, MyTextModifier, TextType } from '../common/AttributeModifier';
import { Details } from './Details';
import { CommonText } from '../common/CommonText';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

const COLUMN_SPACE = 10; // column间隙
const TEXT_SIZE = 12; // 自定义组件中text大小

@Entry
@Component
export struct ShoppingCart {
  private data: MyDataSource = new MyDataSource();
  // 创建组件样式实例
  @State buttonModifie: MyButtonModifier = new MyButtonModifier();
  @State textOne: MyTextModifier = new MyTextModifier(TextType.TYPE_ONE, 15);
  @State textTwo: MyTextModifier = new MyTextModifier(TextType.TYPE_TWO, 17);
  @State textThree: MyTextModifier = new MyTextModifier(TextType.TYPE_Three, 15);

  @Builder
  toolBar() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Checkbox()
          .selectedColor($r('app.color.selectColor'))
          .height($r('app.float.float_20'))
          .width($r('app.float.float_15'))

        Row() {
          Button($r('app.string.settlement'))// 引用组件样式
            .attributeModifier(this.buttonModifie)
        }
      }.padding($r('app.float.float_25'))
    }
  }

  aboutToAppear() {
    for (let i = 1; i <= 20; i++) {
      this.data.pushData(`商品 ${i}`);
    }
  }

  build() {
    Navigation() {
      Column() {
        List() {
          LazyForEach(this.data, (item: string) => {
            ListItem() {
              Column() {
                // 店铺信息
                Row() {
                  Checkbox()
                    .selectedColor($r('app.color.selectColor'))
                    .height($r('app.float.float_15'))
                    .width($r('app.float.float_15'))
                    .margin({ right: $r('sys.float.ohos_id_card_margin_start') })
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
                Row() {
                  Row() {
                    Checkbox()
                      .selectedColor($r('app.color.selectColor'))
                      .width($r('app.float.float_15'))
                      .margin({ right: $r('app.float.float_10') })
                    Row()
                      .width($r('app.float.float_100'))
                      .height($r('app.float.float_100'))
                      .borderRadius($r('app.float.float_10'))
                      .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
                  }
                  .margin({ right: $r('app.float.float_10'), bottom: $r('app.float.float_15') })

                  Flex({
                    direction: FlexDirection.Column,
                    justifyContent: FlexAlign.Start,
                    alignItems: ItemAlign.Start
                  }) {
                    Column({ space: COLUMN_SPACE }) {
                      Text(item)
                        .attributeModifier(this.textTwo)

                      Text($r('app.string.commodity_model'))
                        .attributeModifier(this.textThree)

                      CommonText({ textFour: new MyTextModifier(TextType.TYPE_FOUR, TEXT_SIZE) })

                      Text($r('app.string.commodity_price'))
                        .attributeModifier(this.textOne)
                        .fontColor($r('app.color.orange'))
                    }
                  }
                  .height($r('app.string.max_size'))
                  .padding({ top: $r('app.float.float_10') })
                }
                .width($r('app.string.max_size'))
                .height($r('app.string.max_size'))
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
    }
    .title($r('app.string.shopping_cart'))
    .toolbarConfiguration(this.toolBar())
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getShoppingCart(): void {
  ShoppingCart();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.DYNAMIC_ATTRIBUTES, wrapBuilder(getShoppingCart))

