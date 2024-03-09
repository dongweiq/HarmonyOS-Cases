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

import { Constants } from '../constants/Constants';

@Component
export struct CustomFormComponent {
  @Link res: object;
  @Prop title: number

  build() {
    Column() {
      Text(Constants.TABLE_TITLE_PREFIX + this.title.toString())
        .fontSize(Constants.NUMBER_12)
      Row() {
        ForEach(Object.keys(this.res), (key: string) => {
          Text(key)
            .fontSize($r('app.integer.table_font_size'))
            .border({ width: $r('app.integer.table_border_width'), color: $r('app.color.table_border_color') })
            .textAlign(TextAlign.Center)
            .height($r('app.integer.table_height'))
            .width($r('app.string.table_width'))
        })
      }.backgroundColor($r('app.color.table_background_color'))

      Row() {
        ForEach(Object.keys(this.res), (key: string) => {
          Text(this.res[key]?.toString())
            .fontSize($r('app.integer.table_font_size'))
            .border({ width: $r('app.integer.table_border_width'), color: $r('app.color.table_border_color') })
            .textAlign(TextAlign.Center)
            .height($r('app.integer.table_height'))
            .width($r('app.string.table_width'))
        })
      }
    }
  }
}