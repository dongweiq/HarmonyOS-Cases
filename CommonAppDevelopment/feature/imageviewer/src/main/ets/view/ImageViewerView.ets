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

import { ImageViewerConstants } from '../constants/ImageViewerConstants';
import { CommonImageDetailModel } from '../model/CommonImageDetailModel';
import { ImageScaleModel } from '../model/ImageScaleModel';
import { ImageContentView } from './ImageContentView';

@Preview
@Component
export struct ImageViewerView {
  imageModel: CommonImageDetailModel = new CommonImageDetailModel(
    [
      $r("app.media.test1"), $r("app.media.test2"), $r("app.media.test3"), $r("app.media.test4")
    ]
  );
  @State currentIndex: number = 0;
  @StorageLink("windowHeight") windowHeight: number = 0;
  @StorageLink("windowWidth") windowWidth: number = 0;
  @State scaleArray: Array<ImageScaleModel> = [];
  controller: SwiperController = new SwiperController();

  // TODO: 需求：图片缩放、上下图切换体验待优化
  aboutToAppear() {
    this.currentIndex = this.imageModel.currentIndex + 1;
    for (let index = 0; index < this.imageModel.imageArray.length; index++) {
      this.scaleArray.push(new ImageScaleModel(1, 1));
    }
  }

  build() {
    NavDestination() {
      Stack() { // 如果需要放其他组件，可以使用Stack，让其他组件显示在图片的上方
        Swiper(this.controller) {
          ForEach(this.imageModel.imageArray, (image: Resource, index: number) => {
            Scroll() {
              ImageContentView({
                imageScale: this.scaleArray[index],
                image: image,
                swiperController: this.controller
              })
            }
            .width(ImageViewerConstants.FULL_SIZE)
            .height(ImageViewerConstants.FULL_SIZE)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .nestedScroll({
              scrollForward: NestedScrollMode.SELF_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          })
        }
        .loop(false)
        .autoPlay(false)
        .indicator(false)
        .index(this.imageModel.currentIndex)
        .backgroundColor($r("app.color.image_viewer_bg"))
        .width(ImageViewerConstants.FULL_SIZE)
        .height(ImageViewerConstants.FULL_SIZE)
        .onChange((index: number) => {
          this.currentIndex = index + 1;
        })
        Text($r("app.string.prompt_info"))
          .hitTestBehavior(HitTestMode.None)
          .fontColor($r("app.color.prompt_font_color"))
      }
    }
    .hideTitleBar(true)
    .height(ImageViewerConstants.FULL_SIZE)
    .width(ImageViewerConstants.FULL_SIZE)
  }
}