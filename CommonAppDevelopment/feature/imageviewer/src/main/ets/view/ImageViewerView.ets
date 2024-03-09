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
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

@Preview
@Component
export struct ImageViewerView {
  @State currentIndex: number = 0;
  @State windowHeight: number = 0;
  @State windowWidth: number = 0;
  @State scaleInfo: ImageScaleModel = new ImageScaleModel(1, 1);
  image: Resource = $r("app.media.test1")
  controller: SwiperController = new SwiperController();

  aboutToAppear() {
    window.getLastWindow(getContext(this), (err: BusinessError, data: window.Window) => {
      let rect: window.Rect = data.getWindowProperties().windowRect;
      this.windowWidth = px2vp(rect.width);
      this.windowHeight = px2vp(rect.height);
      data.on("windowSizeChange", (data: window.Size) => {
        this.windowWidth = px2vp(data.width);
        this.windowHeight = px2vp(data.height);
      })
    })
  }

  build() {
    Stack() {
      ImageContentView({
        imageScale: this.scaleInfo,
        image: this.image,
        swiperController: this.controller
      })
    }
    .width(ImageViewerConstants.FULL_SIZE)
    .height(ImageViewerConstants.FULL_SIZE)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageViewerView(): void {
  ImageViewerView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_VIEWER, wrapBuilder(getImageViewerView));