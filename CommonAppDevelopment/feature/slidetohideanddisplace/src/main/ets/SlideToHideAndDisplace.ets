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

import { IconAndDescription, Size } from './model/Util';

const YOffset130 = 130;
const YOffset100 = 100;
const YOffset60 = 60;
const YOffset50 = 50;
const YOffset40 = 40;
const YOffset20 = 20;
const Race = 1.70;
const BorderRadius = 8;
const CardWidth = 150;
const CardHeight = 200;
const SettingWidth = 24;

/**
 * 滑动页面改变顶部个人信息栏显示效果
 * 效果：上滑页面，用户头像逐渐缩小并移动到返回文字的后方，原本展示的手机号/选择身份/满意度调查的文本渐隐，顶部手机号文本渐显
 * 下滑页面，用户头像逐渐放大并向下移动，顶部手机号文本渐隐，下方手机号/选择身份/满意度调查的文本渐显
 */
@Entry
@Component
export struct SlideToHideAndDisplace {
  // 用户头像图片后方个人信息相关组件(用户名/选择身份/满意度调查)的透明度
  @State userRowOpacity: number = 1;
  // 返回文字后方的用户名(手机号)的透明度(进入页面时处于隐藏状态)
  @State userNameOpacity: number = 0;
  // 用户头像图片高度
  @State userImageHeight: number = 50;
  // Scroll组件顶部与上方Row组件(个人信息栏)的上边距
  @State scrollMarginTop: number = 0;
  // 用户头像图片顶部与父组件Row的上边距
  @State userImageMarginTop: number = 0;
  // 用户头像图片左侧与父组件Row的左边距
  @State userImageMarginLeft: number = 20;
  // 订单相关的图标和描述的数据列表
  iconsAndDescriptions1: IconAndDescription[] = [
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_11')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_12')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_13')),
    new IconAndDescription($r('app.media.more'), $r('app.string.icon_and_description_14'))
  ]
  // 粉丝/收藏/关注/历史相关的栏目的图标和描述的数据列表
  iconsAndDescriptions2: IconAndDescription[] = [
    new IconAndDescription($r('app.media.order'), $r('app.string.icon_and_description_21')),
    new IconAndDescription($r('app.media.star'), $r('app.string.icon_and_description_22')),
    new IconAndDescription($r('app.media.order'), $r('app.string.icon_and_description_23')),
    new IconAndDescription($r('app.media.star'), $r('app.string.icon_and_description_24'))
  ]
  // 商品会场的图标和描述的数据列表
  merchandiseVenue: IconAndDescription[] = [
    new IconAndDescription($r('app.media.arc_of_light'), $r('app.string.icon_and_description_31')),
    new IconAndDescription($r('app.media.arc_of_light'), $r('app.string.icon_and_description_32')),
    new IconAndDescription($r('app.media.arc_of_light'), $r('app.string.icon_and_description_33')),
    new IconAndDescription($r('app.media.arc_of_light'), $r('app.string.icon_and_description_34')),
  ]
  // 可滑动容器组件的控制器
  scroller: Scroller = new Scroller();

  // 自定义构建函数，将重复使用的UI元素抽象成一个方法。此处样式为：上方图标下方文字
  @Builder
  IconAndDescription(icon: Resource, description: string | Resource, iconSize?: Size, radius?: number) {
    Column() {
      Image(icon)
        .size(iconSize === undefined ? { height: $r('app.integer.icon_default_height'),
          width: $r('app.integer.icon_default_height') } : iconSize)
        .borderRadius(radius)
      Text(description)
        .margin({ top: $r('app.integer.margin_between_icon_and_description') })
    }
  }

  // 自定义构建函数。此处样式为：在Row组件中横向排列IconAndDescription
  @Builder
  CustomRow(iconsAndDescriptions: IconAndDescription[]) {
    Row() {
      ForEach(iconsAndDescriptions, (item: IconAndDescription) => {
        this.IconAndDescription(item.icon, item.description)
      })
    }
    .width($r('app.string.size_full'))
    .justifyContent(FlexAlign.SpaceAround)
    .padding($r('app.integer.padding_small'))
    .margin({ top: $r('app.integer.margin_small') })
    .backgroundColor($r('app.color.color_transparent_aa'))
    .borderRadius($r('app.integer.border_radius'))
  }

  /**
   * 创建一个Row组件，用来显示用户信息，然后在下面创建一个Scroll组件，用来显示其他内容，
   * 当Scroll滑动时，Row组件隐藏且里面的子组件渐隐
   */
  build() {
    Column() {
      Row() {
        Text($r('app.string.back'))
          .margin({ left: $r('app.integer.margin_between_icon_and_description') })
        Text($r('app.string.phone_number'))
          .margin({ left: $r('app.integer.margin_large') })
          .opacity(this.userNameOpacity) // userNameOpacity控制顶部用户名的透明度
        Blank()
        Text("设置")
          .opacity(this.userNameOpacity) // 设置的文字透明度与顶部用户名相同
        Text("客服")
          .margin({
            left: $r('app.integer.margin_small'),
            right: $r('app.integer.margin_small')
          })
          .opacity(this.userNameOpacity) // 客服的文字透明度与顶部用户名相同
      }
      .padding($r('app.integer.padding_small'))
      .width($r('app.string.size_full'))
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r('app.media.batman'))
          .width(this.userImageHeight)
          .height(this.userImageHeight)// userImageHeight控制头像尺寸
            // userImageMarginTop和userImageMarginLeft控制头像在父容器内的位置
          .margin({ top: this.userImageMarginTop, left: this.userImageMarginLeft })

        Column() {
          Text($r('app.string.phone_number'))
          Button($r('app.string.choose_identity'))
            .height($r('app.integer.button_height'))
            .width($r('app.integer.button_width'))
            .fontColor(Color.White)
            .margin({ top: $r('app.integer.margin_between_icon_and_description') })
        }
        .alignItems(HorizontalAlign.Start)
        .opacity(this.userRowOpacity) // 控制Row组件的透明度
        .padding($r('app.integer.padding_small'))

        Blank() // 在容器主轴方向上自动填充容器空余部分

        Row() {
          this.IconAndDescription($r('app.media.setting'), "设置", new Size(SettingWidth, SettingWidth))
          this.IconAndDescription($r('app.media.dialog'), "客服", new Size(SettingWidth, SettingWidth))
        }
        .margin({ right: $r('app.integer.margin_mid') })
        .width($r('app.integer.height_eighty'))
        .justifyContent(FlexAlign.SpaceBetween)
        .opacity(this.userRowOpacity)
      }
      .height($r('app.integer.height_one_hundred'))
      .width($r('app.string.size_full'))

      // Scroll组件中显示个人信息以外的内容
      Scroll(this.scroller) {
        Column() {
          // 会员栏目
          Row() {
            Column() {
              Text($r('app.string.member'))
                .fontSize($r('app.integer.font_size_mid'))
                .fontColor($r('app.color.member1'))
              Text($r('app.string.get_off_your_purchases'))
                .margin({ top: $r('app.integer.margin_between_icon_and_description') })
                .fontColor($r('app.color.member2'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('app.integer.padding_small'))

            Blank() // 在容器主轴方向上自动填充容器空余部分

            Column() {
              Image($r('app.media.crown'))
                .size({ width: $r('app.integer.icon_default_height'), height: $r('app.integer.icon_default_height') })
              Text("权益中心")
                .margin({ top: $r('app.integer.margin_between_icon_and_description') })
                .fontColor($r('app.color.member3'))
            }
            .padding($r('app.integer.padding_small'))
          }
          .height($r('app.integer.height_eighty'))
          .width($r('app.string.size_full'))
          .borderRadius($r('app.integer.border_radius'))
          .linearGradient({
            angle: 45, // 设置颜色渐变起始角度为顺时针方向45°
            colors: [[0x30fa908a, 0.0], [0x44aaaaa, 0.5], [0x30c2b1fa, 1.0]]
          })

          // 订单信息栏目
          this.CustomRow(this.iconsAndDescriptions1)
          // 粉丝/收藏/关注/历史栏目
          this.CustomRow(this.iconsAndDescriptions2)

          // 橘子购物街会场
          Column() {
            Row() {
              Text("橘子购物节")
                .fontSize($r('app.integer.margin_mid'))
                .fontColor($r('app.color.shopping'))
            }
            .width($r('app.string.size_full'))
            .margin({ left: $r('app.integer.margin_small'), top: $r('app.integer.margin_small') })

            Grid() {
              ForEach(this.merchandiseVenue, (item: IconAndDescription) => {
                GridItem() {
                  // 调用自定义构建函数，传入图标/描述/图标尺寸/图片圆角半径
                  this.IconAndDescription(item.icon, item.description, new Size(CardHeight, CardWidth), BorderRadius)
                }
              })
            }
            .columnsTemplate('1fr 1fr') // 将父组件均分为2列
            .columnsGap($r('app.integer.margin_small'))
            .rowsGap($r('app.integer.margin_small'))
            .width($r('app.string.size_full'))
            .height($r('app.integer.grid_height'))
            .margin({ top: $r('app.integer.margin_small') })
          }
          .backgroundColor($r('app.color.color_transparent_55'))
          .margin({ top: $r('app.integer.margin_small'), bottom: $r('app.integer.margin_small') })
          .borderRadius($r('app.integer.border_radius'))

          Text($r('app.string.in_the_end'))
            .fontColor(Color.Grey)
            .margin({ top: $r('app.integer.margin_large') })
        }
        .height($r('app.string.size_full'))
        .width($r('app.string.size_full'))
      }
      .height($r('app.string.size_one_hundred_and_thirty'))
      .linearGradient({
        angle: 180, // 渐变方向为从上到下
        colors: [[0xffffff, 0.0], [0xffeeee, 0.2], [0xffdddd, 1.0]]
      })
      .margin({ top: this.scrollMarginTop })
      .padding($r('app.integer.margin_default'))
      .scrollBar(BarState.Off)
      .onScroll(() => {
        // TODO: 知识点: Scroll组件绑定onScroll事件，然后在此方法里改变该组件的margin和opacity属性值的大小实现组件移动和隐显
        // 性能注释: onScroll属于频繁回调，不建议在onScroll做耗时和冗余操作
        let yOffset: number = this.scroller.currentOffset().yOffset;
        if (yOffset < YOffset100) {
          this.scrollMarginTop = -yOffset;
          this.userRowOpacity = yOffset < YOffset60 ? 1 - yOffset / YOffset60 : 0;
          this.userImageHeight = YOffset50 * (1 - (yOffset / YOffset130));
          this.userImageMarginTop = -yOffset * Race;
          this.userImageMarginLeft = YOffset20 * (1 + (yOffset / YOffset60));
          if (yOffset > YOffset40) {
            this.userNameOpacity = (yOffset - YOffset40) / YOffset40;
          } else {
            this.userNameOpacity = 0;
          }
        }
      })
    }
    .width($r('app.string.size_full'))
  }
}