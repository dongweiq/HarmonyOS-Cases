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
 * 搜索和地图视图
 */

@Component
export struct SearchMapView {
  build() {
    Row() {
      Search({ placeholder: $r('app.string.dragtoswitchpictures_search_placeholder') })
        .focusOnTouch(false)
        .focusable(false)
        .enableKeyboardOnFocus(false)
        .backgroundColor($r('app.color.search_backgroundcolor'))
        .width($r('app.string.83_size'))
        .margin({ left: $r('app.integer.margin_length') })

      Column() {
        Image($r("app.media.drag_picture_map"))
          .width($r('app.integer.map_image_width'))
          .objectFit(ImageFit.Fill)
          .height($r('app.integer.map_image_height'))
          .draggable(false)

        Text($r('app.string.map_text'))
          .fontSize($r('app.integer.map_text_fontsize'))
      }
      .width($r('app.string.10_size'))
      .margin({ left: $r('app.integer.margin_length'), right: $r('app.integer.margin_length') })
    }
    .width($r('app.string.full_size'))
    .justifyContent(FlexAlign.Start)
    .height($r('app.integer.searchmap_row_height'))
  }
}