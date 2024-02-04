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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expreIndexss or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { STYLE_CONFIGURATION } from '../model/constantsData';

const MAX_SHEET_COUNT = 6; // 最大页签数量
const HIDE_CLOSE_SHEET_COUNT = 4; // 隐藏关闭按钮时页签数量

@Component
export struct TabSheets {
  @Link tabArray: Array<number>; // 控制页签渲染的数组
  @Link focusIndex: number; // Tabs组件当前显示的页签下标
  controller: TabsController = new TabsController(); // Tabs控制器

  build() {
    Row({ space: STYLE_CONFIGURATION.TAB_BAR_ITEM_GUTTER }) {
      ForEach(this.tabArray, (item: number, index: number) => {
        Row({ space: STYLE_CONFIGURATION.TAB_BAR_CONTENT_GUTTER }) {
          Image($r('app.media.ic_public_worldclock_filled'))
            .width(STYLE_CONFIGURATION.ICON_SIZE)
            .aspectRatio(1)
          Text($r('app.string.newSheet'))
            .textOverflow({ overflow: TextOverflow.Clip })
            .maxLines(1)
            .flexShrink(1)
          /**
           * 场景1：页签数量小于HIDE_CLOSE_SHEET_COUNT时，所有页签都显示关闭图标。
           * 场景2：页签数量大于HIDE_CLOSE_SHEET_COUNT时，只有获焦页签显示关闭图标。
           */
          if (this.tabArray.length < HIDE_CLOSE_SHEET_COUNT || this.focusIndex === index) {
            Image($r('app.media.ic_public_cancel_filled'))
              .width(STYLE_CONFIGURATION.ICON_SIZE)
              .aspectRatio(1)
              .onClick(() => {
                // 关闭页签
                if (this.tabArray.length > 1) {
                  this.tabArray.splice(index, 1);
                  if (this.tabArray[index] === undefined) {
                    this.focusIndex = index - 1;
                  } else if (this.tabArray[index] !== undefined && this.focusIndex !== index) {
                    this.focusIndex -= 1;
                  }
                }
              })
          }
        }
        .flexShrink(1)
        .padding({
          left: $r('sys.float.ohos_id_elements_margin_horizontal_m'),
          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
        })
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_xs'))
        .height('100%')
        .backgroundColor(this.focusIndex === index ? $r('sys.color.ohos_id_color_background') : $r('sys.color.ohos_id_color_sub_background'))
        .onClick(() => {
          this.controller.changeIndex(index);
        })

        if (this.focusIndex !== index && this.focusIndex - 1 !== index) {
          Divider()
            .vertical(true)
            .strokeWidth(STYLE_CONFIGURATION.SEPARATOR_STROKE_WIDTH)
            .height('50%')
            .lineCap(LineCapStyle.Round)
        }
      })

      Image($r('app.media.ic_public_add_filled'))
        .width(STYLE_CONFIGURATION.ICON_SIZE)
        .aspectRatio(1)
        .onClick(() => {
          // 新增页签
          if (this.tabArray.length < MAX_SHEET_COUNT) {
            this.tabArray.push(this.tabArray.length);
            let newTabIndex: number = this.tabArray.length - 1;
            this.focusIndex = newTabIndex;
          }
        })
    }
    .padding(STYLE_CONFIGURATION.TAB_SHEET_PADDING)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width('100%')
    .height(STYLE_CONFIGURATION.TAB_BAR_HEIGHT)
  }
}