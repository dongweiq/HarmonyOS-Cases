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
 * 模块功能描述组件
 * @param title 标题
 * @param context 内容
 */
@Component
export struct FunctionDescription {
  private title: ResourceStr = '';
  private content: ResourceStr = '';

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize($r('app.string.ohos_id_text_size_headline'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({overflow:TextOverflow.Ellipsis})
          .maxLines(1)
      }
      .margin({ bottom: $r('app.string.ohos_id_elements_margin_vertical_m') })
      Row(){
        Text(this.content)
          .wordBreak(WordBreak.BREAK_ALL)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}