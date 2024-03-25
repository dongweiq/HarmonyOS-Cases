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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

import { IconAndDescription, Size } from './model/Util';

const Y_OFFSET130 = 130;
const Y_OFFSET_TOP = 76;
const Y_OFFSET60 = 60;
const Y_OFFSET50 = 50;
const Y_OFFSET40 = 40;
const Y_OFFSET20 = 20;
const FULL_SIZE = 100;
const RACE = 1.56;
const BORDER_RADIUS = 8;
const CARD_WIDTH = 150;
const CARD_HEIGHT = 200;
const SETTING_WIDTH = 24;

/**
 * 滑动页面改变顶部个人信息栏显示效果
 * 效果：上滑页面，用户头像逐渐缩小并移动到返回文字的后方，原本展示的用户名/选择身份/设置/客服的文本和图标渐隐，顶部用户名文本渐显
 * 下滑页面，用户头像逐渐放大并向下移动，顶部用户名文本渐隐，下方用户名/选择身份/设置/客服的文本和图标渐显
 */

@Component
export struct SlideToHideAndDisplace {
  // 用户头像图片后方个人信息相关组件(用户名/选择身份/满意度调查)的透明度
  @State userRowOpacity: number = 1;
  // 返回文字后方的用户名的透明度(进入页面时处于隐藏状态)
  @State userNameOpacity: number = 0;
  // 用户头像图片高度
  @State userImageHeight: number = 50;
  // Scroll组件顶部与上方Row组件(个人信息栏)的上边距
  @State scrollMarginTop: number = 0;
  // 用户头像图片顶部与父组件Row的上边距
  @State userImageMarginTop: number = 0;
  // 用户头像图片左侧与父组件Row的左边距
  @State userImageMarginLeft: number = 0;
  // 订单相关的图标和描述的数据列表
  iconsAndDescriptions1: IconAndDescription[] = [
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_11')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_12')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_13')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_14'))
  ]
  // 粉丝/收藏/关注/历史相关的栏目的图标和描述的数据列表
  iconsAndDescriptions2: IconAndDescription[] = [
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_21')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_22')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_23')),
    new IconAndDescription($r('app.media.payment'), $r('app.string.icon_and_description_24'))
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
  iconAndDescription(icon: Resource, description: string | Resource, iconSize?: Size, radius?: number) {
    Column() {
      Image(icon)
        .size(iconSize === undefined ? {
          height: $r('app.integer.icon_default_height'),
          width: $r('app.integer.icon_default_height')
        } : iconSize)
        .borderRadius(radius)
      Text(description)
        .margin({ top: $r('app.integer.margin_between_icon_and_description') })
    }
  }

  // 自定义构建函数。此处样式为：在Row组件中横向排列IconAndDescription
  @Builder
  customRow(iconsAndDescriptions: IconAndDescription[]) {
    Row() {
      // 性能知识点：此处在Row中横向排列组件，列表项确定、数量较少，且需要一次性加载，因此使用ForEach。在列表项多的情况下，推荐使用LazyForEach
      ForEach(iconsAndDescriptions, (item: IconAndDescription) => {
        Column() {
          this.iconAndDescription(item.icon, item.description)
        }
        .width((FULL_SIZE / iconsAndDescriptions.length).toString() + '%')
      })
    }
    .width($r('app.string.size_full'))
    .padding($r('app.integer.padding_small'))
    .margin({ top: $r('app.integer.margin_small') })
    .backgroundColor($r('app.color.color_transparent_aa'))
    .borderRadius($r('app.integer.border_radius'))
  }

  // 会员和权益中心栏目
  @Builder
  memberBanner() {
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
        Text($r('app.string.center_of_right'))
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
  }

  // 橘子购物节会场
  @Builder
  shoppingVenue() {
    Column() {
      Text($r('app.string.orange_shopping_festival'))
        .fontSize($r('app.integer.margin_mid'))
        .fontColor($r('app.color.shopping'))
        .width($r('app.string.size_full'))
        .margin({ left: $r('app.integer.margin_small'), top: $r('app.integer.margin_small') })

      Grid() {
        // 性能知识点：此处在Grid中排列组件，列表项确定、数量较少，且需要一次性加载，因此使用ForEach。在列表项多的情况下，推荐使用LazyForEach
        ForEach(this.merchandiseVenue, (item: IconAndDescription) => {
          GridItem() {
            // 调用自定义构建函数，传入图标/描述/图标尺寸/图片圆角半径
            this.iconAndDescription(item.icon, item.description, new Size(CARD_HEIGHT, CARD_WIDTH), BORDER_RADIUS)
          }
        })
      }
      .columnsTemplate('1fr 1fr') // 将父组件均分为2列
      .rowsGap($r('app.integer.margin_small'))
      .width($r('app.string.size_full'))
      .height($r('app.integer.grid_height'))
      .margin({ top: $r('app.integer.margin_small') })
    }
    .backgroundColor($r('app.color.color_transparent_55'))
    .margin({ top: $r('app.integer.margin_small'), bottom: $r('app.integer.margin_small') })
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
        Text($r("app.string.user_name"))
          .margin({ left: $r('app.integer.margin_large') })
          .opacity(this.userNameOpacity) // userNameOpacity控制顶部用户名的透明度
        Blank()
        Text($r('app.string.settings'))
          .opacity(this.userNameOpacity) // 设置的文字透明度与顶部用户名相同
        Text($r('app.string.customer_service'))
          .margin({
            left: $r('app.integer.margin_small'),
            right: $r('app.integer.margin_small')
          })
          .opacity(this.userNameOpacity) // 客服的文字透明度与顶部用户名相同
      }
      .width($r('app.string.size_full'))
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r('app.media.batman'))
          .width(this.userImageHeight)
          .height(this.userImageHeight)// userImageHeight控制头像尺寸
            // userImageMarginTop和userImageMarginLeft控制头像在父容器内的位置
          .margin({ top: this.userImageMarginTop, left: this.userImageMarginLeft })

        Column() {
          Text($r("app.string.user_name"))
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
          this.iconAndDescription($r('app.media.setting'), $r('app.string.settings'), new Size(SETTING_WIDTH, SETTING_WIDTH))
          this.iconAndDescription($r('app.media.dialog'), $r('app.string.customer_service'), new Size(SETTING_WIDTH, SETTING_WIDTH))
        }
        .width($r('app.integer.height_eighty'))
        .justifyContent(FlexAlign.SpaceBetween)
        .opacity(this.userRowOpacity)
      }
      .height($r('app.integer.height_one_hundred'))
      .width($r('app.string.size_full'))

      // Scroll组件中显示个人信息以外的内容
      Scroll(this.scroller) {
        Column() {
          // 会员和权益中心栏目
          this.memberBanner()
          // 订单信息栏目
          this.customRow(this.iconsAndDescriptions1)
          // 粉丝/收藏/关注/历史栏目
          this.customRow(this.iconsAndDescriptions2)
          // 橘子购物街会场
          this.shoppingVenue()

          Text($r('app.string.in_the_end'))
            .fontColor(Color.Grey)
        }
        .height($r('app.string.size_full'))
        .width($r('app.string.size_full'))
      }
      .height($r("app.string.size_one_hundred_and_twenty"))
      .margin({ top: this.scrollMarginTop })
      .scrollBar(BarState.Off)
      .onScroll(() => {
        // TODO: 知识点: Scroll组件绑定onScroll事件，然后在此方法里改变该组件的margin和opacity属性值的大小实现组件移动和隐显
        // 性能知识点: onScroll属于频繁回调，不建议在onScroll做耗时和冗余操作
        const yOffset: number = this.scroller.currentOffset().yOffset;
        this.userRowOpacity = yOffset < Y_OFFSET60 ? 1 - yOffset / Y_OFFSET60 : 0;
        if (yOffset < Y_OFFSET_TOP) {
          this.scrollMarginTop = -yOffset;
          this.userImageHeight = Y_OFFSET50 * (1 - (yOffset / Y_OFFSET130));
          this.userImageMarginTop = -yOffset * RACE;
          this.userImageMarginLeft = Y_OFFSET20 * (yOffset / Y_OFFSET60) * RACE;
          if (yOffset > Y_OFFSET40) {
            this.userNameOpacity = (yOffset - Y_OFFSET40) / Y_OFFSET40;
          } else {
            this.userNameOpacity = 0;
          }
        } else {
          this.userImageHeight = Y_OFFSET50 * (1 - (Y_OFFSET_TOP / Y_OFFSET130));
          this.userImageMarginTop = -Y_OFFSET_TOP * RACE;
          this.userImageMarginLeft = Y_OFFSET20 * (Y_OFFSET_TOP / Y_OFFSET60) * RACE;
          this.userNameOpacity = 1;
        }
      })
    }
    .width($r('app.string.size_full'))
    .padding($r('app.integer.margin_default'))
    .linearGradient({
      angle: 180, // 渐变方向为从上到下
      colors: [[0xffffff, 0.0], [0xfff1f1, 0.2], [0xffdddd, 1.0]]
    })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getSlideToHideAndDisplace(): void {
  SlideToHideAndDisplace();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.SLIDE_TO_HIDE_AND_DISPLACE, wrapBuilder(getSlideToHideAndDisplace));