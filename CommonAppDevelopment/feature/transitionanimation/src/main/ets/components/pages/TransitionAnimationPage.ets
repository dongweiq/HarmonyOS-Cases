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
import { CardData } from '../../model/CardData';
import { CardPage } from './CardPage';
import { display } from '@kit.ArkUI';
import { WaterFlowDataSource } from '../../model/WaterFlowDataSource';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';


@Component
export struct TransitionAnimationPage {
  // 存储当前设备高度，用于计算详情页展开后高度
  @State currentDiaplayHeight: Length = 0;
  // 详情页是否显示标识
  @State isDetailPageShow: boolean = false;
  @State myOpacity: number = 1;
  @State myZIndex: number = 1;
  // 记录被点击的Card索引
  @State clickedCardIndex: number = -1;
  // 记录被点击的CardId
  @State expandCardId: number = -1;
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();

  aboutToAppear() {
    this.currentDiaplayHeight = display.getDefaultDisplaySync().height;
  }

  @Builder
  cardList() {
    Column({ space: 2 }) {
      WaterFlow() {
        LazyForEach(this.dataSource, (item: CardData, index) => {
          FlowItem() {
            CardPage({ cardData: item })
              .onClick(() => {
                this.clickedCardIndex = index;
              })
          }
          .onAppear(() => {
            // 即将触底时提前增加数据
            for (let i = 0; i < 8; i++) {
              let cardData = JSON.parse(JSON.stringify(this.dataSource.getData(Math.floor(Math.random() * 6)))) as CardData;
              cardData.id = Date.now();
              this.dataSource.addLastItem(cardData);
            }
          })
          .onAreaChange((oldValue, newValue) => {
            // 记录每个卡片点击时的位置尺寸数据，用于设置动画前后的数据
            this.dataSource.getData(index).cardArea = newValue;
          })
          .width('100%')
        })
      }
      .columnsTemplate(getContext().resourceManager.getStringSync($r('app.string.two_fr').id))
      .columnsGap(8)
      .rowsGap(8)
      .backgroundColor($r('app.color.water_flow_background_color'))
      .width('100%')
      .height('100%')
      .padding(8)
    }
    .zIndex(1)
  }

  @Builder
  detailPage() {
    Column() {
      if (this.clickedCardIndex > -1) {
        CardPage({
          cardData: this.dataSource.getData(this.clickedCardIndex),
          expandCardId: this.expandCardId,
          onCardReadyExpand: () => {
            // Card中Image加载渲染完成时触发
            if (!this.isDetailPageShow) {
              animateTo({
                duration: 5, onFinish: () => {
                  this.expandCardId = this.dataSource.getData(this.clickedCardIndex).id;
                }
              }, () => {
                this.isDetailPageShow = true;
              })
            }
          },
          onBack: () => {
            this.expandCardId = -1;
          },
          onAnimationFinish: () => {
            // Card内动画结束时调用，用于重置状态
            if (this.expandCardId < 0) {
              this.clickedCardIndex = -1;
              this.isDetailPageShow = false;
            }
          }
        })
          .width(this.expandCardId > -1 ? '100%' : this.dataSource.getData(this.clickedCardIndex).cardArea.width)
          .height(this.expandCardId > -1 ? px2vp(this.currentDiaplayHeight as number) : this.dataSource.getData(this.clickedCardIndex)
            .cardArea
            .height)
          .position({
            x: this.expandCardId > -1 ? 0 : this.dataSource.getData(this.clickedCardIndex)
              .cardArea
              .position
              .x,
            y: this.expandCardId > -1 ? 0 : this.dataSource.getData(this.clickedCardIndex)
              .cardArea
              .position
              .y
          })
          .animation({ duration: 200 })
          .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(this.isDetailPageShow ? 2 : 0)
    .animation({ duration: 100 })
    .backgroundColor(Color.Transparent)
  }

  build() {
    Stack() {
      this.cardList();
      this.detailPage();
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getTransitionAnimationPageView(): void {
  TransitionAnimationPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.TRANSITION_ANIMATION, wrapBuilder(getTransitionAnimationPageView));