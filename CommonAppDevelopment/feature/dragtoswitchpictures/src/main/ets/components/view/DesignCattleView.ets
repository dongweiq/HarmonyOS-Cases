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

/**
 * AI设计视图
 */
import { DecorationComparsionView } from './DragToSwitchPicturesView'
import { CONFIGURATION } from '../common/Constants'

@Component
export struct DesignCattleView {
  build() {
    Column() {
      DecorationComparsionView()

      Row() {
        Text()
          .aspectRatio(CONFIGURATION.DESIGNCATTLEVIEW_TEXT_ASPECTRATIO)
          .width($r('app.integer.designcattleview_column_row_text_width'))
          .height($r('app.string.full_size'))
          .backgroundColor($r('app.color.designcattleview_column_row_text_backgroundcolor'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
          .margin($r('app.integer.margin_length'))

        Column() {
          Row() {
            Text($r('app.string.design_cattle'))
              .fontSize($r('app.integer.designcattleview_designcattle_text_fontsize'))
              .fontColor($r('app.color.designcattleview_column_designcattle_fontcolor'))
            Text($r('app.string.ai_design'))
              .fontSize($r('app.integer.ai_design_fontsize'))
              .width($r('app.integer.ai_design_width'))
              .fontColor($r('app.color.ai_design_fontcolor'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.integer.ai_design_borderradius'))
              .margin({ left: $r('app.integer.ai_design_margin_length') })
              .backgroundColor($r('app.color.ai_design_backgroundcolor'))
          }

          Text($r('app.string.10s_text'))
            .fontSize($r('app.integer.10s_fontsize'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: $r('app.integer.designcattleview_row_column_margin_length') })

        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row() {
            Text($r('app.string.go_to_try'))
              .fontSize($r('app.integer.10s_fontsize'))
              .fontColor($r('app.color.ai_design_fontcolor'))
              .margin({
                left: $r('app.integer.ai_design_margin_length'),
                right: $r('app.integer.ai_design_margin_length')
              })
            Image($r('app.media.go_to_try'))
              .width($r('app.integer.go_to_try_image_width'))
              .objectFit(ImageFit.Auto)
              .height($r('app.integer.go_to_try_image_height'))
              .draggable(false)
          }.alignItems(VerticalAlign.Center)
        }
        .borderRadius($r('app.integer.borderradius'))
        .backgroundColor($r('app.color.go_to_try_button_backgroundcolor'))
        .width($r('app.integer.go_to_try_button_width'))
        .height($r('app.integer.go_to_try_button_height'))
        .margin({ right: $r('app.integer.margin_length') })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width($r('app.string.full_size'))
      .height($r('app.integer.designcattleview_column_row_height'))
    }
    .backgroundColor($r('app.color.designcattleview_backgroundcolor'))
    .margin({ top: $r('app.integer.margin_length') })
    .width($r('app.string.95_size'))
    .borderRadius($r('app.integer.borderradius'))
  }
}