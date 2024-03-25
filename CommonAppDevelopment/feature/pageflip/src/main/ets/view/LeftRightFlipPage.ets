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
import { BasicDataSource } from '../datasource/BasicDataSource';
import { display } from '@kit.ArkUI';

@Component
export struct LeftRightPlipPage {
  @Link isMenuViewVisible: boolean;
  @Link isCommentVisible: boolean;
  @Link currentPageNum: number;
  private swiperController: SwiperController = new SwiperController();
  private data: BasicDataSource = new BasicDataSource();
  private screenW: number = px2vp(display.getDefaultDisplaySync().width);
  readonly pageFlipPageCount = 1;
  readonly pageFlipCacheCount = 3;
  readonly pageFlipToastDuration = 300;
  readonly pageFlipThree = 3;
  readonly pageFlipTwo = 2;
  readonly pageFlipZero = 0;
  readonly pageFlipPageStart = 1;
  readonly pageFlipPageEnd = 4;
  readonly pageFlipContentResource = 'app.string.pageflip_content';

  aboutToAppear(): void {
    // 请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
    // 请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的末尾形成新的数据源。
    for (let i = this.pageFlipPageStart; i <= this.pageFlipPageEnd; i++) {
      this.data.pushItem(this.pageFlipContentResource + i.toString());
    }
  }

  build() {
    Column() {
      Swiper(this.swiperController) {
        /**
         * TODO: 高性能知识点: 使用了cachedCount设置预加载的Text的数量，只在LazyForEach中生效，设置该属性后会缓存cachedCount个Text，LazyForEach超出显示和缓存范围的Text会被释放。
         * 使用cachedCount参数的例子:https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/ui-ts-performance-improvement-recommendation-0000001477981001-V2
         */
        LazyForEach(this.data, (item: string) => {
          Text($r(item))
            .width($r('app.string.pageflip_full_size'))
            .fontSize($r('app.integer.flippage_text_fontsize'))
            .textAlign(TextAlign.Start)
            .align(Alignment.TopStart)
            .margin({
              top: $r('app.integer.flippage_margin_40'),
              right: $r('app.integer.flippage_margin_20'),
              left: $r('app.integer.flippage_margin_20'),
              bottom: $r('app.integer.flippage_margin_20')
            })
        }, (item: string) => item)
      }
      .index(this.currentPageNum - this.pageFlipPageCount)
      .width($r('app.string.pageflip_full_size'))
      .height($r('app.string.pageflip_full_size'))
      .indicator(false)
      .cachedCount(this.pageFlipCacheCount)
      .itemSpace(this.pageFlipZero)
      .loop(false)
      .curve(Curve.Linear)
      .backgroundColor($r('app.color.pageflip_swiper_backgroundcolor'))
      .effectMode(EdgeEffect.Fade)
      .duration(this.pageFlipToastDuration)
      .onChange((index: number) => {
        this.currentPageNum = index + this.pageFlipPageCount;  // 通过onChange监听当前处于第几页。
      })
    }
    .width($r('app.string.pageflip_full_size'))
    .height($r('app.string.pageflip_full_size'))
    .onClick((event?: ClickEvent) => {
      if (event) {
        if (event.x > this.screenW / this.pageFlipThree * this.pageFlipTwo) {
          if (this.currentPageNum !== this.data.totalCount()) {
            this.swiperController.showNext();
          }
        } else if (event.x > this.screenW / this.pageFlipThree) {
          if (this.isMenuViewVisible) {
            this.isMenuViewVisible = false;
            this.isCommentVisible = false;
          } else {
            this.isMenuViewVisible = true;
            this.isCommentVisible = true;
          }
        } else {
          //向左翻页
          if (this.currentPageNum !== this.pageFlipPageStart) {
            this.swiperController.showPrevious();
          }
        }
      }
    })
  }
}