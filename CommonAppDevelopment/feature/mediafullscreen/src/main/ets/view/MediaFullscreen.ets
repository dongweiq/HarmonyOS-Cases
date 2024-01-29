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

// window.setWindowSystemBarEnable方法的预设值，设置窗口全屏模式时状态栏和导航栏是否显示
const windowSystemBar: Array<'status' | 'navigation'> = ['navigation', 'status'];

/**
 * 实现步骤：
 * 1. 在Video组件内调用onFullscreenChange方法，实现媒体全屏效果。
 * 2. 调用@ohos.window的getLastWindow方法获取当前应用内最上层的子窗口，若无应用子窗口，则返回应用主窗口。
 * 3. 利用获取到的窗口对象，调用setWindowSystemBarEnable方法设置窗口是否显示导航栏和状态栏。
 * 4. 调用窗口对象的setPreferredOrientation方法设置窗口旋转方向以及是否应用重力感应。
 */
@Component
export struct MediaFullscreen {
  @State isFullscreen: boolean = false; // 判断当前是否为全屏状态
  scroller: Scroller = new Scroller();
  @State videoSrc: Resource = $r('app.media.video');
  @State contentData: Array<number> = new Array(10).fill(0);
  controller: VideoController = new VideoController();

  windowChange(isFullscreen: boolean) {
    if (isFullscreen) {
      this.isFullscreen = false;
      window.getLastWindow(getContext(), (err: BusinessError, data) => {
        const errCode = err.code;
        if (errCode) {
          return;
        }
        // TODO:知识点1： 设置窗口是否显示导航栏和状态栏
        data.setWindowSystemBarEnable(windowSystemBar);
        // TODO:知识点2：设置窗口旋转方向以及是否应用重力感应
        data.setPreferredOrientation(window.Orientation.PORTRAIT);
      })
    } else {
      this.isFullscreen = true;
      window.getLastWindow(getContext(), (err: BusinessError, data) => {
        const errCode = err.code;
        if (errCode) {
          return;
        }
        data.setWindowSystemBarEnable([]);
        data.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
      })
    }
  }

  async aboutToDisappear() {
    let currentWindow = await window.getLastWindow(getContext(this));
    currentWindow.setWindowSystemBarEnable(windowSystemBar);
  }

  build() {
    List({ space: 12, scroller: this.scroller }) {
      ForEach(this.contentData, () => {
        ListItem() {
          Column() {
            Stack() {
              Video({
                src: this.videoSrc,
                controller: this.controller
              })
                .width($r('app.string.video_width'))
                .height($r('app.integer.video_height'))
                .objectFit(ImageFit.Contain)
                .onFullscreenChange(() => {
                  // 横竖屏切换
                  this.windowChange(this.isFullscreen);
                })
            }
          }
        }
        .width($r('app.string.video_width'))
      })
    }
    .width($r('app.string.video_width'))
    .height($r('app.string.video_width'))
    .enableScrollInteraction(!this.isFullscreen)
    .scrollBar(BarState.Off)
  }
}