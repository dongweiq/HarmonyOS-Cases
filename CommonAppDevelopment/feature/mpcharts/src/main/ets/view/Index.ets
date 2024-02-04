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

import { LineCharts } from './LineCharts'
import { BarCharts } from './BarCharts'

const HEART_RATE: string = 'heartRate';
const STEP_NUMBER: string = 'stepNumber';
const HEART_RATE_TODAY_DATA: Array<number> = [75, 70, 85, 75, 83, 72, 79, 80, 83, 86, 79, 86, 93, 80, 76, 78, 85, 91, 81, 78, 85, 93, 87, 79, 73];
const HEART_RATE_REFERENCE_DATA: Array<number> = [78, 73, 78, 71, 79, 76, 83, 85, 79, 86, 89, 75, 84, 87, 79, 75, 83, 79, 85, 83, 77, 84, 73, 71, 79, 86, 88, 79];
const STEP_NUMBER_TODAY_DATA: Array<number> = [0, 0, 0, 0, 0, 0, 0, 580, 1309, 820, 103, 86, 1715, 1235, 76, 155, 168, 268, 2045, 405, 404, 21, 582, 144, 0];
const STEP_NUMBER_REFERENCE_DATA: Array<number> = [0, 0, 0, 0, 0, 0, 230, 706, 809, 450, 166, 186, 708, 304, 31, 166, 188, 406, 1405, 155, 303, 122, 0, 0, 0, 0, 0, 0];


@Preview
@Component
export struct MpCharts {
  build() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Row() {
              Text($r('app.string.fitness_record'))
                .font({ size: $r('app.integer.font_size_24'), weight: FontWeight.Bold, family: $r('app.string.font_family') })

              Text($r('app.string.fitness_date'))
                .font({ size: $r('app.integer.font_size_20'), weight: FontWeight.Bold, family: $r('app.string.font_family') })
                .fontColor(Color.Gray)
                .margin({ left: $r('app.integer.margin_10') })
                .alignSelf(ItemAlign.End)
            }

            Text($r('app.string.fitness_rate'))
              .font({ size: $r('app.integer.font_size_18'), family: $r('app.string.font_family') })
              .alignSelf(ItemAlign.End)

          }
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: $r('app.integer.margin_20') })

          BarCharts()
        }
        .width($r('app.string.layout_100'))
        .backgroundColor(Color.White)
        .border({ radius: $r('app.integer.radius_20') })
        .shadow({ radius: $r('app.integer.radius_10'), color: Color.Gray })
        .padding($r('app.integer.padding_20'))
      }
      .margin({ bottom: $r('app.integer.margin_20') })

      ListItem() {
        Column() {
          Row() {
            Text($r('app.string.health_record'))
              .font({ size: $r('app.integer.font_size_24'), weight: FontWeight.Bold, family: $r('app.string.font_family') })

            Text($r('app.string.health_date'))
              .font({ size: $r('app.integer.font_size_20'), weight: FontWeight.Bold, family: $r('app.string.font_family') })
              .fontColor(Color.Gray)
              .margin({ left: $r('app.integer.margin_10') })
              .alignSelf(ItemAlign.End)
          }
          .width($r('app.string.layout_100'))
          .alignItems(VerticalAlign.Bottom)
          .margin({ bottom: $r('app.integer.margin_20') })

          Divider()
            .margin({ bottom: $r('app.integer.margin_20') })
            .color($r('app.color.divider'))

          Text($r('app.string.heart_rate'))
            .font({ size: $r('app.integer.font_size_20'), weight: FontWeight.Bold, family: $r('app.string.font_family') })
            .alignSelf(ItemAlign.Start)

          LineCharts({
            type: HEART_RATE,
            todayData: HEART_RATE_TODAY_DATA,
            referenceData: HEART_RATE_REFERENCE_DATA
          })

          Text($r('app.string.step_number'))
            .font({ size: $r('app.integer.font_size_20'), weight: FontWeight.Bold, family: $r('app.string.font_family') })
            .alignSelf(ItemAlign.Start)

          LineCharts({
            type: STEP_NUMBER,
            todayData: STEP_NUMBER_TODAY_DATA,
            referenceData: STEP_NUMBER_REFERENCE_DATA
          })
        }
        .width($r('app.string.layout_100'))
        .backgroundColor(Color.White)
        .border({ radius: $r('app.integer.radius_20') })
        .shadow({ radius: $r('app.integer.radius_10'), color: Color.Gray })
        .padding($r('app.integer.padding_20'))
      }
    }
    .height($r('app.string.layout_100'))
    .backgroundColor(Color.Gray)
    .padding($r('app.integer.padding_10'))
    .width($r('app.string.layout_100'))
  }
}