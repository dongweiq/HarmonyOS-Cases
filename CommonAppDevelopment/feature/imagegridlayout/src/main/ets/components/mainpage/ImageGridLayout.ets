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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { MultiGrid } from './MultiGrid'

// 图片属性的modifier类，便于用户扩展image相关的属性
class ImageModifier implements AttributeModifier<ImageAttribute> {
  private imageFit: ImageFit = ImageFit.Fill;
  private imageRenderMode: ImageRenderMode = ImageRenderMode.Original;

  constructor() {
  }

  applyNormalAttribute(instance: ImageAttribute): void {
    instance.objectFit(this.imageFit)
    instance.renderMode(this.imageRenderMode)
  }

  objectFit(fit: ImageFit): ImageModifier {
    this.imageFit = fit;
    return this;
  }

  renderMode(mode: ImageRenderMode): ImageModifier {
    this.imageRenderMode = mode;
    return this;
  }
}


// 九宫格图片布局实例
@Component
export struct ImageGridLayout {
  // 不同图片数量的图片集合
  private imageArray1: Resource[] = [$r("app.media.b")];
  private imageArray3: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c")];
  private imageArray4: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d")];
  private imageArray8: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d"), $r("app.media.e"), $r("app.media.f"), $r("app.media.g"), $r("app.media.h")];
  private imageArray9: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d"), $r("app.media.e"), $r("app.media.f"), $r("app.media.g"), $r("app.media.h"), $r("app.media.i")];
  private imageSet: Resource[][] = [this.imageArray1, this.imageArray3, this.imageArray4, this.imageArray8, this.imageArray9];
  private textArray: string[] = ['一张图片场景:', '三张图片场景:', '四张图片场景:', '八张图片场景:', '九张图片场景:'];
  // TODO：知识点：自定义组件中实现属性扩展
  private imageModifier: ImageModifier = new ImageModifier().objectFit(ImageFit.Fill)
    .renderMode(ImageRenderMode.Original)

  build() {
    Scroll() {
      Column() {
        ForEach(this.imageSet, (item: Resource[], index: number) => {
          Text(this.textArray[index])
            .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin') })
          MultiGrid({ imageSource: item, modifier: this.imageModifier })
          Divider().margin({ top: $r('app.float.divider_margin') })
        })
      }.alignItems(HorizontalAlign.Start)
    }
    .padding($r('app.float.padding_20'))
    .width($r('app.string.width_100'))
    .height($r('app.string.height_100'))
  }
}


// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageGridLayout(): void {
  ImageGridLayout();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_GRID_LAYOUT, wrapBuilder(getImageGridLayout));