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

@Component
export struct UpDownFlipPage {
  private data: BasicDataSource = new BasicDataSource();
  @Link isMenuViewVisible: boolean;
  @Link isCommentVisible: boolean;
  @Link currentPageNum: number;
  readonly pageFlipToastDuration = 300;
  readonly pageFlipPageStart = 1;
  readonly pageFlipPageEnd = 4;
  readonly pageFlipContentResource = 'app.string.pageflip_content';
  readonly pageFlipPageCount = 1;
  readonly pageFlipCacheCount = 3;

  aboutToAppear(): void {
    // 请求网络数据之后可以通过this.data.addItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的开头形成新的数据源。
    // 请求网络数据之后可以通过this.data.pushItem(new Item('app.string.content' + i.toString()));的方法插入到数据源的末尾形成新的数据源。
    for (let i = this.pageFlipPageStart; i <= this.pageFlipPageEnd; i++) {
      this.data.pushItem(this.pageFlipContentResource + i.toString());
    }
  }

  build() {
    Column() {
      List({ initialIndex: this.currentPageNum - this.pageFlipPageCount }) {
        /**
         * TODO: 高性能知识点: 使用了cachedCount设置预加载的ListItem的数量，只在LazyForEach中生效，设置该属性后会缓存cachedCount个ListItem，LazyForEach超出显示和缓存范围的ListItem会被释放。
         * 使用cachedCount参数的例子:https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/ui-ts-performance-improvement-recommendation-0000001477981001-V2
         */
        LazyForEach(this.data, (item: string) => {
          ListItem() {
            Text($r(item))
              .fontSize($r('app.integer.flippage_text_fontsize'))
              .width($r('app.string.pageflip_full_size'))
          }
        }, (item: string) => item)
      }
      .width($r('app.string.pageflip_lippage_90_size'))
      .height($r('app.string.pageflip_full_size'))
      .scrollBar(BarState.Off)
      .cachedCount(this.pageFlipCacheCount)
      .onScrollIndex((firstIndex: number, lastIndex: number, centerIndex: number) => {
        this.currentPageNum = firstIndex + this.pageFlipPageCount;  // 通过onScrollIndex监听当前处于第几页。
      })
    }
    .width($r('app.string.pageflip_full_size'))
    .backgroundColor($r('app.color.pageflip_swiper_backgroundcolor'))
    .onClick((event?: ClickEvent) => {
      if (event) {
        if (this.isMenuViewVisible) {
          this.isMenuViewVisible = false;
          this.isCommentVisible = false;
        } else {
          this.isMenuViewVisible = true;
          this.isCommentVisible = true;
        }
      }
    })
  }
}