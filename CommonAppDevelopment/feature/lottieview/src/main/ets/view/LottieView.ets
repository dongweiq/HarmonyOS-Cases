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

import lottie from '@ohos/lottie';
import { FunctionDescription } from '@ohos/base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

const FRAME_START: number = 60; // 动画播放的起始帧
const FRAME_END: number = 120; // 动画播放的终止帧
const TEXT_DATA_LENGTH: number = 3; // 可变文本数据的长度

/**
 * 页面一进来，在onReady函数中执行lottie.loadAnimation来加载动画，默认不自动播放，
 * 点击加载的动画卡片，动画播放，并叠加点击的次数，最后根据(点击的次数%文本数据的数组长度)来更新响应动画的文本。
 */
@Preview
@Component
export struct LottieView {
  build() {
    Column() {
      FunctionDescription({
        title: 'Lottie',
        content: $r('app.string.lottie_content')
      })
      // Lottie动画
      LottieAnimation()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundImage($r('app.media.bg'))
    // 扩展至所有非安全区域
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundImageSize(ImageSize.Cover)
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}

@Component
struct LottieAnimation {
  private politeChickyController: CanvasRenderingContext2D = new CanvasRenderingContext2D(); // CanvasRenderingContext2D对象
  private politeChicky: string = 'politeChicky'; // 动画名称
  private politeChickyPath: string = 'common/lottie/politeChicky.json'; // hap包内动画资源文件路径，仅支持json格式
  private textArray: Array<string> = ['戳我呀', '幸福鸡', '坏了呀']; // 文本数据，用来点击更新文本
  private animateItem: ESObject = null; // 初始化loadAnimation接口的返回对象
  @State times: number = 0; // 初始化点击次数

  // 页面隐藏销毁动画
  onPageHide(): void {
    // TODO:知识点:页面销毁时需要调用lottie的资源回收
    lottie.destroy();
  }

  /**
   * 加载动画
   * @param autoplay 控制动画是否自动播放参数
   */
  loadAnimation(autoplay: boolean) {
    // 销毁动画，减少缓存
    if (this.animateItem !== null) {
      this.animateItem.destroy();
      this.animateItem = null;
    }
    // TODO:知识点:lottie.loadAnimation将json数据生成动画
    this.animateItem = lottie.loadAnimation({
      container: this.politeChickyController,
      renderer: 'canvas',
      loop: false,
      autoplay: autoplay,
      name: this.politeChicky,
      path: this.politeChickyPath,
      initialSegment: [FRAME_START, FRAME_END]
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 动画
      Canvas(this.politeChickyController)
        .width($r('app.integer.canvas_size'))
        .height($r('app.integer.canvas_size'))
        .backgroundColor($r('app.color.ohos_id_color_palette2'))
        .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
        .onReady(() => {
          this.loadAnimation(false);
        })
        .onClick(() => {
          this.loadAnimation(true);
          this.times++;
        })
      // 响应动画的文本
      Text(this.textArray[this.times % TEXT_DATA_LENGTH])
        .fontSize($r('app.string.ohos_id_text_size_headline'))
        .margin($r('app.string.ohos_id_elements_margin_vertical_m'))
        .fontColor(Color.White)
    }.margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getLottieView(): void {
  LottieView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.LOTTIE_VIEW,wrapBuilder(getLottieView));