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

import { HomeTop, SettingItemView, StatusHead, ImageMapView } from "../components/Component";
import window from '@ohos.window';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import WindowModel from '../utils/WindowModel';
import { logger } from '@ohos/utils/src/main/ets/log/Logger';
import { SettingItem } from '../utils/dataSource'
import { CommonConstants } from '../constants/CommonConstants';
import promptAction from '@ohos.promptAction';

/**
 * 本实例介绍利用list及onTouch属性实现底部抽屉滑动效果场景
 * 实现步骤：
 * 1.通过listHeight记录底部列表高度变化
 * 2.通过onTouch属性实现根据手指滑动距离，底部列表高度进行变化
 * 3.手指移开屏幕后，通过判断列表高度实现抽屉式滑动效果
 */

@Component
export struct BottomDrawerSlideCase {
  @State bottomAvoidHeight: number = 0; //底部导航条高度
  private listScroller = new ListScroller(); // list滚动控制器
  @State listHeight: number = 0; // list高度
  @State windowHeight: number = 0; // window高度
  @State statusBarHeight: number = 0; // 顶部状态栏高度
  private yStart: number = 0; // list触摸事件起始纵坐标
  private windowModel: WindowModel = WindowModel.getInstance(); // 窗口管理model
  @State isScroll: boolean = false; // list是否可以滚动
  @State isUp: boolean = true; // list是否向上滑动
  @State isShow: boolean = false; // 顶部遮蔽导航栏区域是否显示
  @State listItem: SettingItem[] = [
    new SettingItem('list_item_id_first'),
    new SettingItem('list_item_id_second'),
    new SettingItem('list_item_id_third'),
    new SettingItem('list_item_id_fourth'),
    new SettingItem('list_item_id_fifth'),
    new SettingItem('list_item_id_sixth'),
    new SettingItem('list_item_id_seventh'),
    new SettingItem('list_item_id_eighth'),
  ]; // list内容项
  @State firstListItemHeight: number = 195; // 列表第一个item高度
  @State secondListItemHeight: number = this.bottomAvoidHeight + 150; // 列表第二个item高度
  @State scrollOffset: number = 0;

  aboutToAppear(): void {
    // 初始化窗口管理model
    const windowStage: window.WindowStage | undefined = AppStorage.get('windowStage');

    // 没有windowStage将无法执行下列逻辑
    if (!windowStage) {
      logger.warn('windowStage init error!');
      return;
    }
    this.windowModel.setWindowStage(windowStage);

    // 设置沉浸模式
    this.windowModel.setMainWindowImmersive(true);

    // 获取顶部导航栏高度
    this.windowModel.getStatusBarHeight((statusBarHeight) => {
      this.statusBarHeight = px2vp(statusBarHeight);
    })

    // 获取底部导航条高度
    this.windowModel.getBottomAvoidHeight((bottomAvoidHeight) => {
      this.bottomAvoidHeight = px2vp(bottomAvoidHeight) / 2;
    })

    // 获取窗口高度
    this.windowModel.getWindowHeight().then(s => {
      this.windowHeight = s;
    })

    // 底部list初始显示高度
    this.listHeight = CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight;
  }

  aboutToDisappear(): void {
    // 关闭沉浸模式
    this.windowModel.setMainWindowImmersive(false);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      RelativeContainer() {

        // Image地图
        ImageMapView()
          .id('map')

        // 地图顶部标题栏
        HomeTop({ statusBarHeight: this.statusBarHeight })
          .alignRules({
            'top': { 'anchor': '__container', 'align': VerticalAlign.Top },
            'left': { 'anchor': '__container', 'align': HorizontalAlign.Start },
            'right': { 'anchor': '__container', 'align': HorizontalAlign.End },
          })
          .id('title_bar')

        // 底部可变分阶段滑动列表
        List({ scroller: this.listScroller }) {
          ListItemGroup({ header: this.itemHead("安全出行季") }) {
            ListItem() {
              Column() {
                Row() {
                  Text($r('app.string.set_out'))
                    .fontSize($r('app.integer.number_15'))
                  Text($r('app.string.destination_new'))
                    .fontSize($r('app.integer.number_15'))
                    .fontColor(Color.Green)
                  Text($r('app.string.get_on_the_car'))
                    .fontSize($r('app.integer.number_15'))
                }
                .height($r('app.integer.height_50'))
                .width('80%')

                Text($r('app.string.please_destination'))
                  .padding({ left: $r('app.integer.number_10') })
                  .fontSize($r('app.integer.number_22'))
                  .fontWeight(2)
                  .height($r('app.integer.number_60'))
                  .backgroundColor($r('app.color.list_first_backgroundcolor'))
                  .borderRadius($r('app.integer.number_10'))
                  .width('80%')
                  .onClick(() => {
                    promptAction.showToast({
                      message: '该功能暂未开发',
                      duration: 2000
                    })
                  })
              }
              .height('80%')
              .width('98%')
              .padding({ left: $r('app.integer.number_15'), right: $r('app.integer.number_15') })
              .justifyContent(FlexAlign.Center)
              .borderRadius($r('app.integer.number_10'))
              .shadow({
                radius: $r('app.integer.number_30'), // 阴影模糊半径
                color: $r('app.color.list_first_backgroundcolor'),
                offsetY: $r('app.integer.number_5') // Y轴偏移量
              })
            }
            .borderRadius({ topLeft: 15, topRight: 15 })
            .width(CommonConstants.FULL_SIZE)
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.firstListItemHeight = (newValue.height) as number;
            })
            .height(this.firstListItemHeight)
            .backgroundColor(Color.White)

            // 性能知识点：此处列表，列表项确定且数量较少，使用了ForEach，在列表项多的情况下，推荐使用LazyForeEach
            ForEach(this.listItem, (item: SettingItem) => {
              ListItem() {
                SettingItemView({ bottomAvoidHeight: this.bottomAvoidHeight })
              }
              .onAreaChange((oldValue: Area, newValue: Area) => {
                this.secondListItemHeight = (newValue.height) as number;
              })
              .backgroundColor(Color.White)
              .width(CommonConstants.FULL_SIZE)
            }, (item: SettingItem) => item.id.toString())
          }
        }
        .borderRadius($r('app.integer.number_10'))
        .scrollBar(BarState.Off) // 滚动条不显示
        .edgeEffect(EdgeEffect.None) // list滑动到顶部和底部效果
        .width(CommonConstants.FULL_SIZE)
        .height(this.listHeight)
        .alignRules({
          'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
          'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
        })
        .onReachStart(() => {
          this.isScroll = false;
          console.info('listtest' + this.isScroll)
        })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          if (oldValue !== newValue) {
            this.listScroller.scrollToIndex(0, true);
          }
        })
        .onScroll((scrollOffset: number) => {
          this.scrollOffset = scrollOffset;
          console.info('listtest' + scrollOffset)
        })
        .id('scrollPart')
        .margin({ left: $r('app.integer.height_10'), right: $r('app.integer.height_10') })
        .sticky(StickyStyle.None) // 列表吸顶效果
        .enableScrollInteraction(this.isScroll)
        .animation({
          duration: 300, // 动画持续时间，单位毫秒
          curve: Curve.Friction, // 动画曲线
          iterations: 1, // 动画播放次数
          playMode: PlayMode.Normal// 动画播放模式
        })

        .onTouch((event) => {
          if (!event) {
            return;
          }
          if (this.isScroll && this.scrollOffset !== 0) {
            return;
          }

          switch (event.type) {
          // 手指按下触摸屏幕
            case TouchType.Down: {
              this.yStart = event.touches[0].y;
              break;
            }

          // 手指离开屏幕
            case TouchType.Up: {
              this.yStart = event.touches[0].y;
              let maxHeight = this.windowHeight - this.statusBarHeight; // 设置list最大高度
              // 列表上滑时，分阶段滑动
              if (this.isUp) {
                // 分阶段滑动，当list高度位于第一个item和第二个item之间时，滑动到第二个item
                if (this.listHeight > CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight && this.listHeight <= CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.bottomAvoidHeight + this.secondListItemHeight) {
                  this.listHeight = CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.secondListItemHeight;
                  this.isShow = false;
                  return;
                }
                // 分阶段滑动，当list高度位于顶部和第二个item之间时，滑动到页面顶部
                if (CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.bottomAvoidHeight + this.secondListItemHeight < this.listHeight && this.listHeight <= maxHeight) {
                  this.listHeight = maxHeight;
                  this.isScroll = true;
                  this.isShow = true;
                  return;
                }
              }
              // 列表下滑时，分阶段滑动
              else {
                // 分阶段滑动，当list高度位于顶部和第二个item之间时,滑动到第二个item
                if (this.listHeight >= CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.secondListItemHeight && this.listHeight <= maxHeight) {
                  this.listHeight = CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.secondListItemHeight;
                  this.isShow = false;
                  return;
                }
                // 分阶段滑动，当list高度位于第一个item和第二个item之间时，滑动到第一个item
                if (this.listHeight <= CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight + this.secondListItemHeight + this.bottomAvoidHeight || this.listHeight <= CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight) {
                  this.listHeight = CommonConstants.LIST_HEADER_HEIGHT + this.firstListItemHeight;
                  this.isShow = false;
                  return;
                }
              }
              break;
            }
          // 当手指在屏幕滑动时，判断是上滑/下滑
            case TouchType.Move: {
              let yEnd = event.touches[0].y; // 手指离开屏幕的纵坐标
              let height = Math.abs(Math.abs(yEnd) - Math.abs(this.yStart)); // 手指在屏幕上的滑动距离
              let maxHeight = this.windowHeight - this.statusBarHeight; // list列表的最大高度
              // 防止误触导致列表高度变化,当手指在屏幕滑动一段距离时才触发后续变化
              if (height > 10) {
                // 判断上滑，且list跟随手势滑动
                if (yEnd < this.yStart) {
                  this.isUp = true;
                  let temHeight = this.listHeight + height;
                  if (temHeight >= maxHeight) {
                    this.isScroll = true;
                    this.isShow = true;
                    this.listHeight = maxHeight;
                  } else {
                    this.isScroll = false;
                    this.listHeight = temHeight;
                  }
                }
                // 判断下滑，且list跟随手势滑动
                else {
                  this.isUp = false;
                  this.isScroll = false;
                  // 防止列表惯性滑动减少list高度
                  if (!this.isScroll) {
                    let temHeight = this.listHeight - height;
                    // 列表高度随滑动高度变化
                    this.listHeight = temHeight;
                  }
                }
              }
              this.yStart = event.touches[0].y;
            }
          }

        })
      }

      // 当列表滑动到第三阶段再向上划，出现的顶部导航栏遮蔽区域
      StatusHead({
        statusBarHeight: this.statusBarHeight,
        topHeaderHeight: CommonConstants.PAGE_HEADER_HEIGHT,
        isShow: this.isShow
      })
    }
    .width(CommonConstants.FULL_SIZE)
    .height(CommonConstants.FULL_SIZE)

  }

  // list头部的标题栏
  @Builder
  itemHead(text: string) {
    Column() {
      Row() {
        Text(text)
          .fontSize($r('app.string.fontsize_15'))
          .fontColor($r('app.color.list_header_text'))
      }
      .shadow({
        radius: $r('app.integer.number_10'), // 阴影模糊半径
        color: $r('app.color.list_header_shadow'),
      })
      .height($r('app.integer.height_50'))
      .width('40%')
      .margin({ left: $r('app.integer.number_30') })
      .backgroundColor($r('app.color.list_header_backgroundcolor'))
      .borderRadius($r('app.integer.number_10'))
      .padding({ left: $r('app.integer.number_15') })

      Blank()
        .height($r('app.integer.number_10'))
        .backgroundColor(Color.Transparent)
    }
    .height(CommonConstants.LIST_HEADER_HEIGHT)
    .borderRadius($r('app.integer.number_10'))
  }
}


/**
 * 创建WrappedBuilder对象，动态路由跳转时构建页面
 */
@Builder
export function getBottomDrawerSlideCase(): void {
  BottomDrawerSlideCase();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.BOTTOM_DRAWER_SLIDE_CASE, wrapBuilder(getBottomDrawerSlideCase));

