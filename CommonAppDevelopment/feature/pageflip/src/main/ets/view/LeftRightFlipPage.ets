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
import { CONFIGURATION, STRINGCONFIGURATION } from '../common/Constants';

/**
 * 左右翻页方式通过swiper+lazyforeach+cachecount实现按需加载。什么时候加载在BasicDataSource的getData方法中实现
 */

@Component
export struct LeftRightPlipPage {
  @Link isMenuViewVisible: boolean;
  @Link isCommentVisible: boolean;
  @Link currentPageNum: number;
  private swiperController: SwiperController = new SwiperController();
  private data: BasicDataSource = new BasicDataSource([]);
  private screenW: number = px2vp(display.getDefaultDisplaySync().width);

  aboutToAppear(): void {
    /**
     * 请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
     * 请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的末尾形成新的数据源。
     */
    for (let i = CONFIGURATION.PAGEFLIPPAGESTART; i <= CONFIGURATION.PAGEFLIPPAGEEND; i++) {
      this.data.pushItem(STRINGCONFIGURATION.PAGEFLIPRESOURCE + i.toString());
    }
    if (this.screenW > CONFIGURATION.WINDOWWIDTH) {
      this.screenW = this.screenW / 2;
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
            .height($r('app.string.pageflip_full_size'))
            .fontSize($r('app.integer.flippage_text_fontsize'))
            .textAlign(TextAlign.Start)
            .align(Alignment.TopStart)
            .lineHeight($r('app.integer.flippage_text_lineheight'))
            .margin({
              top: $r('app.integer.flippage_margin_large'),
              left: $r('app.integer.flippage_padding_middle_two'),
              bottom: $r('app.integer.flippage_margin_middle')
            })
            .padding({
              left: $r('app.integer.flippage_padding_middle'),
              right: $r('app.integer.flippage_padding_middle'),
            })
        }, (item: string) => item)
      }
      // TODO:知识点:index设置当前在容器中显示的子组件的索引值。设置小于0或大于等于子组件数量时，按照默认值0处理。
      .index(this.currentPageNum - CONFIGURATION.PAGEFLIPPAGECOUNT)
      .width($r('app.string.pageflip_full_size'))
      .height($r('app.string.pageflip_full_size'))
      .indicator(false)
      .cachedCount(CONFIGURATION.PAGEFLIPCACHECOUNT)
      .itemSpace(CONFIGURATION.PAGEFLIPZERO)
      .loop(false)
      .curve(Curve.Linear)
      .effectMode(EdgeEffect.Fade)
      .duration(CONFIGURATION.PAGEFLIPTOASTDURATION)
      .onChange((index: number) => {
        this.currentPageNum = index + CONFIGURATION.PAGEFLIPPAGECOUNT; // 通过onChange监听当前处于第几页。
      })
    }
    .width($r('app.string.pageflip_full_size'))
    .height($r('app.string.pageflip_full_size'))
    .backgroundColor($r('app.color.pageflip_swiper_backgroundcolor'))
    // 扩展至所有非安全区域
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onClick((event?: ClickEvent) => {
      if (!event) {
        return;
      }
      if (event.x > this.screenW / CONFIGURATION.PAGEFLIPTHREE * CONFIGURATION.PAGEFLIPTWO) {
        if (this.currentPageNum !== this.data.totalCount()) {
          this.swiperController.showNext();
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
          this.swiperController.showPrevious();
        }
      }
    })
  }
}