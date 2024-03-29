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
import display from '@ohos.display';
import { CONFIGURATION, STRINGCONFIGURATION } from '../common/Constants';

/**
 * 1.在`Stack`组件中布局三个`ReaderPage`，`midPage`位于中间可以根据this.offsetX实时translate自己的位置。
 * 当this.offsetX<0时,translate的x为this.offsetX，midPage向左移动，显现`rightPage`。
 * 当this.offsetX>0,translate的x为0，midPage不动，`leftPage`向右滑动。
 *
 * 2.将滑动翻页的动画和点击翻页的动画封装在一个闭包中，由`isClick`来判断是点击翻页还是滑动翻页，
 * 由`isLeft`来判断点击翻页中是向左翻页还是向右翻页。确定翻页时将this.offsetX设置为this.screenW
 * 或者-this.screenW。translate移动加上动画效果就会产生覆盖翻页的效果。
 *
 * 3.当动画结束时由于翻页会让`this.currentPageNum`加一或减一，根据相应的页数来加载三个`content`相应的内容。
 */

@Component
export struct CoverFlipPage {
  @State leftPageContent: string = "";
  @State midPageContent: string = "";
  @State rightPageContent: string = "";
  @State offsetX: number = 0;
  @Link isMenuViewVisible: boolean;
  @Link isCommentVisible: boolean;
  @Link currentPageNum: number;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });
  private screenW: number = px2vp(display.getDefaultDisplaySync().width);

  aboutToAppear() {
    /**
     * 请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
     * 请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的末尾形成新的数据源。
     */
    this.simulatePageContent();
    if (this.screenW > CONFIGURATION.WINDOWWIDTH) {
      this.screenW = this.screenW / 2;
    }
  }

  // 模拟书页内容,可以在此进行网络请求。
  simulatePageContent() {
    this.leftPageContent = STRINGCONFIGURATION.PAGEFLIPRESOURCE + (this.currentPageNum - CONFIGURATION.PAGEFLIPPAGECOUNT).toString();
    this.midPageContent = STRINGCONFIGURATION.PAGEFLIPRESOURCE + (this.currentPageNum).toString();
    this.rightPageContent = STRINGCONFIGURATION.PAGEFLIPRESOURCE + (this.currentPageNum + CONFIGURATION.PAGEFLIPPAGECOUNT).toString();
  }

  private clickAnimateTo(isClick: boolean, isLeft?: boolean) {
    animateTo({
      duration: CONFIGURATION.PAGEFLIPTOASTDURATION,
      curve: Curve.EaseOut,
      onFinish: () => {
        /** TODO: 知识点：this.currentPageNum加一或者减一后修改组件的内容。
         * 右滑：1. 恢复页面原始状态 2. 修改组件的内容为 page1 = content1-1， page2 = content2-1，page3 = content3-1
         * 左滑：1. 恢复页面原始状态 2. 修改组件的内容为 page1 = content1+1， page2 = content2+1，page3 = content3+1
         */
        if (this.offsetX > CONFIGURATION.PAGEFLIPRIGHTFLIPOFFSETX && this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGESTART) {
          this.currentPageNum -= CONFIGURATION.PAGEFLIPPAGECOUNT;
        } else if (this.offsetX < CONFIGURATION.PAGEFLIPLEFTFLIPOFFSETX && this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGEEND) {
          this.currentPageNum += CONFIGURATION.PAGEFLIPPAGECOUNT;
        }
        this.offsetX = CONFIGURATION.PAGEFLIPZERO;
        this.simulatePageContent();
      }
    }, () => {
      if (isClick) { // 是否为点击翻页
        if (isLeft) {
          this.offsetX = this.screenW; // TODO: 知识点：右滑距离变为一个屏幕宽度，ReaderPage就会向右移动一个屏幕宽度，加上动画，形成了覆盖翻页的效果。
        } else {
          this.offsetX = -this.screenW; // TODO: 知识点：左滑距离变为一个屏幕宽度，ReaderPage就会向左移动一个屏幕宽度，加上动画，形成了覆盖翻页的效果。
        }
      } else { // 滑动翻页
        if (this.offsetX > CONFIGURATION.PAGEFLIPRIGHTFLIPOFFSETX && this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGESTART) {
          this.offsetX = this.screenW;
        } else if (this.offsetX < CONFIGURATION.PAGEFLIPLEFTFLIPOFFSETX && this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGEEND) {
          this.offsetX = -this.screenW;
        } else {
          this.offsetX = CONFIGURATION.PAGEFLIPZERO; // 当位于第一页和末尾页，移动距离设为0，无法翻页。
        }
      }
    });
  }

  build() {
    Stack() {
      ReaderPage({ content: this.rightPageContent }); // 当midPage向左滑时，rightPage开始显现。
      ReaderPage({ content: this.midPageContent })
        /** TODO: 知识点：
         * 当this.offsetX<0时,translate的x为this.offsetX，midPage向左移动，显现rightPage。
         * 当this.offsetX>0,translate的x为CONFIGURATION.PAGEFLIPZERO，midPage不动，leftPage向右滑动。
         */
        .translate({
          x: this.offsetX >= CONFIGURATION.PAGEFLIPZERO ? CONFIGURATION.PAGEFLIPZERO : this.offsetX,
          y: CONFIGURATION.PAGEFLIPZERO,
          z: CONFIGURATION.PAGEFLIPZERO
        })
        .width(this.screenW);
      ReaderPage({ content: this.leftPageContent })
        // TODO: 知识点：在midPage的左边，当向右滑时，跟随this.offsetX向右滑动。
        .translate({
          x: -this.screenW + this.offsetX
        });
    }
    .gesture(
      PanGesture(this.panOption)
        // TODO: 性能知识点: 该函数是系统高频回调函数，避免在函数中进行冗余或耗时操作，例如应该减少或避免在函数打印日志，会有较大的性能损耗。
        .onActionUpdate((event?: GestureEvent) => {
          if (!event) {
            return;
          }
          this.offsetX = event.offsetX;
        })
        .onActionEnd(() => {
          this.clickAnimateTo(false);
        })
    )
    .onClick((event?: ClickEvent) => {
      if (event) {
        if (event.x > this.screenW / CONFIGURATION.PAGEFLIPTHREE * CONFIGURATION.PAGEFLIPTWO) { // 点击屏幕左侧1/3，页面向左翻页；点击中间区域，弹出菜单；点击屏幕右侧1/3，页面向右翻页。
          if (this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGEEND) {
            this.clickAnimateTo(true, false);
          }
        } else if (event.x > this.screenW / CONFIGURATION.PAGEFLIPTHREE) {
          if (this.isMenuViewVisible) {
            this.isMenuViewVisible = false;
            this.isCommentVisible = false;
          } else {
            this.isMenuViewVisible = true;
            this.isCommentVisible = true;
          }
        } else {
          // 向左翻页
          if (this.currentPageNum !== CONFIGURATION.PAGEFLIPPAGESTART) {
            this.clickAnimateTo(true, true);
          }
        }
      }
    })
  }
}

@Component
struct ReaderPage {
  @Prop content: string = "";

  build() {
    Text($r(this.content))
      .width($r('app.string.pageflip_full_size'))
      .height($r('app.string.pageflip_full_size'))
      .fontSize($r('app.integer.flippage_text_fontsize'))
      .align(Alignment.TopStart)
      .backgroundColor($r('app.color.pageflip_swiper_backgroundcolor'))
      .padding({
        top: $r('app.integer.flippage_padding_large'),
        left: $r('app.integer.flippage_margin_middle_up'),
        right: $r('app.integer.flippage_margin_middle')
      })
      .lineHeight($r('app.integer.flippage_text_lineheight'))
        // 扩展至所有非安全区域
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
