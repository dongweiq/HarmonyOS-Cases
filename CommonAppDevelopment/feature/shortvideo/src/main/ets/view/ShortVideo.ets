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
import { TopTabContent } from '../model/DataModel';
import { VideoSwiper } from './VideoSwiper';
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsRouter/Index';

/**
 * 实现步骤：
 * 1. 使用Swiper组件创建一个竖直的可上下滑动的框架
 * 2. Swiper组件结合LazyForEach使用，懒加载资源
 * 3. 在Swiper组件中使用Video组件承载视频
 */

@Component
export struct ShortVideo {
  @State currentIndex: number = 1; // 当前tab下标
  scroller: Scroller = new Scroller(); // scroller控制器初始化
  private topTabListData: TopTabContent = new TopTabContent(); // 初始化顶部tab数据

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.currentIndex === 1) {
        VideoSwiper() // 视频滑动组件
          .height('100%')
      }
      Row() {
        Image($r("app.media.search_icon"))
          .width($r('app.integer.search_icon_width'))
          .height($r('app.integer.search_icon_height'))
        List({ scroller: this.scroller }) {
          /*
           *性能知识点：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
           *当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
           *文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2
           */
          LazyForEach(this.topTabListData, (item: string, index) => {
            ListItem() {
              Column() {
                Text(item)
                  .fontColor(this.currentIndex === index ? Color.White : $r('app.color.font_color'))
                  .fontSize($r('app.integer.tab_font_size'))
                Divider()
                  .width(this.currentIndex === index ? $r('app.integer.tab_divider_width') : $r('app.integer.tab_divider_width_0'))
                  .strokeWidth(2)
                  .color(this.currentIndex === index ? Color.White : Color.Gray)
                  .margin({
                    top: $r('app.integer.divider_margin_top')
                  })
              }
              .padding({ top: $r('app.integer.tab_padding_top') })
              .width('25%')
            }
          }, (item: string, index) => JSON.stringify(item))
        }
        .listDirection(Axis.Horizontal) // 顶部tab列表横向排列
        .height('100%')
        .width('60%')

        Image($r("app.media.add1"))
          .width($r('app.integer.add_icon_width'))
          .height($r('app.integer.add_icon_width'))
      }
      .height($r('app.integer.tab_list_height'))
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height('100%')
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getShortVideo(): void {
  ShortVideo();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
const builderName = RouterNameConstants.ROUTER_NAME_SHORT_VIDEO;
if (!DynamicsRouter.getBuilder(builderName)) {
  const builder: WrappedBuilder<[object]> = wrapBuilder(getShortVideo);
  DynamicsRouter.registerBuilder(builderName, builder);
}