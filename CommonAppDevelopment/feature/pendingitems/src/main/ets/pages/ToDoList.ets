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
import { ToDoListItem } from './ToDoListItem';
import promptAction from '@ohos.promptAction';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { STYLE_CONFIG } from '../model/ConstData';

/*
 * 实现步骤：
 * 1. List组件绑定@State修饰的数组变量toDoData。
 * 2. ListItem组件设置左滑动效swipeAction属性。
 * 3. 触发点击事件新增/删除列表项，更新数组变量toDoData，并同时更新List组件UI(MVVM)。
 */

@Extend(Image)
function ImageStyle() {
  .width(STYLE_CONFIG.IMAGE_SIZE)
  .aspectRatio(1)
  .margin(STYLE_CONFIG.IMAGE_MARGIN)
}

@Component
export struct ToDoList {
  @State toDoData: ToDo[] = []; // 待办事项数据
  @Watch('onEditModeChange') @State isEditMode: boolean = false; // 是否处于编辑模式
  @State selectedItems: ToDo[] = []; // 被选中项数据
  private availableThings: string[] = ['读书', '运动', '旅游', '听音乐', '看电影', '唱歌']; // 待办可选事项
  private menuList: Resource[] = [
    $r('app.media.ic_public_share'),
    $r('app.media.ic_public_move'),
    $r('app.media.ic_public_delete'),
    $r('app.media.ic_public_more')
  ]; // 操作栏图标

  onEditModeChange() {
    if (!this.isEditMode) {
      // 退出编辑模式时，清空被选择数组中元素
      this.selectedItems = [];
    }
  }

  // item左滑显示工具栏
  @Builder
  ItemEnd(index: number) {
    if (this.isEditMode) {
      Row()
    } else {
      Row({ space: STYLE_CONFIG.ICON_GUTTER }) {
        Image($r('app.media.ic_public_settings_filled')).ImageStyle()
        Image($r('app.media.ic_public_detail_filled')).ImageStyle()
        Image($r('app.media.ic_public_delete_filled')).ImageStyle()
          .onClick(() => {
            this.toDoData.splice(index, 1); // 删除当前操作的待办事项
            promptAction.showToast({ message: 'delete success!' });
          })
      }
      .padding(STYLE_CONFIG.OPERATION_BUTTON_PADDING)
      .justifyContent(FlexAlign.SpaceEvenly)
    }
  }

  build() {
    Column() {
      Row() {
        if (this.isEditMode) {
          Text('X')
            .fontSize($r('sys.float.ohos_id_text_size_headline8'))
            .onClick(() => {
              this.isEditMode = false; // 退出编辑模式
            })
            .margin({
              left: $r('sys.float.ohos_id_max_padding_start'),
              right: $r('sys.float.ohos_id_max_padding_end')
            })

          Text(`已选择${this.selectedItems.length}项`)
            .fontSize($r('sys.float.ohos_id_text_size_headline7'))
        } else {
          Text($r('app.string.todo'))
            .fontSize($r('sys.float.ohos_id_text_size_headline6'))
            .margin({ left: STYLE_CONFIG.TEXT_MARGIN_LEFT })
          Blank()
          Image($r('app.media.ic_public_add_filled'))
            .width(STYLE_CONFIG.IMAGE_SIZE)
            .aspectRatio(1)
            .margin({ right: STYLE_CONFIG.IMAGE_MARGIN_RIGHT })
            .onClick(() => {
              // TODO：知识点：1.根据文本选择的选择结果，向待办事项数组中添加数据
              TextPickerDialog.show({
                range: this.availableThings,
                onAccept: (value: TextPickerResult) => {
                  this.toDoData.push(new ToDo(this.availableThings[Number(value.index)]));
                },
              })
            })
        }
      }
      .height('12%')
      .width('100%')

      // TODO：知识点：2.待办数据显示列表组件绑定数据变量toDoData
      List({ initialIndex: 0, space: STYLE_CONFIG.LIST_ITEM_GUTTER }) {
        /**
         * 性能知识点：数据量少时使用ForEach进行循环数据渲染，数据量多时使用LazyForEach循环数据渲染
         * 文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
         */
        ForEach(this.toDoData, (toDoItem: ToDo, index: number) => {
          ListItem() {
            ToDoListItem({
              isEditMode: $isEditMode,
              toDoItem: toDoItem,
              selectedItems: $selectedItems
            })
          }
          .padding({
            left: $r('sys.float.ohos_id_max_padding_start'),
            right: $r('sys.float.ohos_id_max_padding_end'),
            bottom: $r('sys.float.ohos_id_dialog_button_padding_bottom')
          })
          // TODO：知识点：3.设置ListItem的swipeAction属性，左滑时，显示自定义UI视图
          .swipeAction({ end: this.ItemEnd(index), edgeEffect: SwipeEdgeEffect.Spring })
        }, (toDoItem: ToDo) => toDoItem.key)
      }
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)

      // 编辑模式下，显示底部操作工具栏
      if (this.isEditMode) {
        Row() {
          ForEach(this.menuList, (item: Resource, index: number) => {
            Image(item)
              .width(STYLE_CONFIG.MENU_IMAGE_SIZE)
              .aspectRatio(1)
              .onClick(() => {
                // 在待办事项数组中删除已被选中的事项
                if (index === 2) {
                  let leftData = this.toDoData.filter((item) => {
                    return this.selectedItems.find((selectedItem) => selectedItem !== item);
                  })
                  this.isEditMode = false;
                  this.toDoData = leftData;
                  promptAction.showToast({ message: 'delete success!' });
                }
              })
          })
        }
        .height(STYLE_CONFIG.MENU_HEIGHT)
        .justifyContent(FlexAlign.SpaceEvenly)
        .width('100%')
      }
    }
    .backgroundColor($r('app.color.pageBcColor'))
    .width('100%')
    .height('100%')
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getToDoList(): void {
  ToDoList();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.PENDING_ITEMS,wrapBuilder(getToDoList));