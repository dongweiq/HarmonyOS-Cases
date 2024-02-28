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
import { STYLE_CONFIG } from '../model/ConstData';

import { ToDo } from '../model/ToDo';

@Component
export struct ToDoListItem {
  @Link isEditMode: boolean;
  @Link selectedItems: ToDo[];
  private toDoItem: ToDo = new ToDo('');

  // 判断当前item是否被选中
  hasBeenSelected(): boolean {
    return this.selectedItems.indexOf(this.toDoItem) !== -1;
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: STYLE_CONFIG.ICON_GUTTER }) {
        Circle()
          .width(STYLE_CONFIG.MENU_IMAGE_SIZE)
          .aspectRatio(1)
          .fill(Color.White)
          .borderWidth(STYLE_CONFIG.BORDER_WIDTH)
          .borderRadius(STYLE_CONFIG.MENU_IMAGE_SIZE)
          .borderColor($r('app.color.borderColor'))
          .margin({ right: $r('sys.float.ohos_id_dialog_margin_end') })

        Text(`${this.toDoItem.name}`)
          .maxLines(1)
          .fontSize($r('sys.float.ohos_id_text_size_headline7'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .padding({ left: $r('sys.float.ohos_id_default_padding_start') })

      if (this.isEditMode) {
        Checkbox()
          .select(this.hasBeenSelected() ? true : false)
          .onChange((isSelected) => {
            // 根据用户的选择结果，向已勾选事项数组中添加或删除数据
            if (isSelected) {
              this.selectedItems.push(this.toDoItem);
            } else {
              let index = this.selectedItems.indexOf(this.toDoItem);
              if (index !== -1) {
                this.selectedItems.splice(index, 1);
              }
            }
          })
          .width(STYLE_CONFIG.MENU_IMAGE_SIZE)
          .aspectRatio(1)
      }
    }
    .width('100%')
    .height(STYLE_CONFIG.TODO_ITEM_HEIGHT)
    .padding({
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      top: STYLE_CONFIG.TODO_ITEM_PADDING_VERTICAL,
      bottom: STYLE_CONFIG.TODO_ITEM_PADDING_VERTICAL
    })
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_xl'))
    .linearGradient({
      direction: GradientDirection.Right,
      colors: this.hasBeenSelected() ? [[0xffcdae, 0.0], [0xFfece2, 1.0]] : [[0xffffff, 0.0], [0xffffff, 1.0]]
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture()
          .onAction(() => {
            // 触发长按手势，进入编辑模式
            if (!this.isEditMode) {
              this.isEditMode = true;
              this.selectedItems.push(this.toDoItem);
            }
          })
      )
    )
  }
}