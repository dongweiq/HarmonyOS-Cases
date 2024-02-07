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

import { AppInfo } from '../model/AppInfo';

const ICON_NUM_IN_GRID: number = 15; // 示例Grid中子组件数目

/**
 * 实现Grid场景，拖拽交换子组件位置: 通过editMode()打开编辑模式、通过onItemDragStart()指定拖拽时样式、通过onItemDrop()指定拖拽释放时的行为
 */
@Component
export struct GridSceneView {
  @State appInfoList: AppInfo[] = [];
  @State movedItem: AppInfo = new AppInfo();

  aboutToAppear() {
    for (let index = 1; index <= ICON_NUM_IN_GRID; index++) {
      this.appInfoList.push(new AppInfo($r(`app.media.ic_public_app${index}`), `App${index}`));
    }
  }

  build() {
    Column() {
      Text($r('app.string.grid_drag_title'))
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .fontSize($r('app.string.opt_title_font_size'))
      Row() {
        Grid() {
          ForEach(this.appInfoList, (item: AppInfo) => { // TODO: 性能知识点：图标一次性完全显示，且禁用滑动，无需懒加载（LazyForEach可以适用在动态添加数据的场景中，参考资料：https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/）
            GridItem() {
              IconWithNameView({ app: item });
            }
            .width($r('app.string.icon_square_size'))
            .height($r('app.string.layout_70'))
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap($r('app.string.layout_10'))
        .rowsGap($r('app.string.layout_10'))
        .editMode(true) // TODO：知识点：设置Grid进入编辑模式，方可拖拽Grid组件内部GridItem
        .onItemDragStart((event: ItemDragInfo, itemIndex: number) => { // TODO：知识点：在Grid层，通过onItemDragStart实现拖拽开始时的回调行为
          this.movedItem = this.appInfoList[itemIndex];
          return this.itemWhileDrag(); //设置拖拽过程中显示的图形
        })
        .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => { // TODO：知识点：在Grid层，通过onItemDrop实现拖拽结束后的回调行为
          // isSuccess=false时，说明drop的位置在grid外部；insertIndex > length时，说明有新增元素的事件发生
          if (isSuccess && insertIndex < this.appInfoList.length) {
            this.changeIndex(itemIndex, insertIndex);
          }
        })
        .padding({ top: $r('app.string.layout_10'), bottom: $r('app.string.layout_10'), left: $r('app.string.layout_5'), right: $r('app.string.layout_5') })
      }
      .width($r('app.string.layout_420'))
      .height($r('app.string.layout_250'))
      .borderRadius($r('app.string.layout_20'))
      .opacity($r('app.string.background_opacity'))
      .backgroundColor($r('app.color.background_color'))
    }
  }

  /**
   * 设置GridItem拖拽过程中显示的图形
   */
  @Builder
  itemWhileDrag() {
    IconWithNameView({ app: this.movedItem })
      .width($r('app.string.icon_square_size'))
      .height($r('app.string.icon_square_size'))
  }

  changeIndex(index1: number, index2: number) {
    let temp: AppInfo = this.appInfoList[index1];
    this.appInfoList[index1] = this.appInfoList[index2];
    this.appInfoList[index2] = temp;
  }
}

/**
 * App自定义组件
 */
@Component
struct IconWithNameView {
  @ObjectLink app: AppInfo

  build() {
    Column() {
      Image(this.app.icon)
        .width($r('app.string.icon_square_size'))
        .height($r('app.string.icon_square_size'))
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.layout_10'))
      Text(this.app.name)
        .width($r('app.string.icon_square_size'))
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({ top: $r('app.string.layout_1') })
        .fontSize($r('app.string.app_name_font_size'))
    }
  }
}
