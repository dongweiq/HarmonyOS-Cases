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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 实现步骤：
 * 1. 页签实现：添加onClick方法，记录点击的index，index变化后，改变页签颜色、字体大小，使用animateTo方法实现页签切换动画
 * 2. 内容区实现：使用List，添加滑动手势来进行页面的切换，手势响应后，使用scrollToIndex方法来实现平滑的滑动到相应index
 */
@Component
export struct CustomView
{
  // 当前选中的页签index
  @State currentIndex: number = 0;
  // 颜色条的偏移量
  @State transitionX: number = 0;
  // 即将前往的页签index
  @State wantGoIndex: number = 0;
  // 创建Scroller对象
  scroller: Scroller = new Scroller();
  // 页签显示数据
  private titleArray: Array<string> = ['候补预测', '在线换座', '余票挖掘', '个人中心'];

  build() {
    Column() {
      // 页签实现
      DiscoverTopView({currentIndex: this.currentIndex, transitionX: this.transitionX,
                       wantGoIndex: this.wantGoIndex, scroller: this.scroller, titleArray: this.titleArray})
      // 内容区域实现
      DiscoverTabView({currentIndex: this.currentIndex, transitionX: this.transitionX,
                       wantGoIndex: this.wantGoIndex, scroller: this.scroller, titleArray: this.titleArray})
    }
    .width($r('app.string.one_hundred_percent'))
    .height($r('app.integer.width_and_height_one_hundred'))
    .backgroundColor(Color.White)
  }
}

// 顶部页签实现
@Component
struct DiscoverTopView {
  // 当前选中的页签index
  @Link currentIndex: number;
  // 颜色条的偏移量
  @Link transitionX: number;
  // 即将前往的页签index
  @Link wantGoIndex: number;
  // 创建Scroller对象
  scroller: Scroller = new Scroller();
  // 页签显示数据
  titleArray: Array<string> = [];
  // 计算title长度的一半
  private titleLengthHalf: number = 2;
  // 颜色条长度的一半
  private colorBarHalf: number = 10;
  // title宽度计算基数
  private titleLengthRadix: number = 20;
  // 循环因子初始值
  private loopDefault: number = 0;
  // duration计算基数
  private durationRadix: number = 200;
  // iterations默认值
  private iterationsDefault: number = 1;

  aboutToAppear() {
    // 获取颜色条偏移量
    this.transitionX = this.getTransitionX(this.currentIndex);
  }

  // 获取颜色条偏移量
  getTransitionX(index: number) {
    let theNumber: number = 0;
    for (let i = this.loopDefault; i <= index; i++) {
      const title = this.titleArray[i];
      const titleLength = title.length * this.titleLengthRadix;
      if (i === index) {
        theNumber += titleLength / this.titleLengthHalf - this.colorBarHalf;
      } else {
        theNumber += titleLength;
      }
    }
    return theNumber;
  }

  build() {
    Column() {
      Row() {
        // TODO 高性能知识点：此处为了演示场景，列表数量只有4个，使用ForEach，列表数量较多的场景，推荐使用LazyForEach+组件复用+缓存列表项实现
        ForEach(this.titleArray, (title: string, idx: number) => {
          Text(title)
            .textAlign(TextAlign.Center)
            .height($r('app.integer.width_and_height_thirty'))
            .width(this.titleLengthRadix * title.length)
            .fontColor(this.currentIndex === idx ?
              (this.wantGoIndex === idx ? $r('app.color.font_selected_state'):$r('app.color.font_unselected_state')):
              (this.wantGoIndex === idx ? $r('app.color.font_selected_state'):$r('app.color.font_unselected_state')))
            .fontSize(this.currentIndex === idx ? $r('app.integer.font_size_eighteen') : $r('app.integer.font_size_fourteen'))
            .fontWeight(this.currentIndex === idx ? FontWeight.Bold : FontWeight.Normal)
            .onClick(() => {
              // TODO 知识点：页签实现：记录点击index，index变化后，获取颜色条偏移量，刷新页签颜色、字体大小，实现效果
              if (this.currentIndex !== idx) {
                // 记录点击index
                this.wantGoIndex = idx;
                // 动画效果
                animateTo({
                  duration: Math.abs(idx - this.currentIndex) * this.durationRadix,
                  curve: Curve.EaseInOut,
                  iterations: this.iterationsDefault,
                  playMode: PlayMode.Normal,
                  onFinish: () => {
                    this.currentIndex = idx;
                    // 高性能知识点：scrollToIndex方法，开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题
                    this.scroller.scrollToIndex(this.currentIndex, true, ScrollAlign.START);
                  }
                }, () => {
                  // 获取颜色条偏移量
                  this.transitionX = this.getTransitionX(idx);
                })
              }
            })
        })
      }
      .height($r('app.integer.width_and_height_thirty'))
      .width($r('app.string.one_hundred_percent'))

      Row()
        .width($r('app.integer.width_and_height_twenty'))
        .height($r('app.string.one_hundred_percent'))
        .borderRadius($r('app.integer.borderRadius_value'))
        .backgroundColor($r('app.color.color_bar'))
        .position({x: this.transitionX, y: $r('app.integer.positionY')})
    }
    .height($r('app.integer.width_and_height_forty'))
    .width($r('app.string.ninety_two_percent'))
  }
}

// 内容区域实现
@Component
struct DiscoverTabView {
  // 当前选中的页签index
  @Link currentIndex: number;
  // 颜色条的偏移量
  @Link transitionX: number;
  // 即将前往的页签index
  @Link wantGoIndex: number;
  // 创建Scroller对象
  scroller: Scroller = new Scroller();
  // 页签显示数据
  titleArray: Array<string> = [];
  // 计算title长度的一半
  private titleLengthHalf: number = 2;
  // 颜色条长度的一半
  private colorBarHalf: number = 10;
  // title宽度计算基数
  private titleLengthRadix: number = 20;
  // 循环因子初始值
  private loopDefault: number = 0;
  // duration计算基数
  private durationRadix: number = 200;
  // iterations默认值
  private iterationsDefault: number = 1;
  // 判断条件值
  private judgmentValue: number = 0;
  // currentIndex计算基数
  private currentIndexRadix: number = 1;
  // 创建PanGestureOptions对象
  private panOption: PanGestureOptions = new PanGestureOptions({direction: PanDirection.Left | PanDirection.Right});
  // 是否开始动画标志
  isStartAction: boolean = false;

  // 获取偏移量
  getTransitionX(index: number) {
    let theNumber: number = 0;
    for (let i = this.loopDefault; i <= index; i++) {
      const title = this.titleArray[i];
      const titleLength = title.length * this.titleLengthRadix;
      if (i === index) {
        theNumber += titleLength / this.titleLengthHalf - this.colorBarHalf;
      } else {
        theNumber += titleLength;
      }
    }
    return theNumber;
  }

  // 实现动画效果
  achieveEffect(temIndex: number) {
    // 高性能知识点：scrollToIndex方法，开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题
    this.scroller.scrollToIndex(temIndex, true, ScrollAlign.START);
    this.wantGoIndex = temIndex;
    // 动画效果
    animateTo({
      duration: Math.abs(temIndex - this.currentIndex) * this.durationRadix,
      curve: Curve.EaseInOut,
      iterations: this.iterationsDefault,
      playMode: PlayMode.Normal,
      onFinish: () => {
        this.currentIndex = temIndex;
      }
    }, () => {
      this.transitionX = this.getTransitionX(temIndex);
    })
  }

  build() {
    List({ scroller: this.scroller }) {
      // 内容区域部分
      // TODO 高性能知识点：此处为了演示场景，列表数量只有4个，使用ForEach，列表数量较多的场景，推荐使用LazyForEach+组件复用+缓存列表项实现
      ForEach(this.titleArray, (item: string) => {
        ListItem() {
          Text(item)
            .width($r('app.string.one_hundred_percent'))
            .height($r('app.integer.width_and_height_fifty'))
            .fontSize($r('app.integer.font_size_twenty_five'))
            .textAlign(TextAlign.Center)
        }
      })
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .priorityGesture(
      PanGesture(this.panOption)
        // TODO 知识点：内容区域实现：添加滑动手势，手势响应后，使用scrollToIndex方法来实现效果
        .onActionUpdate((event: GestureEvent) => {
          if (!this.isStartAction) {
            this.isStartAction = true;
            if (event.offsetX < this.judgmentValue) {
              if (this.currentIndex < this.titleArray.length - this.currentIndexRadix) {
                const temIndex: number = this.currentIndex + this.currentIndexRadix;
                this.achieveEffect(temIndex);
              }
            } else {
              if (this.currentIndex > this.judgmentValue) {
                const temIndex: number = this.currentIndex - this.currentIndexRadix;
                this.achieveEffect(temIndex);
              }
            }
          }
        })
        .onActionEnd(() => {
          this.isStartAction = false;
        })
    )
    .backgroundColor($r('app.color.theme_color'))
    .width($r('app.string.one_hundred_percent'))
    .height($r('app.integer.width_and_height_fifty'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getCustomView(): void {
  CustomView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.CUSTOM_VIEW,wrapBuilder(getCustomView));