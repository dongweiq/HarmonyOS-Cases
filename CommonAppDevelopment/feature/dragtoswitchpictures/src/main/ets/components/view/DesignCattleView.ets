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
import { DecorationComparisonView } from './DragToSwitchPicturesView';
import { CONFIGURATION } from '../common/Constants';
import { promptAction } from '@kit.ArkUI';

@Component
export struct DesignCattleView {
  build() {
    Column() {
      Text($r('app.string.dragtoswitchpictures_title'))
        .width($r('app.string.full_size'))
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontWeight('sys.string.ohos_id_text_font_family_medium')
        .margin({ top: $r('app.integer.margin_length') })

      DecorationComparisonView()

      RelativeContainer() {
        Text()
          .aspectRatio(CONFIGURATION.DESIGNCATTLEVIEW_TEXT_ASPECTRATIO)
          .width($r('app.integer.designcattleview_column_row_text_width'))
          .height($r('app.string.full_size'))
          .backgroundColor($r('app.color.designcattleview_column_row_text_backgroundcolor'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
          .margin({ right: $r('app.integer.dragtoswitchpictures_margin_right_170') })
          .onClick((event?: ClickEvent) => {
            promptAction.showToast({
              message: $r('app.string.dragtoswitchpictures_toast_one'),
              duration: CONFIGURATION.DRAGTOSWITCHPICTURES_DURATION
            });
          })
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })
          .id("text1")
          .margin({ left: 10, top: 10 })

        Text($r('app.string.design_cattle'))
          .fontSize($r('app.integer.designcattleview_designcattle_text_fontsize'))
          .fontColor($r('app.color.designcattleview_column_designcattle_fontcolor'))
          .alignRules({
            top: { anchor: "text1", align: VerticalAlign.Top },
            left: { anchor: "text1", align: HorizontalAlign.End }
          })
          .id("text2")
          .margin({ left: 10, top: 10 })
        Text($r('app.string.ai_design'))
          .fontSize($r('app.integer.ai_design_fontsize'))
          .width($r('app.integer.ai_design_width'))
          .fontColor($r('app.color.ai_design_fontcolor'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.integer.ai_design_borderradius'))
          .margin({ left: $r('app.integer.ai_design_margin_length') })
          .backgroundColor($r('app.color.ai_design_backgroundcolor'))
          .alignRules({
            top: { anchor: "text2", align: VerticalAlign.Top },
            left: { anchor: "text2", align: HorizontalAlign.End }
          })
          .id("text3")
          .margin({ left: 2, top: 2 })
        Text($r('app.string.10s_text'))
          .fontSize($r('app.integer.10s_fontsize'))
          .alignRules({
            top: { anchor: "text2", align: VerticalAlign.Bottom },
            left: { anchor: "text2", align: HorizontalAlign.Start }
          })
          .id("text4")

        Button({ type: ButtonType.Capsule, stateEffect: true })
          .borderRadius($r('app.integer.borderradius'))
          .backgroundColor($r('app.color.go_to_try_button_backgroundcolor'))
          .width($r('app.integer.go_to_try_button_width'))
          .height($r('app.integer.go_to_try_button_height'))
          .onClick((event?: ClickEvent) => {
            promptAction.showToast({
              message: $r('app.string.dragtoswitchpictures_toast_two'),
              duration: CONFIGURATION.DRAGTOSWITCHPICTURES_DURATION
            });
          })
          .alignRules({
            top: { anchor: "text3", align: VerticalAlign.Top },
            left: { anchor: "text3", align: HorizontalAlign.End }
          })
          .id("button1")
          .margin({ left: 70 })

        Text($r('app.string.go_to_try'))
          .fontSize($r('app.integer.10s_fontsize'))
          .fontColor($r('app.color.ai_design_fontcolor'))
          .margin({
            left: $r('app.integer.ai_design_margin_length'),
            right: $r('app.integer.ai_design_margin_length')
          })
          .alignRules({
            top: { anchor: "button1", align: VerticalAlign.Top },
            left: { anchor: "button1", align: HorizontalAlign.Start }
          })
          .id("text5")
          .margin({ left: 15, top: 8 })
        Image($r('app.media.go_to_try'))
          .width($r('app.integer.go_to_try_image_width'))
          .objectFit(ImageFit.Auto)
          .height($r('app.integer.go_to_try_image_height'))
          .draggable(false)
          .alignRules({
            top: { anchor: "text5", align: VerticalAlign.Top },
            left: { anchor: "text5", align: HorizontalAlign.End }
          })
          .id("image1")
          .margin({ left: 4, top: 1 })
      }
      .width(320)
      .height($r('app.integer.designcattleview_column_row_height'))
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.designcattleview_backgroundcolor'))
    .margin({ top: $r('app.integer.margin_length') })
    .width($r('app.string.95_size'))
    .borderRadius($r('app.integer.borderradius'))
  }
}