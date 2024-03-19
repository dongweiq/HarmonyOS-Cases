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
import { PanPositionModel } from '../model/PanPositionModel';
import { connection } from '@kit.NetworkKit';
import { promptAction, window } from '@kit.ArkUI';
import { logger } from '@ohos/base/Index';
import { createNWeb, getNWeb } from '../common/utils/NWebUtils';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct HelperView {
  windowSize: window.Size = { width: 0, height: 0 };
  helperUrl: string = "";
  @State isShowReadMe: boolean = false;
  @Link helperIconOffset: PanPositionModel;

  aboutToAppear(): void {
    window.getLastWindow(getContext(this), (err: BusinessError, data: window.Window) => {
      let rect: window.Rect = data.getWindowProperties().windowRect;
      this.windowSize.width = px2vp(rect.width);
      this.windowSize.height = px2vp(rect.height);
    })
  }

  build() {
    Image($r("app.media.help"))
      .onAppear(() => {
        createNWeb(this.helperUrl, this.getUIContext());
      })
      .offset({ x: this.helperIconOffset.currentX, y: this.helperIconOffset.currentY })
      .gesture(
        GestureGroup(
          GestureMode.Exclusive,
          TapGesture({ fingers: 1, count: 1 })
            .onAction(() => {
              if (connection.hasDefaultNetSync()) {
                this.isShowReadMe = !this.isShowReadMe;
              } else {
                promptAction.showToast({ message: $r("app.string.no_network_prompt_msg") });
              }
            }),
          PanGesture({ fingers: 1 })
            .onActionUpdate((event: GestureEvent) => {
              const ICON_SIZE: number = 54;
              this.helperIconOffset.currentX = event.offsetX + this.helperIconOffset.lastX;
              this.helperIconOffset.currentY = event.offsetY + this.helperIconOffset.lastY;

              // 限制icon的偏移：不能超出屏幕
              if (this.helperIconOffset.currentX > 0) {
                this.helperIconOffset.currentX = 0;
              } else if (this.helperIconOffset.currentX < -1 * (this.windowSize.width - ICON_SIZE)) {
                this.helperIconOffset.currentX = -1 * (this.windowSize.width - ICON_SIZE);
              }
              if (this.helperIconOffset.currentY > 0) {
                this.helperIconOffset.currentY = 0;
              } else if (this.helperIconOffset.currentY < -1 * (this.windowSize.height - ICON_SIZE * 2)) {
                this.helperIconOffset.currentY = -1 * (this.windowSize.height - ICON_SIZE * 2);
              }
            })
            .onActionEnd((event: GestureEvent) => {
              this.helperIconOffset.stash();
            })
        )
      )
      .size({ width: $r("app.integer.helper_size"), height: $r("app.integer.helper_size") })
      .margin($r("sys.float.ohos_id_card_margin_start"))
      .bindSheet($$this.isShowReadMe, this.buildReadMeSheet(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        showClose: false,
        dragBar: true,
        backgroundColor: "#303643",
        preferType: SheetType.CENTER,
        enableOutsideInteractive: true,
      })
  }

  // 帮助功能：半模态弹窗显示对应案例README
  @Builder
  buildReadMeSheet(): void {
    Column() {
      NodeContainer(getNWeb(this.helperUrl, this.getUIContext()))
        .width($r("app.string.full_size"))
        .height($r("app.string.full_size"))
    }
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
  }
}