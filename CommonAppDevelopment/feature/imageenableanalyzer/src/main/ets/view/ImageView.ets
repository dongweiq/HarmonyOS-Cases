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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import promptAction from '@ohos.promptAction';

/**
 * 实现步骤：
 * 通过Image.enableAnalyzer(true)实现Image组件长摁拖拽元素并AI抠图：
 * 1. 目前AI分析支持传入的图片类型为PixelMap且为RGBA_8888类型的图片，因此定义方法使图片转成PixelMap且为RGBA_8888类型。
 * 2. 将需要AI抠图的Image组件添加.enableAnalyzer(true)方法，并传入PixelMap且为RGBA_8888类型的图片，即可开启AI抠图能力。
 * Image.enableAnalyzer()参考文档：
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-image-0000001821000853#ZH-CN_TOPIC_0000001821000853
 */
@Component
export struct ImageView {
  @State swiperIndex: number = 0;
  @State imagePixelMapList: Array<image.PixelMap> = []; // 定义转化过类型的图片数组
  @Consume('pageStack') pageStack: NavPathStack;
  scroller: Scroller = new Scroller();

  aboutToAppear() {
    const arr = [$r('app.media.cat'), $r('app.media.cat2')];
    arr.forEach(async (item) => {
      const imagePixelMap = await this.getPixmapFromMedia(item); // TODO：知识点：使jpg类型的图片转成PixelMap且为RGBA_8888类型
      this.imagePixelMapList.push(imagePixelMap);
    })
  }

  build() {
    Stack() {
      Scroll(this.scroller) {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Swiper() {
              ForEach(this.imagePixelMapList, (item: image.PixelMap) => { // 传入符合AI处理的图片类型并渲染图片
                /* 性能知识点：当数据量较大时，推荐使用懒加载加载数据。
                 * 参考使用数据懒加载文章：
                 * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/arkts-performance-improvement-recommendation.md/
                 */
                Image(item)
                  .enableAnalyzer(true)// TODO：知识点：开启Image组件的AI分析能力，目前支持分析PixelMap且为RGBA_8888类型的图片
                  .objectFit(ImageFit.Contain)
                  .width('100%')
                  .draggable(false) // 禁止整张图片拖动
              })
            }
            .index(this.swiperIndex)
            .onChange((index: number) => {
              this.swiperIndex = index;
            })
            .indicator(new DotIndicator()
              .itemWidth($r('app.integer.indicator_itemWidth'))
              .itemHeight($r('app.integer.indicator_itemWidth'))
              .selectedItemWidth($r('app.integer.indicator_selectedItemWidth'))
              .selectedItemHeight($r('app.integer.indicator_selectedItemHeight'))
              .color(Color.Gray)
              .selectedColor(Color.Red))

            Row() {
              Text(`${this.swiperIndex + 1}/${this.imagePixelMapList.length}`)
                .fontSize($r('app.integer.bubble_text_fontSize'))
                .fontColor($r('app.color.white'))
            }
            .width($r('app.integer.row_text_width'))
            .height($r('app.integer.row_text_height'))
            .borderRadius($r('app.integer.row_borderRadius'))
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.bg3'))
            .margin({ right: $r('app.integer.row_margin_right'), bottom: $r('app.integer.row_margin_bottom') })
          }
          .width('100%')
          .height($r('app.integer.swiper_height'))
          .margin({ top: $r('app.integer.view_margin_top') })
          .backgroundColor($r('app.color.white'))

          Column() {
            Content()
              .margin({ top: $r('app.integer.content_margin_top') })
          }
          .padding({ left: $r('app.integer.column_padding_left'), right: $r('app.integer.column_padding_right') })
        }
        .width('100%')
        .margin({ top: $r('app.integer.column_margin_top') })
      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBarColor(Color.Gray) // 滚动条颜色
      .scrollBarWidth(3) // 滚动条宽度

      Image($r('app.media.back'))
        .width($r('app.integer.icon_width'))
        .aspectRatio(1)
        .position({ x: 20, y: 20 })
        .onClick(() => {
          this.pageStack.pop();
        })
      Image($r('app.media.batman'))
        .width($r('app.integer.icon_width'))
        .height($r('app.integer.icon_width'))
        .position({ x: 60, y: 20 })
        .onClick(()=>{
          // 调用Toast显示提示:此样式仅为案例展示
          promptAction.showToast({ message: $r('app.string.only_show_ui') });
        })

      Text($r('app.string.user_name'))
        .position({ x: 100, y: 26 })
        .onClick(()=>{
          // 调用Toast显示提示:此样式仅为案例展示
          promptAction.showToast({ message: $r('app.string.only_show_ui') });
        })

      Image($r("app.media.share"))
        .width($r('app.integer.icon_width'))
        .aspectRatio(1)
        .position({ x: '100%', y: 20 })
        .translate({ x: -62, y: 0 })
        .onClick(()=>{
          // 调用Toast显示提示:此样式仅为案例展示
          promptAction.showToast({ message: $r('app.string.only_show_ui') });
        })
    }
  }

  private async getPixmapFromMedia(resource: Resource) {
    const unit8Array = await getContext(this)?.resourceManager?.getMediaContent({
      bundleName: resource.bundleName,
      moduleName: resource.moduleName,
      id: resource.id
    })
    const imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
    const createPixelMap: image.PixelMap = await imageSource.createPixelMap({
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888
    })
    await imageSource.release();
    return createPixelMap;
  }
}


@Component
  // 图片下面的文字内容组件
struct Content {
  build() {
    Column() {
      Text($r('app.string.image_drag_title')) // 文字标题
        .fontSize($r('app.integer.text_title_fontSize'))
        .fontWeight("bold")
        .padding({ top: $r('app.integer.text_padding_top') })
        .textAlign(TextAlign.Start)
      Text($r('app.string.image_drag_content')) // 文字内容
        .fontSize($r('app.integer.text_content_fontSize'))
        .padding({ top: $r('app.integer.text_padding_top') })
        .lineHeight($r('app.integer.contain_line_height'))
        .textAlign(TextAlign.Start)
      Text($r('app.string.image_drag_ref')) // 文字内容话题
        .fontSize($r('app.integer.text_content_fontSize'))
        .fontColor($r('app.color.content_color'))
        .padding({ top: $r('app.integer.text_padding_top') })
        .textAlign(TextAlign.Start)
        .onClick(()=>{
          // 调用Toast显示提示:此样式仅为案例展示
          promptAction.showToast({ message: $r('app.string.only_show_ui') });
        })
    }
    .width('100%')
    .padding({
      top: $r('app.integer.view_padding_top'), bottom: $r('app.integer.view_padding_bottom'),
      left: $r('app.integer.view_padding_left'), right: $r('app.integer.view_padding_right')
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.integer.view_borderRadius'))
  }
}


// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageView(): void {
  ImageView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_ENABLE_ANALYZER, wrapBuilder(getImageView));
