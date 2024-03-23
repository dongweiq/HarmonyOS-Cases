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

import { TABINFO } from '../model/TabBarData';
import { TabBarDataType } from '../model/DataType';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

const HOME_TAB_BAR_INDEX: number = 0; // 初始化社区的tab下标
const COMMUNITY_TAB_BAR_INDEX: number = 2; // 初始化社区的tab下标
const ARC_MARGIN_TOP: number = -15; // 圆弧的上外间距为-15

@Preview
@Component
export struct TabView {
  @Provide selectedIndex: number = 0; // 初始化被选定的tabBar下标
  private controller: TabsController = new TabsController(); // 初始化Tab控制器

  build() {
    Column() {
      Tabs({ index: this.selectedIndex, barPosition: BarPosition.End, controller: this.controller }) {
        // 首页模块
        TabContent() {
          Text($r('app.string.home'))
            .fontSize($r('app.integer.title_font_size'))
            .padding(20)
        }

        // 新品模块
        TabContent() {
          Text($r('app.string.news'))
            .fontSize($r('app.integer.title_font_size'))
        }

        // 社区模块
        TabContent() {
          Text($r('app.string.community'))
            .fontSize($r('app.integer.title_font_size'))
        }

        // 购物车模块
        TabContent() {
          Text($r('app.string.shopping_cart'))
            .fontSize($r('app.integer.title_font_size'))
        }

        // 我的模块
        TabContent() {
          Text($r('app.string.mine'))
            .fontSize($r('app.integer.title_font_size'))
        }
      }
      .vertical(false)
      .scrollable(false)
      .layoutWeight(1)
      .backgroundColor('#ffdbd9d9')
      .barHeight($r('app.integer.common_size_0'))
      .onChange((index: number) => {
        this.selectedIndex = index;
      })

      // 自定义TabBar组件
      CustomTabBar({ selectedIndex: $selectedIndex })
    }.width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}

@Component
struct CustomTabBar {
  @Link selectedIndex: number; // 初始化被选定的tabBar下标
  @State iconOffset: number = 0; // 初始化tabBar图片的偏移量

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      // 数据量比较少的情况下推荐使用ForEach，遇到数据量比较多的场景，如列表场景、瀑布流场景等，推荐使用LazyForEach(https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md/)
      ForEach(TABINFO, (item: TabBarDataType, tabIndex: number) => {
        // 单独一个TabBar组件
        TabItem({
          iconOffset: this.iconOffset,
          tabBarIndex: tabIndex,
          selectedIndex: $selectedIndex,
        })

      })
    }
    .height($r('app.integer.tab_bar_height_size'))
  }
}

/**
 * 场景1：TabBar中间页面如何实现有一圈圆弧外轮廓
 * 可以将Image外层包括一层容器组件，通过设置borderRadius以及margin的top值实现圆弧外轮廓效果。
 * 这里borderRadius的值设置为容器组件宽度的一半，margin的top值根据开发者的ux效果设置合适的值即可。
 * 场景2：TabBar页签点击之后会改变图标显示，并有一小段动画效果
 * 改变图标显示可以声明一个变量selectedIndex，此变量代表被选定的tabBar下标，点击的时候将当前tabBar的下标值进行赋值。
 * 通过当前被选中的tabBar下标值和tabBar的默认下标值进行判断来达到点击之后改变图标显示的效果。
 * 动画效果可以将Image添加一个offset属性和animation属性，offset属性可以控制组件的横向和纵向偏移量；
 * animation在组件的某些通用属性变化时，可以通过属性动画animation实现过渡效果。
 * 点击TabBar页签，改变offset的属性值，自动触发animation属性动画。
 * animation参考文档:
 * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/arkui-ts/ts-animatorproperty.md/
 */

@Component
struct TabItem {
  @Prop iconOffset: number; // 初始化tabBar图片的偏移量
  @Prop tabBarIndex: number; // tabBar下标
  @Link selectedIndex: number; // 初始化被选定的tabBar下标

  build() {
    Column() {
      Stack() {
        // 判断tab的下标是否为2
        if (this.tabBarIndex === COMMUNITY_TAB_BAR_INDEX) {
          Column() {
            Image(this.selectedIndex === this.tabBarIndex ? TABINFO[this.tabBarIndex].selectedIcon :
                  TABINFO[this.tabBarIndex].defaultIcon)
              .size({
                width: $r('app.integer.community_image_size'),
                height: $r('app.integer.community_image_size')
              })
              .interpolation(ImageInterpolation.High) // TODO：知识点：使用interpolation属性对图片进行插值，使图片显示得更清晰
          }
          .width($r('app.integer.community_image_container_size'))
          .height($r('app.integer.community_image_container_size'))
          // TODO：知识点：通过设置borderRadius以及margin的top值实现圆弧外轮廓效果。
          .borderRadius($r('app.integer.community_image_container_border_radius_size'))
          .margin({ top: ARC_MARGIN_TOP })
          .backgroundColor(Color.White)
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            // 通过被选中的tabBar下标值和tabBar的默认下标值来改变图片显示
            Image(this.selectedIndex === this.tabBarIndex ? TABINFO[this.tabBarIndex].selectedIcon :
                  TABINFO[this.tabBarIndex].defaultIcon)
              // TODO：知识点：使用interpolation属性对图片进行插值，使图片显示得更清晰
              .interpolation(ImageInterpolation.High)
              .size(this.selectedIndex === HOME_TAB_BAR_INDEX && this.selectedIndex === this.tabBarIndex ?
                { width: $r('app.integer.community_image_size'), height: $r('app.integer.community_image_size') } :
                {
                  width: $r('app.integer.tab_bar_image_size'),
                  height: $r('app.integer.tab_bar_image_size')
                })
              // TODO：知识点：通过offset控制图片的纵向偏移。
              .offset({
                y: (this.selectedIndex === this.tabBarIndex && this.selectedIndex !== COMMUNITY_TAB_BAR_INDEX) ?
                this.iconOffset : $r('app.integer.common_size_0')
              })
              // TODO：知识点：组件的某些通用属性变化时，可以通过属性动画animation实现过渡效果。本示例的动画效果是tabBar的图片向上偏移一小段距离
              .animation({
                duration: 400,
                curve: Curve.Ease,
                iterations: 1,
                playMode: PlayMode.Normal
              })
          }
          .width(this.selectedIndex === HOME_TAB_BAR_INDEX && this.selectedIndex === this.tabBarIndex ?
          $r('app.integer.community_image_size') : $r('app.integer.tab_bar_image_container_size'))
          .height(this.selectedIndex === HOME_TAB_BAR_INDEX && this.selectedIndex === this.tabBarIndex ?
          $r('app.integer.community_image_size') : $r('app.integer.tab_bar_image_container_size'))
          .justifyContent(FlexAlign.Center)
        }
      }

      Text(TABINFO[this.tabBarIndex].title)
        .fontSize($r('app.integer.tab_bar_text_font_size'))
        .fontColor(this.selectedIndex === this.tabBarIndex ? $r('app.color.selected_text_color') : Color.Black)
        .visibility(this.selectedIndex === HOME_TAB_BAR_INDEX && this.selectedIndex === this.tabBarIndex ? Visibility.None : Visibility.Visible)
    }
    .width($r('app.integer.tab_bar_height_size'))
    .onClick(() => {
      // 更新被选中的tabBar下标
      this.selectedIndex = this.tabBarIndex;
      // 此处控制tabBar的Image图片向上偏移
      this.iconOffset = -3;
    })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getTabView(): void {
  TabView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.CUSTOM_TAB_BAR, wrapBuilder(getTabView));