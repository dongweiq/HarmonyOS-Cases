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

import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { FlowItemContentsData, FlowItemContent, JsonObject } from '../model/BasicDataSource';

// window.setWindowSystemBarEnable方法的预设值，设置窗口全屏模式时状态栏和导航栏是否显示
const WINDOW_SYSTEM_BAR: Array<'status' | 'navigation'> = ['navigation', 'status'];
const LAYOUT_WEIGHT: number = 1; // 自动分配剩余空间
const JSON_URI: string = 'mockData.json'; // 获取mock数据的json名称
const ASPECT_RATIO: number = 1.77777778; //元素宽高比

/**
 * 实现步骤：
 * 1. 在Video组件内调用onFullScreenChange方法，实现媒体全屏效果。
 * 2. 调用@ohos.window的getLastWindow方法获取当前应用内最上层的子窗口，若无应用子窗口，则返回应用主窗口。
 * 3. 利用获取到的窗口对象，调用setWindowSystemBarEnable方法设置窗口是否显示导航栏和状态栏。
 * 4. 调用窗口对象的setPreferredOrientation方法设置窗口旋转方向和重力感应。
 */

@Component
export struct MediaFullScreen {
  @State cachedCountNumber: number = 6; // 懒加载缓存数
  @State contentData: FlowItemContentsData = new FlowItemContentsData(); // 瀑布流内容

  async aboutToAppear() {
    let jsonObj: JsonObject = new JsonObject(JSON_URI);
    let array = await jsonObj.getFlowItemContentObj();
    this.contentData.pushData(array);
  }

  async aboutToDisappear() {
    let currentWindow = await window.getLastWindow(getContext(this));
    currentWindow.setWindowSystemBarEnable(WINDOW_SYSTEM_BAR);
  }

  build() {
    Column() {
      WaterFlow() {
        // 性能知识点: LazyForEach 懒加载优化，详情请见 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/
        LazyForEach(this.contentData, (moment: FlowItemContent) => {
          FlowItem() {
            ReusableComponent({ moment })
          }
          .width($r('app.string.video_width'))
        }, (moment: FlowItemContent) => moment.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('app.integer.friendMomentsPage_row_padding_left'))
      .rowsGap($r('app.integer.friendMomentsPage_row_padding_left'))
      .cachedCount(this.cachedCountNumber) // 懒加载缓存配置
      .width($r('app.string.layout_100'))
      .height($r('app.string.layout_100'))
    }
    .backgroundColor($r('app.color.friends_page_search_border_color'))
    .height($r('app.string.layout_100'))
    .layoutWeight(LAYOUT_WEIGHT)
  }
}

// 性能知识点: @Reusable复用组件优化，详情请见 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/component-recycle.md/
@Reusable
@Component
struct ReusableComponent {
  @Prop moment: FlowItemContent;
  @State isFullScreen: boolean = false; // 判断当前是否为全屏状态
  controller: VideoController = new VideoController();

  windowChange(isFullScreen: boolean) {
    if (isFullScreen) {
      this.isFullScreen = false;
      this.controller.stop();
      window.getLastWindow(getContext(), (err: BusinessError, data) => {
        const errCode = err.code;
        if (errCode) {
          return;
        }
        // TODO:知识点： 设置窗口是否显示导航栏和状态栏
        data.setWindowSystemBarEnable(WINDOW_SYSTEM_BAR);
        data.setPreferredOrientation(window.Orientation.PORTRAIT);
      })
    } else {
      this.isFullScreen = true;
      // 设置媒体全屏
      this.controller.requestFullscreen(true);
      window.getLastWindow(getContext(), (err: BusinessError, data) => {
        const errCode = err.code;
        if (errCode) {
          return;
        }
        data.setWindowSystemBarEnable([]);
        // TODO:知识点：设置窗口旋转方向和重力感应：AUTO_ROTATION_LANDSCAPE，表示传感器自动横向旋转模式。
        data.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
        this.controller.start();
      })
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Video({
          src: $rawfile(this.moment.media),
          previewUri: $r(`app.media.${this.moment.mediaPreview}`),
          controller: this.controller
        })
          .borderRadius({ topLeft: 10, topRight: 10 })
          .alignSelf(ItemAlign.Center)
          .controls(this.isFullScreen)
          .width('100%')
          .aspectRatio(ASPECT_RATIO)
          .layoutWeight(LAYOUT_WEIGHT)
          .objectFit(ImageFit.Contain)
          .onFullscreenChange(() => {
            // 全屏切换
            this.windowChange(this.isFullScreen);
          })
          .onClick(() => {
            if (this.isFullScreen) return;
            this.windowChange(this.isFullScreen);
          })

        Image($r('app.media.play'))
          .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)
          .width($r('app.integer.friendMomentsPage_icon_play_width'))
          .height($r('app.integer.friendMomentsPage_icon_play_height'))
      }

      Text(this.moment.text)
        .lineHeight($r('app.integer.friendMomentsPage_useName_line_height'))
        .fontFamily($r('app.string.harmony_hei_ti'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.integer.friendMomentsPage_userText_fontSize'))
        .fontColor($r('app.color.title_font_color'))
        .padding($r('app.integer.friendMomentsPage_row_padding_left'))
      Row() {
        Image($r(`app.media.${this.moment.user.userImage}`))
          .autoResize(false)
          .width($r('app.integer.friendMomentsPage_user_image_width'))
          .height($r('app.integer.friendMomentsPage_user_image_height'))
          .borderRadius($r('app.integer.friendMomentsPage_user_image_border_radius'))
        Text(this.moment.user.userName)
          .fontSize($r('app.integer.friendMomentsPage_useName_fontSize'))
          .fontColor($r('app.color.title_font_color'))
          .lineHeight($r('app.integer.friendMomentsPage_userText_line_height'))
          .fontFamily($r('app.string.harmony_hei_ti'))
          .margin({ left: $r('app.integer.friendMomentsPage_user_col_margin_left') })
          .layoutWeight(LAYOUT_WEIGHT)
      }
      .padding({
        left: $r('app.integer.friendMomentsPage_row_padding_left'),
        right: $r('app.integer.friendMomentsPage_row_padding_right'),
        top: $r('app.integer.friendMomentsPage_row_padding_top'),
        bottom: $r('app.integer.friendMomentsPage_row_padding_bottom')
      })
    }
    .shadow({ radius: $r('app.integer.stack_shadow_radius'), color: Color.Gray })
    .border({ radius: $r('app.integer.friendMomentsPage_row_padding_left') })
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }
}
