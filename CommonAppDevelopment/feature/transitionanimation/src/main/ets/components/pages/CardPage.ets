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
import { CardData } from '../../model/CardData'
@Component
export struct CardPage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Prop cardData: CardData;
  onCardReadyExpand?: Function;
  onBack?: Function;
  onAnimationFinish?: ()=> void;
  @Prop @Watch('onExpandCardIdChange') expandCardId?: number = -1;
  @State isCardExpand:boolean = false;

  onExpandCardIdChange() {
    animateTo({duration:200, onFinish: this.onAnimationFinish}, ()=>{
      this.isCardExpand = this.expandCardId === this.cardData.id
    })
  }

  @Builder
  topBar() {
    if (this.isCardExpand) {
      Row() {
        Column(){
          Image($r('app.media.left'))
            .width('100%')
        }
        .width(20)
        .clip(true)
        .margin({left: 10})
        .onClick(()=>{
          if (this.onBack) {
            this.onBack();
          }
        })
        Column() {
          Image(this.cardData.avatorSrc)
            .width('100%')
        }
        .margin({left: 10})
        .width(26)
        .clip(true)
        Text(this.cardData.authorName)
          .padding({left: 10})
      }
      .margin({
        top: 0,
        bottom: 10
      })
      .height(40)
      .alignSelf(ItemAlign.Start)
    }
  }

  @Builder
  contentImage() {
    Image(this.cardData.imageSrc)
      .width('100%')
      .onComplete(() => {
        if (this.onCardReadyExpand) {
          this.onCardReadyExpand();
        }
      })
  }

  @Builder
  title() {
    Text(this.cardData.title).textAlign(TextAlign.Start)
      .fontWeight(this.isCardExpand ? FontWeight.Bold : FontWeight.Normal)
      .margin({
        left: 10,
        top: 10,
        bottom: 10
      })
  }

  @Builder
  bottomContent() {
    Column() {
      if (!this.isCardExpand) {
        Row() {
          Row() {
            Image(this.cardData.avatorSrc)
          }
          .width(26)
          .height(26)
          .clip(true)
          Text(this.cardData.authorName)
            .align(Alignment.Start)
            .fontColor(Color.Grey)
            .fontSize(12)
            .lineHeight(26)
            .padding({ left: 8 })
        }
        .margin({
          left: 10,
          top: 0,
          bottom: 10
        })
      }
      else {
        Column(){
          Text(this.cardData.content)
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .padding({left:7, right:7})
        .width('100%')
        Button('父页面（点击进入子页面）')
          .onClick(() => {
            this.pageInfos.pushPath({name: 'NewNavPage'}, true)
          })
          .width("60%")
          .margin({top:10, bottom: 40})
      }
    }
  }

  build() {
    List() {
      this.topBar();
      this.contentImage();
      this.title();
      this.bottomContent();
    }
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
    .clip(true)
  }
}