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

/**
 * 实现步骤
 * 1.
 * 2.
 */

import Constants from '../../utils/Constants';
import CardComponent from '../viewmodel/CardViewModel';
import { CardsSource, CardInfo } from '../model/CardModel';
import { display } from '@kit.ArkUI';
import { logger } from '@ohos/base';

const TAG: string = '[CardSwiper]:';

@Component
export struct CardSwiperAnimation {
  // 卡片数据源
  private data: CardsSource = new CardsSource([]);
  // 卡片数据列表
  @State private cardsList: CardInfo[] = [];
  // 卡片偏移度列表
  @State private cardsOffset: number[] = [];
  // 屏幕宽度
  private displayWidth: number = 0;
  // Swiper 两侧的偏移量
  private swiperMargin: number = Constants.SWIPER_MARGIN;
  // Swiper 当前索引值
  @State private currentSwiperIndex: number = 0;

  aboutToAppear(): void {
    // 获取屏幕大小，用于后续计算卡片的偏移量
    let displayData: display.Display = display.getDefaultDisplaySync();
    this.displayWidth = px2vp(displayData.width);
    logger.info(TAG, `Display width ${this.displayWidth}`);
    // 添加卡片数据，来自预置用例，可根据实际情况自行修改。同时初始化偏移量列表。
    Constants.CARD_TEST_CASE.forEach((item) => {
      this.cardsList.push(item);
      this.cardsOffset.push(0);
    })
    // 初始化懒加载列表
    this.data = new CardsSource(this.cardsList);
    // 计算当前卡片及关联卡片的偏移量
    this.calculateOffset(0);
  }

  build() {
    Column() {
      Swiper() {
        LazyForEach(this.data, (item: CardInfo, index: number) => {
          CardComponent({
            cardInfo: item,
            cardOffset: this.cardsOffset[index],
            cardIndex: index,
            showingCard: this.currentSwiperIndex
          })
        })
      }
      .index($$this.currentSwiperIndex)
      .loop(false)
      .prevMargin(this.swiperMargin)
      .nextMargin(this.swiperMargin)
      .onChange((index) => {
        logger.info(TAG, `Target index: ${index}`);
        this.calculateOffset(index);
      })
      .onGestureSwipe((index, event) => {
        let currentOffset = event.currentOffset;
        // 获取当前卡片（居中）的原始偏移量
        let maxOffset = this.getMaxOffset(index) / 2;
        // 实时维护卡片的偏移量列表，做到跟手效果
        if (currentOffset < 0) {
          // 向左偏移
          /*
           * 此处计算原理为：按照比例设置卡片的偏移量。
           * 当前卡片居中，向左滑动后将在左边，此时卡片偏移量即为 maxOffset * 2（因为向右对齐）。
           * 所以手指能够滑动的最大距离（this.displayWidth）所带来的偏移量即为 maxOffset。
           * 易得公式：卡片实时偏移量 = （手指滑动长度 / 屏幕宽度） * 卡片最大可偏移量 + 当前偏移量。
           * 之后的计算原理相同，将不再赘述。
           */
          this.cardsOffset[index] = (-currentOffset / this.displayWidth) * maxOffset + maxOffset;
          if (this.isIndexValid(index + 1)) {
            // 下一个卡片的偏移量
            let maxOffset = this.getMaxOffset(index + 1) / 2;
            this.cardsOffset[index + 1] = (-currentOffset / this.displayWidth) * maxOffset;
          }
          if (this.isIndexValid(index - 1)) {
            // 上一个卡片的偏移量
            let maxOffset = this.getMaxOffset(index - 1) / 2;
            this.cardsOffset[index - 1] = (currentOffset / this.displayWidth) * maxOffset + 2 * maxOffset;
          }
        } else if (currentOffset > 0) {
          // 向右滑动
          this.cardsOffset[index] = (currentOffset / this.displayWidth) * maxOffset + maxOffset;
          if (this.isIndexValid(index + 1)) {
            let maxOffset = this.getMaxOffset(index + 1) / 2;
            this.cardsOffset[index + 1] = (currentOffset / this.displayWidth) * maxOffset;
          }
          if (this.isIndexValid(index - 1)) {
            let maxOffset = this.getMaxOffset(index -1) / 2;
            this.cardsOffset[index - 1] = (-currentOffset / this.displayWidth) * maxOffset + 2 * maxOffset;
          }
        }
      })
      .onAnimationStart((_, targetIndex) => {
        this.calculateOffset(targetIndex);
      })
      .height($r('app.integer.swiper_height'))
    }
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 计算卡片偏移量，并维护偏移量列表。
   * @param targetIndex { number } swiper target card's index.
   */
  calculateOffset(target: number) {
    let left = target - 1;
    let right = target + 1;

    // 计算上一张卡片的偏移值
    if (this.isIndexValid(left)) {
      this.cardsOffset[left] = this.getMaxOffset(left);
    }
    // 计算当前卡片的偏移值
    if (this.isIndexValid(target)) {
      this.cardsOffset[target] = this.getMaxOffset(target) / 2;
    }
    // 下一张片的偏移值
    if (this.isIndexValid(right)) {
      this.cardsOffset[right] = 0;
    }
  }

  /**
   * 检查卡片索引值的合法性。
   * @param index {number} input card's index.
   * @returns true or false.
   */
  isIndexValid(index: number): boolean {
    return index >= 0 && index < this.cardsList.length;
  }

  /**
   * 计算指定卡片的最大偏移量。
   * @param index {number} target card's index.
   * @returns offset value.
   */
  getMaxOffset(index: number): number {
    /*
     * 这里的偏移量指相对容器左侧的值。
     * 计算公式为：屏幕宽度 - Swiper两侧突出的偏移量 - 卡片自身的宽度。
     * 此值即为卡片可偏移的最大值，也就是卡片右对齐的状态值。
     * 如果居中，则将最大偏移量 / 2。
     */
    return this.displayWidth - this.cardsList[index].width - 2 * this.swiperMargin;
  }
}