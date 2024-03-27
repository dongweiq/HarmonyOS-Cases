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
import { CONFIGURATION, STRINGCONFIGURATION } from '../common/Constants';

@Component
export struct TopView {
  @Link isMenuViewVisible: boolean; // 用来判断上下菜单视图是否显示。
  @State imageNameList: Array<string> = [STRINGCONFIGURATION.FLIPPAGECLOUDUPLOAD, STRINGCONFIGURATION.FLIPPAGECONTACTS, STRINGCONFIGURATION.FLIPPAGESHAREFILLED, STRINGCONFIGURATION.FLIPPAGEMOREFILLED]

  build() {
    Column() {
      Row() {
        Image($r('app.media.flippage_back'))
          .width($r('app.string.pageflip_topview_row_image_width'))
          .height($r('app.string.pageflip_topview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            DynamicsRouter.pop();
          })

        Row() {
          ForEach(this.imageNameList, (item: string) => {
            Image($r(item))
              .width($r('app.string.pageflip_topview_row_row_image_width'))
              .height($r('app.string.pageflip_topview_row_row_image_height'))
              .objectFit(ImageFit.Contain)
              .padding($r('app.integer.flippage_padding_small'))
              .onClick(() => {
                promptAction.showToast({
                  message: $r('app.string.pageflip_default_toast'),
                  duration: CONFIGURATION.PAGEFLIPTOASTDURATION
                });
              })
          }, (item: string) => item)

        }.width($r('app.string.pageflip_topview_row_row_image_height'))
      }
      .backgroundColor($r('app.color.pageflip_row_backgroundcolor'))
      .justifyContent(FlexAlign.SpaceBetween)
      .width($r('app.string.pageflip_full_size'))
      .height($r('app.string.pageflip_topview_row_height'))

      Blank()
        .backgroundColor($r('app.color.pageflip_bottom_blank_backgroundcolor'))
        .width($r('app.string.pageflip_full_size'))
        .height(CONFIGURATION.PAGEFLIPBOTTOMBLANKBEIGHT)
    }
    .visibility(this.isMenuViewVisible ? Visibility.Visible : Visibility.None)
  }
}