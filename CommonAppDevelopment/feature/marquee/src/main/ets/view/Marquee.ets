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

import { FunctionDescription, logger } from '@ohos/base';
import { TripDataType } from '../model/DataType';
import Constants from '../model/Constants';
import { TripDataSource } from '../model/DataSource';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * 本示例介绍了文本宽度过宽时，则实现跑马灯效果(文本首尾相连循环滚动并且显示在同一可视区，以及每循环一次之后会停滞一段时间后再滚动)。
 * 由于ArkUI中的Marquee组件无法实现文本接替并显示在同一可视区的效果，它只能等文本完全消失在可视区之后，才会再次显示在可视区，因此需要使用以下
 * 方案：首先将Text组件外层包裹一层Scroll组件，Scroll组件设置一定的宽度值。页面进来执行scrollAnimation函数。文本宽度超过Scroll组件
 * 宽度的时候，将Text文本向左偏移，偏移一段距离之后，可视区显示下一段文本。其中偏移过程使用animateTo来实现。每循环滚动一次停滞操作
 * 通过使用计时器setTimeout来实现，1s之后，初始化偏移量，再次执行动画。
 */
@Preview
@Component
export struct MarqueeView {
  build() {
    Column() {
      // 场景介绍组件
      FunctionDescription({
        title: $r('app.string.marquee_title'),
        content: $r('app.string.marquee_content')
      })
      // 行程信息组件
      TripView()
    }
    .width('100%')
    .height('100%')
    .padding($r('app.string.ohos_id_card_padding_start'))
    .linearGradient({
      angle: Constants.ANGLE,
      colors: [[$r('app.color.marquee_bg_color1'), 0], [$r('app.color.marquee_bg_color2'), 1]]
    })
  }
}

@Component
struct TripView {
  @State tripData: TripDataSource = new TripDataSource();

  build() {
    Column() {
      Text($r('app.string.my_trip'))
        .width('100%')
        .fontSize($r('app.string.ohos_id_text_size_headline'))
        .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
      // 性能：动态加载数据场景可以使用LazyForEach遍历数据。https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
      LazyForEach(this.tripData, (item: TripDataType) => {
        // 单个行程信息组件
        TripMessage({
          tripDataItem: item
        })
      }, (item: TripDataType) => JSON.stringify(item))
    }
  }
}

@Component
struct TripMessage {
  // 动画延迟时间
  @State delay: number = 0;
  // 初始化文本偏移量
  @State ticketCheckTextOffset: number = 0;
  // 初始化文本组件所占的宽度
  @State ticketCheckTextWidth: number = 0;
  // 初始化Scroll组件所占的宽度
  @State ticketCheckScrollWidth: number = 0;
  // 行程信息数据
  private tripDataItem: TripDataType = {} as TripDataType;

  // 通用样式函数
  @Styles
  commonStyles(){
    .width('100%')
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
  }

  // 文本滚动函数
  scrollAnimation() {
    // 文本宽度小于Scroll组件宽度，不执行滚动操作
    if (this.ticketCheckTextWidth < this.ticketCheckScrollWidth) {
      return;
    }
    /**
     * 文本向左偏移动画
     *
     * @param duration:动画总时长
     * @param curve:动画曲线
     * @param delay:延迟时间
     * @param onFinish:完成回调函数
     * 性能：播放动画时，系统需要在一个刷新周期内完成动画变化曲线的计算，完成组件布局绘制等操作。建议使用系统提供的动画接口，
     * 只需设置曲线类型、终点位置、时长等信息，就能够满足常用的动画功能，减少UI主线程的负载。
     * 参考资料：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-apis-0000001820879805
     */
    animateTo({
      duration: Constants.ANIMATION_DURATION,
      curve: Curve.Linear,
      delay: this.delay,
      onFinish: () => {
        // TODO：知识点：动画完成时，添加定时器，1s之后重新执行动画函数，达到停滞操作。
        setTimeout(() => {
          // 初始化文本偏移量
          this.ticketCheckTextOffset = 0;
          // 执行动画函数
          this.scrollAnimation();
        }, Constants.DELAY_TIME)
      }
    }, () => {
      // 文本偏离量
      this.ticketCheckTextOffset = -(this.ticketCheckTextWidth + Constants.BLANK_SPACE)
    })
  }

  build() {
    Column() {
      Row() {
        Text(this.tripDataItem.trainNumber)
        Text(this.tripDataItem.wholeCourse)
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)


      Row() {
        Text(this.tripDataItem.startingTime)
          .fontSize($r('sys.float.ohos_id_text_size_headline6'))
          .width(100)
          .textAlign(TextAlign.Start)
        Text($r('app.string.plan_text'))
          .fontColor($r('app.color.ohos_id_color_emphasize'))
          .width(80)
          .height(24)
          .textAlign(TextAlign.Center)
          .border({
            width: 1,
            radius: $r('app.string.ohos_id_corner_radius_default_m'),
            color: $r('app.color.ohos_id_color_emphasize')
          })
        Text(this.tripDataItem.endingTime)
          .fontSize($r('sys.float.ohos_id_text_size_headline6'))
          .width(100)
          .textAlign(TextAlign.End)

      }.commonStyles()
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.tripDataItem.origin)
        Text(this.tripDataItem.timeDifference)
        Text(this.tripDataItem.destination)
      }.commonStyles()
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Text($r('app.string.ticket_entrance'))
            .padding({ right: 4 })
          // TODO：知识点：使用Scroll组件和文本内容组件结合来判断文本宽度过宽时执行文本滚动，否则不执行
          Scroll() {
            Row() {
              Text(this.tripDataItem.ticketEntrance)
                .onAreaChange((oldValue, newValue) => {
                  logger.info(`TextArea oldValue:${JSON.stringify(oldValue)},newValue:${JSON.stringify(newValue)}`);
                  // 获取当前文本内容宽度
                  this.ticketCheckTextWidth = Number(newValue.width);
                })
              // TODO：知识点：文本宽度大于Scroll组件宽度时显示。在偏移过程中可实现文本接替并显示在同一显示区的效果
              if (this.ticketCheckTextWidth >= this.ticketCheckScrollWidth) {
                Blank()
                  .width(Constants.BLANK_SPACE)
                Text(this.tripDataItem.ticketEntrance)
              }
            }.offset({ x: this.ticketCheckTextOffset })
          }
          .width($r('app.string.scroll_width'))
          .align(Alignment.Start)
          .enableScrollInteraction(false)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .onAreaChange((oldValue, newValue) => {
            logger.info(`scrollArea oldValue:${JSON.stringify(oldValue)},newValue:${JSON.stringify(newValue)}`);
            // 获取当前Scroll组件宽度
            this.ticketCheckScrollWidth = Number(newValue.width);
          })
        }
        .width('46%')

        Blank()
        Row() {
          Text($r('app.string.vehicle_model'))
          Text(this.tripDataItem.vehicleModel)
        }
      }.commonStyles()
    }
    .width('100%')
    .padding($r('app.string.ohos_id_card_padding_start'))
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
    .backgroundColor(Color.White)
    .onAppear(() => {
      // 执行动画函数
      this.scrollAnimation();
    })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getMarqueeView(): void {
  MarqueeView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.MARQUEE,wrapBuilder(getMarqueeView));