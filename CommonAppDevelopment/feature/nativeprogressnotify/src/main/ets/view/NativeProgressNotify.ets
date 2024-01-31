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

import naitiveprogressnotify from 'libnativeprogressnotify.so';
import { NativeProgressNotifyConstants } from '../constants/NativeProgressNotifyConstants';

@Component
export struct NativeProgressNotify {
  @State progress: number = 0;

  build() {
    Row() {
      Column({ space: 10 }) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
          .width($r("app.integer.progress_size"))
          .height($r("app.integer.progress_size"))
          .animation({ duration: NativeProgressNotifyConstants.PROGRESS_ANIMATION_DURATION, curve: Curve.Ease })
          .style({ strokeWidth: 15 })
        Text(`当前下载进度：${this.progress}%`)
        Button("Start Download")
          .onClick(() => {
            naitiveprogressnotify.startDownload((data: number) => {
              this.progress = data;
              console.log("[NativeProgressNotify]progress:" + this.progress);
            })
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}