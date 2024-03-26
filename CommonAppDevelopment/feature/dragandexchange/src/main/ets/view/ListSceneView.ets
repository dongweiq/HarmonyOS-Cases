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

const ICON_NUM_IN_LIST: number = 4; // 示例List中子组件数目
const LIST_SPACE: number = 30; // 列表默认间隔

/**
 * 实现List场景，拖拽交换子组件位置: 通过ListItem的onDragStart()方法指定拖拽开始时的行为，通过List的onTouch()指定拖拽释放时的行为。
 */
@Component
export struct ListSceneView {
  @State appInfoList: AppInfo[] = [];
  @State dragIndex: number = 0;

  aboutToAppear() {
    for (let index = 0; index < ICON_NUM_IN_LIST; index++) {
      this.appInfoList.push(new AppInfo($r(`app.media.ic_public_game${index + 1}`), `item${index + 1}`, true));
    }
  }

  changeIndex(index1: number, index2: number) {
    let temp: AppInfo = this.appInfoList[index1];
    this.appInfoList[index1] = this.appInfoList[index2];
    this.appInfoList[index2] = temp;
  }

  build() {
    Column() {
      Text($r('app.string.list_drag_title'))
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .fontSize($r('app.string.opt_title_font_size'))
      Row() { // 仅靠List实现背景框，padding调整样式后，互换时可能错位
        List({ space: LIST_SPACE }) {
          // TODO: 性能知识点：图标一次性完全显示，且禁用滑动，无需懒加载。LazyForEach可以适用在动态添加数据的场景中，参考资料：
          //  https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/
          ForEach(this.appInfoList, (item: AppInfo, index) => {
            ListItem() {
              Column() {
                IconNoNameView({ app: item })
              }
            }
            .onDragStart(() => { // TODO：知识点：在ListItem层，通过onDragStart实现拖拽开始时的回调行为
              item.visible = false; // 拖拽时，设置子组件原位置图标不可见
            })
            .onTouch((event: TouchEvent) => { // 拖拽释放时，记录目标位置子组件index值
              if (event.type === TouchType.Down) {
                this.dragIndex = index;
              }
            })
          })
        }
        .scrollBar(BarState.Off)
        .height($r('app.string.layout_70'))
        .listDirection(Axis.Horizontal)
        .alignListItem(ListItemAlign.Center)
        .onDrop((event: DragEvent, extraParams: string) => { // TODO：知识点：在List层，通过onDrop实现拖拽结束后的回调行为
          let jsonString: JsonObjType = JSON.parse(extraParams) as JsonObjType; // 通过参数extraParams获取原位置子组件index值
          this.changeIndex(this.dragIndex, jsonString.insertIndex); // 互换子组件index值
          this.appInfoList[jsonString.insertIndex].visible = true; // 完成互换后，设置子组件原位置图标不可见
        })
        .enableScrollInteraction(false) // 禁用滑动
        .alignListItem(ListItemAlign.Center)
        .padding({top: $r('app.string.layout_10'), bottom: $r('app.string.layout_10'), left: $r('app.string.layout_15'), right: $r('app.string.layout_15')})
      }
      .justifyContent(FlexAlign.Center)
      .height($r('app.string.layout_70'))
      .width($r('app.string.layout_90_percent'))
      .borderRadius($r('app.string.layout_20'))
      .opacity($r('app.string.background_opacity'))
      .backgroundColor($r('app.color.background_color'))
    }
    .margin({top: $r('app.string.layout_20')})
  }
}

/**
 * 无名字App自定义组件
 */
@Component
struct IconNoNameView {
  @ObjectLink app: AppInfo;

  build() {
    Column() {
      Image(this.app.icon)
        .width($r('app.string.icon_square_size'))
        .height($r('app.string.icon_square_size'))
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.layout_10'))
        .draggable(false) // TODO：知识点：保持默认值true时，图片有默认拖拽效果，会影响List子组件拖拽动效，所以修改为false
    }.visibility(this.app.visible ? Visibility.Visible : Visibility.Hidden) // 消失时需要占位，所以使用显隐控制而非条件渲染。（条件渲染与显隐控制区别，参考资料：https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/proper-choice-between-if-and-visibility.md/）
  }
}

/**
 * 封装处理处理JSON对象的类
 */
class JsonObjType {
  public insertIndex: number;

  constructor(insertIndex: number) {
    this.insertIndex = insertIndex;
  }
}