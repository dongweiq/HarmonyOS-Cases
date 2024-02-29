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

import { Callback } from '@kit.BasicServicesKit';
import { MemoDataSource } from '../model/DataSource';
import { MemoInfo } from '../model/MemoInfo';
import MemoItem from '../view/MemoItem';
import Constants from '../model/Constants';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * 本示例以备忘录应用为示例，介绍如何在实现标题展开时继续下拉的动效。
 * 通过状态变量isExpanded控制标题是否展开，通过状态变量heightValue控制内容高度变化；
 * 而状态变量的更新在onTouch时间的响应函数handleTouchEvent中处理，根据手指滑动类型TouchType分情况处理；
 * 当响应状态变量更新的动画，通过为标题和菜单绑定属性动画animation实现。
 */
@Preview
@Component
export struct TitleExpansion {
  @State @Watch("isContinuePullDown") isExpanded: boolean = false; // 标题是否展开 列表是否完成第一次下滑
  @State @Watch("isContinuePullDown") isMoving: boolean = false; // 笔记列表是否在被拖动
  @State @Watch("isContinuePullDown") offsetY: number = Constants.INIT_COORDINATE; // 列表y坐标偏移量
  @State heightValue: ResourceStr = $r('app.string.memo_area_height_before'); // 笔记列表布局高度
  @State duration: number = Constants.ANIMATE_DURATION_DRAG; // 动画持续时间
  @State memoData: MemoDataSource = new MemoDataSource(); // 懒加载模拟数据源
  private downY: number = Constants.INIT_COORDINATE; // 按下时的y坐标
  private lastMoveY: number = Constants.INIT_COORDINATE; // 上一次移动结束时的坐标
  private throttleStatus: boolean = true; // 节流器状态

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          // 展开前的标题
          Text(!this.isExpanded ? $r('app.string.memo_title') : '')
            .fontSize($r('app.string.init_title_font_size'))
          Blank()
          Image($r("app.media.is_public_add"))
            .width($r('app.string.menu_pic_layout'))
            .height($r('app.string.menu_pic_layout'))
          Image($r("app.media.ic_public_more"))
            .width($r('app.string.menu_pic_layout'))
            .height($r('app.string.menu_pic_layout'))
            .margin({ left: $r('app.string.layout_8') })
        }
        .width($r('app.string.layout_100_percent'))
        .padding($r('app.string.layout_25'))
        .margin({ top: $r('app.string.layout_10') })
        .alignItems(VerticalAlign.Center)
        .translate(this.getMenuTranslateOptions()) // TODO：知识点：配置菜单平移参数
        .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })

        // 展开后的标题
        Column() {
          Text($r('app.string.memo_title'))
            .fontSize($r('app.string.expanded_title_font_size'))
          Text($r('app.string.memo_counts'))
            .fontSize($r('app.string.memo_counts_font_size'))
            .fontColor(Color.Grey)
        }
        .width($r('app.string.layout_100_percent'))
        .padding({ left: $r('app.string.layout_25') })
        .margin({ top: $r('app.string.layout_10') })
        .alignItems(HorizontalAlign.Start)
        .translate(this.getTitleTranslateOptions()) // TODO：知识点：配置标题平移参数
        .scale(this.getTitleScaleOptions()) // TODO：知识点：配置标题缩放参数
        .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })
        .transition({ type: TransitionType.Insert, translate: { y: Constants.TRANSLATE_Y } })
        .visibility(this.isExpanded ? Visibility.Visible : Visibility.Hidden) // 性能知识点：相对频繁的显隐切换，可以使用显隐控制替换条件渲染，减少组件的反复销毁创建成本。

      }
      .height($r('app.string.layout_100_percent'))
      .width($r('app.string.layout_100_percent'))

      Column() {
        List({ space: Constants.SEARCH_MEMO_SPACE }) {
          ListItem() {
            Search({ placeholder: $r('app.string.search_placeholder') })
              .width($r('app.string.layout_100_percent'))
              .height($r('app.string.layout_40'))
              .backgroundColor(Color.White)
          }
          // 性能知识点：动态加载数据场景可以使用LazyForEach遍历数据。参考资料：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
          LazyForEach(this.memoData, (item: MemoInfo) => {
            ListItem() {
              MemoItem({ memoItem: item })
            }
          }, (item: MemoInfo) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .margin({ left: $r('app.string.layout_10'), right: $r('app.string.layout_10') })
        .width($r('app.string.layout_90_percent'))
      }
      .width($r('app.string.layout_100_percent'))
      .height(this.heightValue) // 通过状态变量heightValue控制内容高度变化
      .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })
      .onTouch((event: TouchEvent) => this.handleTouchEvent(event))
    }
    .backgroundColor($r("app.color.background_color"))
  }

  /**
   * 获取标题展开时，图标继续下拉的Translate参数
   */
  getMenuTranslateOptions(): TranslateOptions {
    return this.isContinuePullDown() ? {
      y: Math.min(this.offsetY - Constants.CONTENT_DOWN_Y_THRESHOLD, Constants.MENU_DOWN_Y_MAX_VALUE)
    } : { y: Constants.INIT_COORDINATE };
  }

  /**
   * 获取标题展开时，标题继续下拉的Translate参数
   */
  getTitleTranslateOptions(): TranslateOptions {
    return this.isContinuePullDown() ? {
      y: Math.min(this.offsetY - Constants.CONTENT_DOWN_Y_THRESHOLD, Constants.TITLE_DOWN_Y_MAX_VALUE)
    } : { y: Constants.INIT_COORDINATE };
  }

  /**
   * 获取标题展开时，标题缩放的Scale参数
   */
  getTitleScaleOptions(): ScaleOptions {
    return this.isContinuePullDown() ? {
      x: Constants.TITLE_SCALE_MAX_VALUE,
      y: Constants.TITLE_SCALE_MAX_VALUE,
      centerX: Constants.INIT_COORDINATE,
      centerY: Constants.INIT_COORDINATE
    } : {
      x: Constants.TITLE_SCALE_DEFAULT_VALUE,
      y: Constants.TITLE_SCALE_DEFAULT_VALUE,
      centerX: Constants.INIT_COORDINATE,
      centerY: Constants.INIT_COORDINATE
    };
  }

  /**
   * 判断是否达到触发继续下拉动效的条件
   */
  isContinuePullDown(): boolean {
    return this.isMoving && this.isExpanded && this.offsetY >= Constants.CONTENT_DOWN_Y_THRESHOLD;
  }

  /**
   * onTouch事件响应函数，根据手指滑动类型TouchType分为三种情况处理：
   * 1. TouchType.Down，即手指下按时：记录按下时的坐标downY，并更新状态变量isMoving为开始滑动、duration为初始动画时长
   * 2. TouchType.Move，即手指滑动时：根据滑动方向的不同，更新滑动距离offsetY、内容高度heightValue、标题是否展开等状态变量
   * 3. TouchType.Up、TouchType.Cancel，即滑动结束时：更新状态变量isMoving为停止滑动、duration为回弹动画时长
   */
  handleTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      // 手指下按时
      case TouchType.Down:
        this.downY = event.touches[0].y;
        this.lastMoveY = event.touches[0].y;
        this.isMoving = true;
        this.duration = Constants.ANIMATE_DURATION_DRAG; // 重置动画持续时间
        break;

      // 手指滑动时
      case TouchType.Move:
        const delta = event.touches[0].y - this.lastMoveY;
        this.offsetY = event.touches[0].y - this.downY;
        if (delta < 0) { // TODO：知识点：手势为上滑时
          this.heightValue = $r('app.string.memo_area_height_before');
          this.isExpanded = false;
        }
        if (delta > 0) { // TODO：知识点：手势为下滑时
          // 性能知识点：手指滑动的时，直接使用animateTo，会创建大量的animateTo对象，可以通过节流器优化性能
          this.animateToThrottle(() => {
            this.heightValue = $r('app.string.memo_area_height_after');
            this.isExpanded = true;
          }, 1000);
        }
        this.lastMoveY = event.touches[0].y;
        break;

      // 滑动结束时
      case TouchType.Up:
      case TouchType.Cancel:
        this.isMoving = false;
        this.duration = Constants.ANIMATE_DURATION_BACK; // 控制回弹动画时间
        break;
    }
  }

  /**
   * 节流器：如果短时间内多次触发了同一事件，那么在函数执行一次后，在一个限期内不再执行
   */
  animateToThrottle(fn: Callback<void>, delay: number) {
    if (this.throttleStatus) {
      // 性能知识点：播放动画时，系统需要在一个刷新周期内完成动画变化曲线的计算，完成组件布局绘制等操作。建议使用系统提供的动画接口，只需设置曲线类型、终点位置、时长等信息，就能够满足常用的动画功能，减少UI主线程的负载。参考资料：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-apis-0000001820879805
      animateTo({
        duration: this.duration, curve: Curve.FastOutLinearIn
      }, fn)
      this.throttleStatus = false;
      setTimeout(() => {
        this.throttleStatus = true;
      }, delay)
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getTitleExpansion(): void {
  TitleExpansion();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.EXPAND_TITLE, wrapBuilder(getTitleExpansion));