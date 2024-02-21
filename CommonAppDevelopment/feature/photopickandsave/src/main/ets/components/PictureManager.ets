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

import { SelectPictures } from './SelectPictures';
import { SaveNetWorkPictures } from './SaveNetWorkPictures';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

@Component
export struct PictureManager {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  TabBuilder(index: number, name: string | Resource) {
    Column() {
      Text(name)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(16)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#182431')
        .lineHeight(30)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .margin({ bottom: 7 })
        .opacity(this.currentIndex === index ? 1 : 0.6)
      Divider()
        .strokeWidth(2)
        .width(48)
        .borderRadius(1)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
        .margin({ bottom: 8 })
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
      TabContent() {
        // 下载网络图片并保存到图库或用户指定文件
        SaveNetWorkPictures();
      }
      .tabBar(this.TabBuilder(0, "下载保存图片"))

      TabContent() {
        // 图片选择模块
        SelectPictures();
      }.tabBar(this.TabBuilder(1, "选择图片"))

    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .barWidth(200)
    .barHeight(40)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getPictureManager(): void {
  PictureManager();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterInfo.PHOTO_PICK_AND_SAVE[0];
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(getPictureManager);
  DynamicsRouter.registerBuilder(builderName, builder);
}
