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
      Row({ space: 4 }) {
        Circle()
          .width(24)
          .height(24)
          .fill(Color.White)
          .borderWidth(3)
          .borderRadius(30)
          .borderColor('#ffdcdfdf')
          .margin({ right: 10 })

        Text(`${this.toDoItem.name}`)
          .maxLines(1)
          .fontSize(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .padding({ left: 12 })

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
          .width(24)
          .height(24)
      }
    }
    .width('100%')
    .height(80)
    .padding({
      left: 16,
      right: 12,
      top: 4,
      bottom: 4
    })
    .borderRadius(24)
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