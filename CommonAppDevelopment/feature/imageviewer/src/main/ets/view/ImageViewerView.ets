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


/**
 * 思路：
 * 1. 使用matrix实现图片的缩放
 * 2. 使用offset实现组件的偏移
 * 3. 提前计算图片属性以便对组件属性进行设置
 * 4. Image.objectFile使用Cover以便图片能够超出其父组件显示（而不撑大父组件）——供增强需求：多张图片切换使用
 */

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { common } from '@kit.AbilityKit';
import { ImageViewerConstants } from '../constants/ImageViewerConstants';
import { CommonLazyDataSourceModel } from '../model/CommonLazyDataSourceModel';
import { ImageItemView } from './ImageItemView';
import fs from '@ohos.file.fs';

@Component
export struct ImageViewerView {
  @State isEnableSwipe: boolean = true;
  @Provide bgc: Color = Color.White;
  imageDataSource: CommonLazyDataSourceModel<string> = new CommonLazyDataSourceModel();
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  swipeController: SwiperController = new SwiperController();

  /**
   * 初始化数据源
   */
  aboutToAppear(): void {
    const resourceDir: string = this.context.resourceDir;
    const files: string[] = fs.listFileSync(resourceDir);
    for (let f of files) {
      this.imageDataSource.pushData(resourceDir + '/' + f);
    }
  }

  build() {
    Swiper(this.swipeController) {
      // TODO：性能知识点：懒加载
      LazyForEach(this.imageDataSource, (item: string, index: number) => {
        ImageItemView({ imageUri: item, isEnableSwipe: this.isEnableSwipe })
          .width($r("app.string.image_item_width"))
          .height($r("app.string.image_item_height"))
      })
    }
    .onClick(() => {
      this.bgc = this.bgc === Color.White ? Color.Black : Color.White;
    })
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .autoPlay(false)
    .disableSwipe(!this.isEnableSwipe)
    .loop(false)
    .indicator(false)
    .cachedCount(ImageViewerConstants.SWIPER_CACHE_COUNT)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageViewerView(): void {
  ImageViewerView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_VIEWER, wrapBuilder(getImageViewerView));