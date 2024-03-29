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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

import { SwiperData } from '../model/SwiperData';

/**
 * 主页轮播图组件
 * 通过stack组件堆叠图片，实现多层级效果，配合手势滑动和显式动画实现切换的动画效果。同时通过改变数据中间值currentIndex来改变组件zIndex层级和高度来实现切换的效果。该场景多用于购物、资讯类应用。
 */
@Component
export struct SwiperComponent {
  @Consume('pageStack') pageStack: NavPathStack;
  @State currentIndex: number = 0;
  @State swiperData: SwiperData[] = [
    new SwiperData($r("app.media.mp_chart"), 'MpChart图表实现案例', RouterInfo.BAR_CHAT),
    new SwiperData($r("app.media.lottie"), 'Lottie动画', RouterInfo.LOTTIE_VIEW),
    new SwiperData($r("app.media.component_tack"), '组件堆叠', RouterInfo.COMPONENT_TACK),
  ];
  private halfCount: number = Math.floor(3 / 2);
  private manualSlidingDuration: number = 800;
  private automaticSlidingDuration: number = 300;
  private automaticSwitchTime: number = 5000;
  @State swiperInterval: number = 0

  aboutToAppear(): void {
    this.currentIndex = this.halfCount;
  }

  /**
   * 获取图片系数
   * @param index：索引值
   * @returns
   */
  getImgCoefficients(index: number): number {
    const coefficient: number = this.currentIndex - index; // 计算图片左右位置
    const tempCoefficient: number = Math.abs(coefficient);
    if (tempCoefficient <= this.halfCount) {
      return coefficient;
    }
    const dataLength: number = this.swiperData.length;
    let tempOffset: number = dataLength - tempCoefficient; // 判断图片位于左右层级位置
    if (tempOffset <= this.halfCount) {
      if (coefficient > 0) {
        return -tempOffset;
      }
      return tempOffset;
    }
    return 0;
  }

  /**
   * 计算偏移量
   * @param index：索引值
   * @returns
   */
  getOffSetX(index: number): number {
    const offsetIndex: number = this.getImgCoefficients(index);
    const tempOffset: number = Math.abs(offsetIndex);
    let offsetX: number = 0;
    if (tempOffset === 1) {
      // 根据图片层级系数来决定左右偏移量
      offsetX = -35 * offsetIndex;
    }
    return offsetX;
  }

  // 性能：显式动画(https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-explicit-animation-0000001478341181-V2)
  startAnimation(isLeft: boolean, duration: number): void {
    animateTo({
      duration: duration,
    }, () => {
      const dataLength: number = this.swiperData.length;
      const tempIndex: number = isLeft ? this.currentIndex + 1 : this.currentIndex - 1 + dataLength;
      this.currentIndex = tempIndex % dataLength;
    })
  }

  build() {
    Column() {
      Stack() {
        // LazyForEach必须在容器组件内使用，仅有List、Grid、Swiper以及WaterFlow组件支持数据懒加载，其他组件仍然是一次性加载所有的数据。
        ForEach(this.swiperData, (item: SwiperData, index: number) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(item.imageSrc)
              .objectFit(ImageFit.Cover)
              .width('100%')
              .height('100%')
              .borderRadius($r('app.string.main_page_top_borderRadius'))
            // 轮播图底部蒙层
            Stack() {
              Column() {
              }
              .width('100%')
              .height('100%')
              .backgroundColor(Color.Black)
              .opacity(0.3)
              .borderRadius({
                topLeft: 0,
                topRight: 0,
                bottomLeft: $r('app.string.main_page_top_borderRadius'),
                bottomRight: $r('app.string.main_page_top_borderRadius')
              })

              Text(item.name)
                .width('100%')
                .height('100%')
                .fontSize(16)
                .fontColor(Color.White)
                .textAlign(TextAlign.Start)
                .padding($r('app.string.main_page_padding5'))
            }
            .height($r('app.string.bottom_title_height'))
          }
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .offset({
            x: this.getOffSetX(index),
            y: 0
          })
          .blur(index !== this.currentIndex ? 12 : 0)
          // TODO: 知识点:通过animateTo实现动画并且同时改变currentIndex数据中间值来判断组件zIndex实现切换动画
          .zIndex(index !== this.currentIndex && this.getImgCoefficients(index) === 0 ?
            0 : 2 - Math.abs(this.getImgCoefficients(index)))
          .width($r('app.string.swiper_stack_width'))
          .height(index !== this.currentIndex ? $r('app.string.swiper_stack_height1') : $r('app.string.swiper_stack_height2'))
          .onClick(() => {
            // 点击轮播图Item时，根据点击的模块信息，将页面放入路由栈
            DynamicsRouter.push(item.routerInfo, item.param);
          })
        })
      }
      .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
        if (isVisible && currentRatio >= 1.0) {
          this.swiperInterval = setInterval(() => {
            this.startAnimation(true, this.manualSlidingDuration);
          }, this.automaticSwitchTime)
        }

        if (!isVisible && currentRatio <= 0.0) {
          clearInterval(this.swiperInterval)
        }
      })
      .height($r('app.string.main_page_swiper_height'))
      .width('100%')
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart((event: GestureEvent) => {
            this.startAnimation(event.offsetX < 0, this.automaticSlidingDuration);
          })
          .onActionEnd(() => {
            clearInterval(this.swiperInterval)
          })
      )
      .alignContent(Alignment.Center)
      .padding({
        left: $r('app.string.main_page_padding2'),
        right: $r('app.string.main_page_padding2'),
        top: $r('app.string.main_page_padding2')
      })

      Row({ space: 10 }) {
        ForEach(this.swiperData, (item: SwiperData, index: number) => {
          Circle({ width: 8, height: 8 })
            .fill(index !== this.currentIndex ? Color.Black : Color.Red)
            .fillOpacity(0.6)
        })
      }
      .margin({ top: 12 })
    }
    .width('100%')
  }
}
