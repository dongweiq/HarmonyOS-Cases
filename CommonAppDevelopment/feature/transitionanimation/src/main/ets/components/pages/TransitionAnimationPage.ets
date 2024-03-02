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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';
import { NewNavPage } from './NewNavPage';


@Component
export struct TransitionAnimationPage {
  @State currentDiaplayHeight: Length = 0;
  @State isDetailPageShow: boolean = false;
  @State myOpacity: number = 1;
  @State myZIndex: number = 1;
  @State clickedCardIndex: number = -1;
  @State expandCardId: number = -1;
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  aboutToAppear() {
    this.currentDiaplayHeight = display.getDefaultDisplaySync().height;
  }

  @Builder
  pageMap(name: string) {
    if (name === 'NewNavPage') {
      NewNavPage()
    }
  }

  @Builder
  CardList() {
    Column({ space: 2 }) {
      WaterFlow() {
        LazyForEach(this.dataSource, (item: CardData, index) => {
          FlowItem() {
            CardPage({cardData: item})
              .onClick(() => {
                this.clickedCardIndex = index;
              })
          }
          .onAppear(() => {
            // 即将触底时提前增加数据
            for (let i = 0; i < 8; i++) {
              let cardData = JSON.parse(JSON.stringify(this.dataSource.getData(Math.floor(Math.random()*6)))) as CardData;
              cardData.id = Date.now();
              this.dataSource.addLastItem(cardData)
            }
          })
          .onAreaChange((oldValue, newValue) => {
            this.dataSource.getData(index).cardArea = newValue;
          })
          .width('100%')
        })
      }
      .columnsTemplate("1fr 1fr")
      .columnsGap(8)
      .rowsGap(8)
      .backgroundColor('#cccccc')
      .width('100%')
      .height('100%')
      .padding(8)
    }
    .zIndex(1)
  }

  @Builder
  DetailPage() {
    Column() {
      if (this.clickedCardIndex > -1) {
        CardPage({
          cardData: this.dataSource.getData(this.clickedCardIndex),
          expandCardId: this.expandCardId,
          onCardReadyExpand: () => {
            if (!this.isDetailPageShow) {
              animateTo({duration: 5,onFinish: ()=>{
                this.expandCardId = this.dataSource.getData(this.clickedCardIndex).id;
              }}, ()=> {
                this.isDetailPageShow = true
              })
            }
          },
          onBack: () => {
            this.expandCardId = -1;
          },
          onAnimationFinish: () => {
            if (this.expandCardId < 0) {
              this.clickedCardIndex = -1;
              this.isDetailPageShow = false;
            }
          }
        })
          .width(this.expandCardId > -1 ? '100%' : this.dataSource.getData(this.clickedCardIndex).cardArea.width)
          .height(this.expandCardId > -1 ? px2vp( this.currentDiaplayHeight as number) : this.dataSource.getData(this.clickedCardIndex).cardArea.height)
          .position({
            x: this.expandCardId > -1 ? 0 : this.dataSource.getData(this.clickedCardIndex).cardArea.position.x,
            y: this.expandCardId > -1 ? 0 : this.dataSource.getData(this.clickedCardIndex).cardArea.position.y
          })
          .animation({duration: 200})
          .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(this.isDetailPageShow ? 2 : 0)
    .animation({duration:100})
    .backgroundColor(Color.Transparent)
  }

  build() {
    Navigation(this.pageInfos) {
      Stack() {
        this.CardList();
        this.DetailPage();
      }
    }
    .hideTitleBar(true)
    .navDestination(this.pageMap)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getTransitionAnimationPageView(): void {
  TransitionAnimationPage()
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.TRANSITION_ANIMATION, wrapBuilder(getTransitionAnimationPageView));