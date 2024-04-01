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

import { ICON_DATA1, ICON_DATA2 } from '../mock/IconMock';
import { IconDataModel } from '../model/IconModel';
import { promptAction } from '@kit.ArkUI';

const ICONVIEWSPACE: number = 10; // 图标之间间距
const ASPECT_RATIO: number = 1; // 图片的宽高比
const ICONLISTCOLUMNS1: number = 4; // 列表1的列数
const ICONLISTCOLUMNS2: number = 5; // 列表2的列数
const SPAN: number = 1; // 占列数

// 上图下文字白色背景样式
@Component
struct iconView1 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Column({ space: ICONVIEWSPACE }) {
      Image(this.icon)
        .width($r('app.integer.icon_view_width'))
        .aspectRatio(ASPECT_RATIO)
        .objectFit(ImageFit.Contain)

      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height($r('app.integer.icon_view_height'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius($r('app.integer.icon_view_border_radius'))
    .onClick(()=>{
      promptAction.showToast({ message: $r('app.string.component_stack_other_function')});
    })
  }
}

// 左文右图字白色背景样式
@Component
struct iconView2 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size2'))
        .fontColor(Color.Black)

      Image(this.icon)
        .width($r('app.integer.icon_view_width2'))
        .aspectRatio(ASPECT_RATIO)
        .objectFit(ImageFit.Contain)
        .margin({ left: $r('app.integer.icon_view_image_margin_left') })
    }
    .width('100%')
    .height($r('app.integer.icon_view_height2'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius($r('app.integer.icon_view_border_radius'))
    .onClick(()=>{
      promptAction.showToast({ message: $r('app.string.component_stack_other_function')});
    })
  }
}

// 上图下文字透明背景样式
@Component
struct iconView3 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Column({ space: ICONVIEWSPACE }) {
      Image(this.icon)
        .width($r('app.integer.icon_view_width'))
        .aspectRatio(ASPECT_RATIO)
        .objectFit(ImageFit.Contain)

      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height($r('app.integer.icon_view_height3'))
    .justifyContent(FlexAlign.Center)
    .onClick(()=>{
      promptAction.showToast({ message: $r('app.string.component_stack_other_function')});
    })
  }
}

@Component
export struct IconList1 {
  build() {
    GridRow({ columns: ICONLISTCOLUMNS1, gutter: { x: ICONVIEWSPACE, y: ICONVIEWSPACE } }) {
      // GridRow组件不支持LazyForEach方法
      ForEach(ICON_DATA1, (item: IconDataModel) => {
        GridCol({ span: item.span }) {
          if (item.span === SPAN) {
            iconView1({ icon: item.icon, title: item.title })
          } else {
            iconView2({ icon: item.icon, title: item.title })
          }
        }
      }, (item: IconDataModel) => item.id.toString())
    }
  }
}

@Component
export struct IconList2 {
  @Prop ratio: number;

  build() {
    GridRow({ columns: ICONLISTCOLUMNS2, gutter: { x: ICONVIEWSPACE, y: ICONVIEWSPACE } }) {
      // GridRow组件不支持LazyForEach方法
      ForEach(ICON_DATA2, (item: IconDataModel) => {
        GridCol({ span: item.span }) {
          iconView3({ icon: item.icon, title: item.title })
        }
        .scale({ x: this.ratio, y: this.ratio })
      }, (item: IconDataModel) => item.id.toString())
    }
  }
}

@Component
export struct IconList3 {
  scroller: Scroller = new Scroller();
  @Prop marginSpace: number;

  build() {
    List({ space: this.marginSpace }) {
      // 当前是固定菜单列表，数量少，不需要使用LazyForEach做性能优化
      ForEach(ICON_DATA1, (item: IconDataModel) => {
        ListItem() {
          iconView1({ icon: item.icon, title: item.title })
            .width($r('app.integer.icon_view_height'))
        }
      }, (item: IconDataModel) => item.id.toString())
    }
    .height($r('app.integer.icon_view_height'))
    .width('100%')
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }
}



