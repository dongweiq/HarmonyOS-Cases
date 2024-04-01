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

import image from '@ohos.multimedia.image';
import effectKit from '@ohos.effectKit';
import resourceManager from '@ohos.resourceManager';
import window from '@ohos.window';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * 实现步骤：
 * 1. 通过使用滑动视图容器Swiper，将控制器SwiperController绑定Swiper组件，实现其子组件Image图片滑动轮播显示效果。
 * 2. 在事件onAnimationStart切换动画过程中通过Image模块相关能力，获取图片颜色平均值，使用effectKit包中的ColorPicker智能取色器进行颜色取值。
 * 3. 同时通过接口animateTo开启背景颜色渲染的属性动画。全局界面开启沉浸式状态栏。
 */


@Component
export struct MainPage {
  // 图片资源获取
  @State imgData: Resource[] = [
    $r('app.media.image4'),
    $r('app.media.image5'),
    $r('app.media.image6'),
    $r('app.media.image7')
  ];
  // 初始背景色赋值
  @State bgColor: string = "#fffffff";
  // 顶部安全高度赋值
  @State topSafeHeight: number = 0;
  // 创建swiperController
  private swiperController: SwiperController = new SwiperController();
  // swiper自动播放时间间隔
  private swiperInterval: number = 3500;
  // swiper子组件切换动画时长
  private swiperDuration: number = 500;
  // swiper子组件与子组件间隙
  private swiperItemSpace: number = 10;

  async aboutToAppear() {
    // 顶部安全高度适配
    let windowHight: window.Window = await window.getLastWindow(getContext(this));
    await windowHight.setWindowLayoutFullScreen(true);
    this.topSafeHeight = px2vp(windowHight.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)

    // TODO 知识点：初始化页面获取第一张图片的颜色
    const context = getContext(this);
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    const fileData: Uint8Array = await resourceMgr.getMediaContent(this.imgData[0]);
    const buffer = fileData.buffer as ArrayBuffer;
    const imageSource: image.ImageSource = image.createImageSource(buffer);
    const pixelMap: image.PixelMap = await imageSource.createPixelMap();

    // TODO 知识点：智能取色器接口使用，初始化背景色
    effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
      let color = colorPicker.getMainColorSync();
      // 将取色器选取的color示例转换为十六进制颜色代码
      this.bgColor = "#" + color.alpha.toString(16) + color.red.toString(16) + color.green.toString(16) + color.blue.toString(16)
    })
  }

  build() {
    Column() {
      Swiper(this.swiperController) {
        // TODO 高性能知识点：此处为了演示场景，数量只有4个，使用ForEach，真实场景列表数量较多的场景，推荐使用LazyForEach+组件复用+缓存列表项实现
        ForEach(this.imgData, (item: Resource) => {
          Image(item).borderRadius($r('app.integer.image_borderRadius'))
            .margin({ top: $r('app.integer.image_margin_top') })
        })
      }
      .width($r('app.string.swiper_width'))
      .padding({ left: $r('app.integer.swiper_padding_left'), right: $r('app.integer.swiper_padding_right') })
      .autoPlay(true)
      .interval(this.swiperInterval)
      .duration(this.swiperDuration)
      .loop(true)
      .itemSpace(this.swiperItemSpace)
      .indicator(false)
      // TODO 知识点：切换动画过程中获取图片平均颜色
      .onAnimationStart(async (index, targetIndex) => {
        try {
          const context = getContext(this);
          // 获取resourceManager资源管理器
          const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
          const fileData: Uint8Array = await resourceMgr.getMediaContent(this.imgData[targetIndex]);
          // 获取图片的ArrayBuffer
          const buffer = fileData.buffer as ArrayBuffer;
          // 创建imageSource
          const imageSource: image.ImageSource = image.createImageSource(buffer);
          // 创建pixeMap
          const pixelMap: image.PixelMap = await imageSource.createPixelMap();

          effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
            // 读取图像主色的颜色值，结果写入Color
            let color = colorPicker.getMainColorSync();
            // 开启背景颜色渲染的属性动画
            animateTo({ duration: 500, curve: Curve.Linear, iterations: 1 }, () => {
              // 将取色器选取的color示例转换为十六进制颜色代码
              this.bgColor = "#" + color.alpha.toString(16) + color.red.toString(16) + color.green.toString(16) + color.blue.toString(16);
            })
          })

        } catch (e) {
        }
      })
    }
    .width($r('app.string.column_width'))
    .height($r('app.string.column_height'))
    .linearGradient({
      // 渐变方向
      direction: GradientDirection.Bottom,
      // 数组末尾元素占比小于1时，满足重复着色的效果
      colors: [[this.bgColor, 0.0], [Color.White, 0.5]]
    })
    .padding({ top: this.topSafeHeight })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getMainPage(): void {
  MainPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.EFFECT_KIT, wrapBuilder(getMainPage));