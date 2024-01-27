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

import window from '@ohos.window'
import { BusinessError } from '@ohos.base';

const windowSystemBar: Array<'status' | 'navigation'> = ['navigation', 'status']

@Component
export struct MediaFullscreen {
  @State isFullscreen: boolean = false;
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
        // TODO 知识点1： 设置窗口是否显示导航栏和状态栏
        data.setWindowSystemBarEnable(windowSystemBar);
        // TODO 知识点2：设置窗口旋转方向以及是否应用重力感应
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