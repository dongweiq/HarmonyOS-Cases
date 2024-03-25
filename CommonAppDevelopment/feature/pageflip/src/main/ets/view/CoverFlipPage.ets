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
import promptAction from '@ohos.promptAction';

@Component
export struct CoverFlipPage {
  @State content1: string = ""
  @State content2: string = ""
  @State content3: string = ""
  @State offsetX: number = 0
  @Link isMenuViewVisible: boolean;
  @Link isCommentVisible: boolean;
  @Link currentPageNum: number;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right })
  private screenW: number = px2vp(display.getDefaultDisplaySync().width)
  readonly pageFlip_toast_duration = 300;
  readonly pageFlip_content_resource = 'app.string.pageflip_content';
  readonly pageFlip_page_count = 1;
  readonly pageFlip_page_start = 1;
  readonly pageFlip_page_three = 3;
  readonly pageFlip_page_eleven = 11;
  readonly pageFlip_page_end = 14;
  readonly pageFlip_right_flip_offsetX = 20;
  readonly pageFlip_left_flip_offsetX = -20;
  readonly pageFlip_zero = 0;
  readonly pageFlip_three = 3;
  readonly pageFlip_two = 2;

  aboutToAppear() {
    // 请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
    // 请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的末尾形成新的数据源。
    this.simulatePageContent();
  }

  /// 模拟书页内容,可以在此进行网络请求。
  simulatePageContent() {
    this.content1 = this.pageFlip_content_resource + (this.currentPageNum - this.pageFlip_page_count);
    this.content2 = this.pageFlip_content_resource + (this.currentPageNum);
    this.content3 = this.pageFlip_content_resource + (this.currentPageNum + this.pageFlip_page_count);
  }

  private clickAnimateTo(isClick: boolean, isLeft?: boolean) {
    animateTo({
      duration: this.pageFlip_toast_duration,
      curve: Curve.EaseOut,
      onFinish: () => {
        // 右滑：1. 恢复页面原始状态 2. 修改组件的内容为 page1 = content1-1， page2 = content2-1，page3 = content3-1
        // 左滑：1. 恢复页面原始状态 2. 修改组件的内容为 page1 = content1+1， page2 = content2+1，page3 = content3+1
        if (this.offsetX > this.pageFlip_right_flip_offsetX && this.currentPageNum !== this.pageFlip_page_start) {
          this.currentPageNum -= this.pageFlip_page_count;
        } else if (this.offsetX < this.pageFlip_left_flip_offsetX && this.currentPageNum !== this.pageFlip_page_end) {
          this.currentPageNum += this.pageFlip_page_count;
        }
        /**
         * if (this.offsetX > this.pageFlip_zero && this.currentPageNum === this.pageFlip_page_three) {
         *   请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
         * }
         */
        /**
         * if (this.offsetX < this.pageFlip_zero && this.currentPageNum === this.pageFlip_page_eleven) {
         *   请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的结尾形成新的数据源。
         * }
         */
        this.offsetX = this.pageFlip_zero;
        this.simulatePageContent();
      }
    }, () => {
      if (isClick) { // 是否为点击翻页
        if (isLeft) {
          this.offsetX = this.screenW; // 右滑距离变为一个屏幕宽度，ReaderPage就会向右移动一个屏幕宽度，加上动画，形成了覆盖翻页的效果。
        } else {
          this.offsetX = -this.screenW; // 左滑距离变为一个屏幕宽度，ReaderPage就会向左移动一个屏幕宽度，加上动画，形成了覆盖翻页的效果。
        }
      } else { // 滑动翻页
        if (this.offsetX > this.pageFlip_right_flip_offsetX && this.currentPageNum !== this.pageFlip_page_start) {
          this.offsetX = this.screenW;
        } else if (this.offsetX < this.pageFlip_left_flip_offsetX && this.currentPageNum !== this.pageFlip_page_end) {
          this.offsetX = -this.screenW;
        } else {
          this.offsetX = this.pageFlip_zero; // 当位于第一页和末尾页，移动距离设为0，无法翻页。
        }
      }
    });
  }

  build() {
    Stack() {
      ReaderPage({ content: this.content3 }); // 当page2向左滑时，page3开始显现。
      ReaderPage({ content: this.content2 }) // 当this.offsetX<0时,translate的x为this.offsetX，page2向左移动，显现page3。当this.offsetX>0,translate的x为this.pageFlip_zero，page2不动，page1向右滑动。
        .translate({
          x: this.offsetX >= this.pageFlip_zero ? this.pageFlip_zero : this.offsetX,
          y: this.pageFlip_zero,
          z: this.pageFlip_zero
        })
        .width(this.screenW);
      ReaderPage({ content: this.content1 }) // 在page2的左边，当向右滑时，跟随this.offsetX向右滑动。
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
          // offset > 0，右滑显示page1；offset < 0，左滑显示page3
        })
        .onActionEnd(() => {
          this.clickAnimateTo(false);
        })
    )
    .onClick((event?: ClickEvent) => {
      if (event) {
        if (event.x > this.screenW / this.pageFlip_three * this.pageFlip_two) { // 点击屏幕左侧1/3，页面向左翻页；点击中间区域，弹出菜单；点击屏幕右侧1/3，页面向右翻页。
          if (this.currentPageNum !== this.pageFlip_page_end) {
            this.clickAnimateTo(true, false);
          }
        } else if (event.x > this.screenW / this.pageFlip_three) {
          if (this.isMenuViewVisible) {
            this.isMenuViewVisible = false;
            this.isCommentVisible = false;
          } else {
            this.isMenuViewVisible = true;
            this.isCommentVisible = true;
          }
        } else {
          //向左翻页
          if (this.currentPageNum !== this.pageFlip_page_start) {
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
      .padding({ top: $r('app.integer.flippage_padding_40'),left:$r('app.integer.flippage_margin_20'),right:$r('app.integer.flippage_margin_20') })
  }
}
