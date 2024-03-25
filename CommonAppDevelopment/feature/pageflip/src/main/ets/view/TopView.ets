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
import { promptAction } from '@kit.ArkUI';
import { DynamicsRouter } from '@ohos/dynamicsrouter/Index';

@Component
export struct TopView {
  @Link isMenuViewVisible: boolean; // 用来判断上下菜单视图是否显示。
  readonly pageFlipBottomBlankHeight = 0.3;
  readonly pageFlipToastDuration = 300;

  build() {
    Column() {
      Row() {
        Image($r('app.media.flippage_back'))
          .width($r('app.string.pageflip_lippage_10_size'))
          .height($r('app.string.pageflip_lippage_70_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            DynamicsRouter.pop();
          })

        Row() {
          Image($r('app.media.flippage_cloud_upload'))
            .width($r('app.string.pageflip_lippage_25_size'))
            .height($r('app.string.pageflip_lippage_60_size'))
            .objectFit(ImageFit.Contain)
            .padding($r('app.integer.flippage_padding_5'))
            .onClick((event?: ClickEvent) => {
              promptAction.showToast({
                message: $r('app.string.pageflip_default_toast'),
                duration: this.pageFlipToastDuration
              });
            })

          Image($r('app.media.flippage_contacts'))
            .width($r('app.string.pageflip_lippage_25_size'))
            .height($r('app.string.pageflip_lippage_60_size'))
            .objectFit(ImageFit.Contain)
            .padding($r('app.integer.flippage_padding_5'))
            .onClick((event?: ClickEvent) => {
              promptAction.showToast({
                message: $r('app.string.pageflip_default_toast'),
                duration: this.pageFlipToastDuration
              });
            })

          Image($r('app.media.flippage_share_filled'))
            .width($r('app.string.pageflip_lippage_25_size'))
            .height($r('app.string.pageflip_lippage_60_size'))
            .objectFit(ImageFit.Contain)
            .padding($r('app.integer.flippage_padding_5'))
            .onClick((event?: ClickEvent) => {
              promptAction.showToast({
                message: $r('app.string.pageflip_default_toast'),
                duration: this.pageFlipToastDuration
              });
            })

          Image($r('app.media.flippage_more_filled'))
            .width($r('app.string.pageflip_lippage_25_size'))
            .height($r('app.string.pageflip_lippage_60_size'))
            .objectFit(ImageFit.Contain)
            .padding($r('app.integer.flippage_padding_5'))
            .onClick((event?: ClickEvent) => {
              promptAction.showToast({
                message: $r('app.string.pageflip_default_toast'),
                duration: this.pageFlipToastDuration
              });
            })
        }.width($r('app.string.pageflip_lippage_60_size'))
      }
      .backgroundColor($r('app.color.pageflip_row_backgroundcolor'))
      .justifyContent(FlexAlign.SpaceBetween)
      .width($r('app.string.pageflip_full_size'))
      .height($r('app.string.pageflip_lippage_8_size'))

      Blank()
        .backgroundColor($r('app.color.pageflip_bottom_blank_backgroundcolor'))
        .width($r('app.string.pageflip_full_size'))
        .height(this.pageFlipBottomBlankHeight)
    }
    .visibility(this.isMenuViewVisible ? Visibility.Visible : Visibility.None)
  }
}